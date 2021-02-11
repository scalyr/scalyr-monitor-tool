FROM python:3.7-slim-buster
ARG testFile
ARG CONFIG_VALUES
ENV TESTFILE=${testFile}
COPY ./monitors /tmp
ENV CONFIG_VALUES=${CONFIG_VALUES}
# Install dependencies:
COPY requirements.txt .
#RUN apt-get update && apt-get install sudo -y
RUN python3 -m venv /opt/venv && . /opt/venv/bin/activate && pip3 install -r requirements.txt && pip3 install scalyr-agent-2 && ls /tmp/ && ls /opt/venv/lib/python3.7/site-packages/scalyr_agent/builtin_monitors/ && mv /tmp/${testFile}.py /opt/venv/lib/python3.7/site-packages/scalyr_agent/builtin_monitors/${testFile}.py && cd /opt/venv/lib/python3.7/site-packages/ && python3 -m scalyr_agent.run_monitor -c "$(echo $CONFIG_VALUES)" scalyr_agent.builtin_monitors.${testFile}
#RUN cd /opt/venv/lib/python3.7/site-packages/ && python3 -m scalyr_agent.run_monitor  scalyr_agent.builtin_monitors.${testFile}
