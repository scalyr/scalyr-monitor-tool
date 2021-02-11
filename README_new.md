# 1. Build the container with scalyr agent and all the deps
docker build . -t scalyr-monitor-dev

# 2. Run the container to test your monitor changes / develop the monitor

```bash
docker run -v $(pwd)/monitors:/monitors -it scalyr-monitor-dev /bin/bash
```

NOTE: It's important you use ``-v`` flag - this way local ``./monitors`` directory will be available to container and you will be able to test your changes live - you won't need to rebuild the container to test new version of the monitor.


### 1. Run built-in monitor

```bash
docker run -v $(pwd)/monitors:/monitors scalyr-monitor-dev python scalyr_agent.builtin_monitors.test_monitor -c '{"gauss_mean": 0.5}'
```

### 2. Run your custom monitor from monitors/ directory

```bash
docker run -v $(pwd)/monitors:/monitors scalyr-monitor-dev python -m scalyr_agent.run_monitor monitors.test_monitor -c '{"gauss_mean": 0.5}'
```
