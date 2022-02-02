ARG PYTHON_VERSION=3.8

FROM python:${PYTHON_VERSION}-slim-buster

ARG AGENT_VERSION=master

# Install dev dependencies
RUN apt-get update -y
RUN apt-get install -y wget build-essential git vim

# Clone scalyr agent repo and use that for development
RUN git clone https://github.com/scalyr/scalyr-agent-2.git
RUN cd scalyr-agent-2 ; git checkout ${AGENT_VERSION}

# Create virtualenv Install Python deps
RUN python3 -m venv /opt/venv && . /opt/venv/bin/activate && cd scalyr-agent-2 && pip3 install -r dev-requirements.txt

# Install agent into venv
# Workaround since pysnmp is not compatible with Python 3.7
RUN rm -rf /scalyr-agent-2/scalyr_agent/third_party/pysnmp/
RUN rm -rf /scalyr-agent-2/scalyr_agent/build/
RUN rm -rf /scalyr-agent-2/scalyr_agent/*egg*
RUN cd /scalyr-agent-2 ; /opt/venv/bin/python setup.py install

# Third party monitors are auto loaded from here
RUN mkdir -p /usr/share/scalyr-agent-2/py/monitors/

# Create symlink to root for easier development / inspection
RUN ln -s /monitors /usr/share/scalyr-agent-2/py/monitors/local
RUN mkdir /monitors

# Set pythonpath and path so correct python command is used out of the box
ENV PYTHONPATH "/opt/venv/lib/python3.7/site-packages/:${PYTHONPATH}"
ENV PATH "/opt/venv/bin/:${PATH}"
