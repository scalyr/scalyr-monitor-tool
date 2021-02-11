***Get Started***

This will build the testing environment in python to test monitors. 


***To Test Plugin***
1. Clone URL 
``git clone URL``
2. Declare you agent plugin or test one in the `/monitors' folder (omit the .py extension)
```EXPORT plugin=test_monitor```
3. Declare your parameters as a string
```Export params="{ gauss_mean: 0.5 }"```
4. Build docker container and pass args

```
sudo docker build \
--build-arg testFile=$plugin \
--build-arg CONFIG_VALUES="$params" \
.
```

You should see the output of the plugin stream to stdout

```
2021-02-11 04:26:18.497Z [ip_monitor()] response "{\n  \"ip_addr\": \"24.23.157.7\",\n  \"remote_host\": \"unavailable\",\n  \"user_agent\": \"scalyr-agent-2.1.18;monitor=ip_monitor\",\n  \"port\": 35786,\n  \"method\": \"GET\",\n  \"encoding\": \"identity\",\n  \"via\": \"1.1 google\",\n  \"forwarded\": \"24.23.157.7, 216.239.32.21\"\n}" length=250 request_method="GET" server="https://ifconfig.me/all.json" status=200
2021-02-11 04:26:23.677Z [ip_monitor()] response "{\n  \"ip_addr\": \"24.23.157.7\",\n  \"remote_host\": \"unavailable\",\n  \"user_agent\": \"scalyr-agent-2.1.18;monitor=ip_monitor\",\n  \"port\": 22644,\n  \"method\": \"GET\",\n  \"encoding\": \"identity\",\n  \"via\": \"1.1 google\",\n  \"forwarded\": \"24.23.157.7, 216.239.32.21\"\n}" length=250 request_method="GET" server="https://ifconfig.me/all.json" status=200
```

***To add to live environment***

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
