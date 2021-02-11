ARG python_version=3.7
FROM python:${python_version}-slim-buster
ENV CONFIG_VALUES=${CONFIG_VALUES}

# Install dev dependencies
RUN apt-get update -y
RUN apt-get install -y wget build-essential git vim

# Download requirements from scalyr-agent-2 repo
# We use dev-requirements so testing related tools are also available
RUN wget https://raw.githubusercontent.com/scalyr/scalyr-agent-2/master/dev-requirements.txt

# Install Python deps
RUN python3 -m venv /opt/venv && . /opt/venv/bin/activate && pip3 install -r dev-requirements.txt

# Clone scalyr agent repo and use that for development
RUN git clone https://github.com/scalyr/scalyr-agent-2.git

# Third party monitors are auto loaded from here
RUN mkdir -p /usr/share/scalyr-agent-2/py/monitors/

# Create symlink to root for easier development / inspection
RUN ln -s /monitors /usr/share/scalyr-agent-2/py/monitors/local
RUN mkdir /monitors

# Install agent into venv
# Workaround since pysnmp is not compatible with Python 3.7
RUN rm -rf /scalyr-agent-2/scalyr_agent/third_party/pysnmp/
RUN rm -rf /scalyr-agent-2/scalyr_agent/build/
RUN rm -rf /scalyr-agent-2/scalyr_agent/*egg*
RUN cd /scalyr-agent-2 ; /opt/venv/bin/python setup.py install

ENV PYTHONPATH "/opt/venv/lib/python3.7/site-packages/:${PYTHONPATH}"
ENV PATH "/opt/venv/bin/:${PATH}"

#RUN if [ -z "$CONFIG_VALUES" ] ; then echo Argument not provided ; else echo Argument is $arg ; fi
#RUN if [ -z "$CONFIG_VALUES" ] ; then export python3 -m scalyr_agent.run_monitor scalyr_agent.builtin_monitors.${testFile}  ; else python3 -m scalyr_agent.run_monitor -c ${CONFIG_VALUES} scalyr_agent.builtin_monitors.${testFile} ; fi
#RUN cd /opt/venv/lib/python3.7/site-packages/ && python3 -m scalyr_agent.run_monitor  scalyr_agent.builtin_monitors.${testFile}
