# Copyright 2023 SentineOne, inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ------------------------------------------------------------------------
# author:  Joel Mora <joelm@sentinelone.com>

from __future__ import absolute_import

__author__ = "joelm@sentinelone.com"

import random
import subprocess
from scalyr_agent import ScalyrMonitor
from datetime import datetime, timedelta, timezone
import requests
import json
import hashlib
import logging
from scalyr_agent import scalyr_logging


class SnowflakeMonitor(ScalyrMonitor):
    """A Scalyr agent monitor that queries Snowflake and returns data.
    """

    def _initialize(self):
        """Performs monitor-specific initialization."""   

        pip_install = ['snowflake-connector-python', 'pandas', 'cryptography', 'pyjwt', "requests"]
        self.install_dependencies(pip_install)
        self.__counter = 0
        self.__snowflake_username = self._config.get(
            "snowflake_username", default="jmora", required_field=True
        )
        self.__rsa_key = self._config.get(
            "rsa_key", default="/tmp/rsa_key.p8", required_field=True
        )
        self.__rsa_key_password = self._config.get(
            "rsa_key_password", default="", required_field=False
        )
        self.__snowflake_account = self._config.get(
            "snowflake_account", default="uqfoqir-rlb55634", required_field=True
        )
        self.__snowflake_warehouse = self._config.get(
            "snowflake_warehouse", default="COMPUTE_WH", required_field=False
        )
        self.__snowflake_database = self._config.get(
            "snowflake_database", default="SNOWFLAKE_SAMPLE_DATA", required_field=False
        )
        self.__snowflake_schema = self._config.get(
            "snowflake_schema", default="TPCH_SF1", required_field=False
        )
        self.__sql_query = self._config.get(
            "sql_query", default="select current_version();", required_field=False
        )
        self.__account = self.__snowflake_account.upper()
        self.__user = self.__snowflake_username.upper()
        self.__qualified_username = self.__account + "." + self.__user
            

    def install_dependencies(self, libs_to_install):
        try:
            # check if pip is up-to-date
            subprocess.check_call(["pip", "install", "--upgrade", "pip"])
        except subprocess.CalledProcessError as e:
            print("Error: ", e)
        for lib in libs_to_install:
            try:
                # check if library is already installed
                subprocess.check_call(["pip", "show", lib], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            except subprocess.CalledProcessError as e:
                # library not found, install it
                print(f"{lib} not found, installing...")
                subprocess.check_call(["pip", "install", "--quiet", lib])
        # create test file if it does not exist



    def snowflake_connection(self):
        # Set your JWT token and account identifier
        jwt_token = self.generate_JWT()
        account_identifier = self.__snowflake_account
        # API endpoint URL
        url = f"https://{account_identifier}.snowflakecomputing.com/api/v2/statements"

        # Request headers
        headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'myApplicationName/1.0',
        'X-Snowflake-Authorization-Token-Type': 'KEYPAIR_JWT',
        'baseUrl': f'https://{account_identifier}.snowflakecomputing.com',
        'Authorization': f'Bearer {jwt_token}'
        }

        # Request body
        payload = {
            "statement": self.__sql_query
        }

        # Make a POST request using requests library
        response = requests.post(url, headers=headers, data=json.dumps(payload), verify=False)
        return response.text




    
    def generate_JWT(self):
        from cryptography.hazmat.primitives.serialization import load_pem_private_key
        from cryptography.hazmat.backends import default_backend
        import jwt
        qualified_username = self.__account + "." + self.__user
        now = datetime.now(timezone.utc)
        lifetime = timedelta(minutes=59)

        # Read private key from file
        with open(self.__rsa_key, 'rb') as pem_in:
            pemlines = pem_in.read()
            private_key = load_pem_private_key(pemlines, self.__rsa_key_password.encode('utf-8'), default_backend())

        # Generate the public key fingerprint for the issuer in the payload
       # public_key_fp = "SHA256:/X9zRVvcrsvU1W9zD4YB/21I61ZgeLBnK1NmyxSVsnc="
        public_key_fp = self.calculate_public_key_fingerprint(private_key)

        # Construct JWT payload
        payload = {
            "iss": qualified_username + '.' + public_key_fp,
            "sub": qualified_username,
            "iat": now,
            "exp": now + lifetime
        }

        # Generate the token
        encoding_algorithm = "RS256"
        token = jwt.encode(payload, key=private_key, algorithm=encoding_algorithm)

        # Convert token to string if it's in bytes
        if isinstance(token, bytes):
            token = token.decode('utf-8')

        return token
    
    def open_metric_log(self):
        rv = super().open_metric_log()
        if not rv:
            return rv

    def calculate_public_key_fingerprint(self, private_key):
        from cryptography.hazmat.primitives.serialization import Encoding, PublicFormat
        import  base64
        public_key_raw = private_key.public_key().public_bytes(Encoding.DER, PublicFormat.SubjectPublicKeyInfo)
        sha256hash = hashlib.sha256()
        sha256hash.update(public_key_raw)
        public_key_fp = 'SHA256:' + base64.b64encode(sha256hash.digest()).decode('utf-8')
        return public_key_fp

    def gather_sample(self):
        response = self.snowflake_connection()
        # Parse the JSON response
        data = json.loads(response)

        # Prepare key-value pairs
        kv_pairs = {}
        if 'data' in data:
            for i, column in enumerate(data['resultSetMetaData']['rowType']):
                column_name = column['name']
                if column_name not in kv_pairs:
                    kv_pairs[column_name] = data['data'][0][i]
        # Convert dictionary to JSON string
        kv_pairs_json = kv_pairs_json = json.dumps(kv_pairs, indent=None)
        scalyr_logging.MetricLogHandler.get_handler_for_path(self.log_config['path']).setFormatter(logging.Formatter('%(message)s'))
        self._logger.emit_value('Monitor', "Snowflake",
                        extra_fields=kv_pairs)