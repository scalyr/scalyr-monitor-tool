# Scalyr Monitors Development and Test Setup

This repository contains information on how to build a Docker image and container which can be
used to develop Scalyr Monitors.

Only dependency for it is Docker.

## Usage

### 1. Build the Docker image with Scalyr Agent and Other Dependencies

```bash
docker build . -t scalyr-monitor-dev
```

### 2. Run the container to develop and test your monitor

Make changes to your monitor code in ``./monitors/your_monitor_name_monitor.py`` file and once
you want to test them, run the command below.

```bash
docker run -v $(pwd)/monitors:/monitors scalyr-monitor-dev python -m scalyr_agent.run_monitor monitors.your_monitor_name_monitor -c '{"gauss_mean": 0.5}'
```

NOTE: It's important you use ``-v`` flag. This way local ``./monitors`` directory will be
available to container and you will be able to test your changes live - you won't need to
rebuild the container image to test any changes you made to the monitor file

As an alternative, you can start a container with a shell and then run that command in the
shell directly.

```bash
docker run -v $(pwd)/monitors:/monitors -it scalyr-monitor-dev /bin/bash
python -m scalyr_agent.run_monitor monitors.your_monitor_name_monitor -c '{"gauss_mean": 0.5}'
```

If you want to run a built-in monitor, you can use this command:

```bash
docker run -v $(pwd)/monitors:/monitors scalyr-monitor-dev python -m scalyr_agent.run_monitor scalyr_agent.builtin_monitors.test_monitor -c '{"gauss_mean": 0.5}'
```

## Using Development Monitor in Live Environment

1. [Install Scalyr Agent](https://app.scalyr.com/help/install-agent-linux-quick-start-2)

2. Copy the plugin you tested to `/usr/share/scalyr-agent-2/py/monitors/local`

3. Add a config for the plugin in the agent config 

```sudo vim /etc/scalyr-agent-2/agent.d/monitors.json```


```
{
   monitors: [ {
       module: "ip_monitor",
       gauss_mean: 0.5, #param from above
       other_params: value
   }]
}
```
