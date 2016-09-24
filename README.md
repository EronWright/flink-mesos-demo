# flink-mesos-demo

Demonstrates how to experiment with Flink-on-Mesos (WIP).

A Flink cluster consists of a JobManager (often called the AppMaster process) plus some number of TaskManagers (TM).
The snapshot build of Flink contains a new Mesos-specific AppMaster capable of registering as a Mesos framework and
launching TMs as Mesos tasks.    The AppMaster is designed to run in Mesos too, as a task of a not-yet-available component 
called the dispatcher.

To demonstrate the available functionality, this repository builds a simple Docker image capable of launching the AppMaster.
Feel free to launch a Docker container manually, or as a Marathon/Aurora application.

## Quick-Start

### Configure Flink
Edit the Flink configuration in the `conf` directory. In addition to the standard settings, the following 
Mesos-specific settings may be configured:

| Key            | Description |
|----------------|-------------|
| `mesos.master`   | The connection string for Mesos, as an ip:port pair, or as `zk://server:2181/mesos`. |
| `mesos.failover-timeout` | The number of seconds that Mesos will allow for failover of the AppMaster. | 
| `mesos.resourcemanager.framework.role` | The Mesos framework role. |
| `mesos.resourcemanager.framework.principal` | The Mesos framework principal. |
| `mesos.resourcemanager.framework.secret` | The Mesos framework secret. |


### Build the docker image
```
$ cd <repo>
$ docker build -t eronwright/flink-mesos-demo:latest .
```
 
### Start the AppMaster
```
$ docker run -itd --net=host eronwright/flink-mesos-demo:latest
```

### Open the Web UI
Browse to `http://<appmaster host>:8081/`


## Notes

### Customization

The Dockerfile defines certain environent variables which may be customized.  Note that in the final user experience,
such information is provided as CLI parameters to such commands as `mesos-session.sh` and `flink run`.

| Variable | Description |
|----------|------------|
| `_CLIENT_TM_COUNT` | Sets the number of TaskManagers to allocate.  |
| `_CLIENT_TM_MEMORY` | Sets the amount of memory to allocate for each TM. |
| `_SLOTS` | Sets the number of Flink task slots to advertize. |
| `_CLIENT_USERNAME` | The username for Mesos task and for Hadoop purposes. |

### High Availability
The AppMaster uses ZooKeeper (if configured) to support high-availability.    Upon an AppMaster crash,
the replacement AppMaster (as provided by Marathon/Aurora here, and later the dispatcher) reconnects to
any still-running TaskManagers.

Be sure to set the `high-availability.zookeeper.path.namespace` setting to a
unique value for each Flink cluster.
