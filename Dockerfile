FROM python:3.7-slim-buster
ARG testFile
ARG CONFIG_VALUES
ENV TESTFILE=${testFile}
COPY ./monitors /tmp
ENV CONFIG_VALUES=${CONFIG_VALUES}
# Install dependencies:
COPY requirements.txt .
#RUN if [ -z "$CONFIG_VALUES" ] ; then echo Argument not provided ; else echo Argument is $arg ; fi
#RUN if [ -z "$CONFIG_VALUES" ] ; then export python3 -m scalyr_agent.run_monitor scalyr_agent.builtin_monitors.${testFile}  ; else python3 -m scalyr_agent.run_monitor -c ${CONFIG_VALUES} scalyr_agent.builtin_monitors.${testFile} ; fi
RUN  python3 -m venv /opt/venv && . /opt/venv/bin/activate && pip3 install -r requirements.txt && pip3 install scalyr-agent-2 && ls /tmp/ && ls /opt/venv/lib/python3.7/site-packages/scalyr_agent/builtin_monitors/ && mv /tmp/${testFile}.py /opt/venv/lib/python3.7/site-packages/scalyr_agent/builtin_monitors/${testFile}.py && cd /opt/venv/lib/python3.7/site-packages/ && if [ -z "$CONFIG_VALUES" ] ; then python3 -m scalyr_agent.run_monitor scalyr_agent.builtin_monitors.${testFile}  ; else python3 -m scalyr_agent.run_monitor -c "$(echo $CONFIG_VALUES)" scalyr_agent.builtin_monitors.${testFile} ; fi
#RUN cd /opt/venv/lib/python3.7/site-packages/ && python3 -m scalyr_agent.run_monitor  scalyr_agent.builtin_monitors.${testFile}
