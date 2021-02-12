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

## Testing a Parser

When logs eventually get to scalyr, they need to be parsed. You can test this in your account with the entire ingestion pipeline easily by adding the Docker Agent:

##### 1. Build the Docker image with Scalyr Agent and Other Dependencies

```bash
docker pull scalyr/scalyr-agent-docker-json
```

##### 2. Build the Docker image with Scalyr Agent and Other Dependencies


```bash 
docker run -d --name scalyr-docker-agent \
-e SCALYR_API_KEY=<Your API key> \
-v /var/run/docker.sock:/var/scalyr/docker.sock \
-v /var/lib/docker/containers:/var/lib/docker/containers \
scalyr/scalyr-agent-docker-json
```

##### 3. Build parser
Edit the parser. By default it is the [docker parser](https://app.scalyr.com/parser?parser=docker). View a full list [here](https://app.scalyr.com/parsers)


##### 4. Run Monitor
Add a label to change the parser to something other than `docker`

```bash
docker run -l com.scalyr.config.log.attributes.parser=docker -v $(pwd)/monitors:/monitors scalyr-monitor-dev python -m scalyr_agent.run_monitor monitors.your_monitor_name_monitor -c '{"gauss_mean": 0.5}'
```
##### 5. See logs in Scalyr
You can see the logs by searching `serverHost = "container_id" && logfile contains "container_name"` or searching [by the parser](https://app.scalyr.com/events?filter=parser%3D%27docker%27) 

