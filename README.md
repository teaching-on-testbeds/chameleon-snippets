# Snippets for building a network topology

This repository collects snippets that are commonly used across Chameleon notebooks for building a network topology.


For example, an experiment might:

* Configure the Chameleon Jupyter environment (`chi-config.md`)
* Define the slice name and the experiment configuration (experiment specific, an example showing the format is given in `example.md`)
* Configure the resources: create VMs and networks, configure access to them, add IPv4 addresses to experiment interfaces, add static routes, set up hosts files, enable IPv4 forwarding, install packages (`configure-resources.md`)
* Turn off segment offload (this is useful for educational experiments where we care about frame sizes) (`offload-off.md`)
* Execute the experiment (experiment specific, not in this repository)
* Delete the resources in the experiment (`delete-slice.md`)

Also in this repository, there is an example of a `Makefile` that generates a complete Python notebook for Chameleon using these snippets (with an example experiment configuration that is defined in the Makefile).
### Defining the experiment configuration

These snippets assume the experiment configuration is defined near the top of the notebook, including `node_conf`, `net_conf`, and `route_conf` as in the following example:

```python
node_conf = [
 {'name': "romeo",   'flavor': 'm1.small', 'image': 'CC-Ubuntu20.04', 'packages': ['mtr']}, 
 {'name': "juliet",  'flavor': 'm1.small', 'image': 'CC-Ubuntu20.04', 'packages': []}, 
 {'name': "hamlet",  'flavor': 'm1.small', 'image': 'CC-Ubuntu20.04', 'packages': []}, 
 {'name': "ophelia", 'flavor': 'm1.small', 'image': 'CC-Ubuntu20.04','packages': []}, 
 {'name': "router",  'flavor': 'm1.small', 'image': 'CC-Ubuntu20.04', 'packages': []}
]
net_conf = [
 {"name": "net0", "subnet": "10.0.0.0/24", "nodes": [{"name": "romeo",   "addr": "10.0.0.100"}, {"name": "juliet", "addr": None}, {"name": "router", "addr": "10.0.0.10"}]},
 {"name": "net1", "subnet": "10.0.1.0/24", "nodes": [{"name": "hamlet",   "addr": "10.0.1.100"}, {"name": "ophelia", "addr": "10.0.1.101"}, {"name": "router", "addr": "10.0.1.10"}]},
]
route_conf = [
 {"addr": "10.0.1.0/24", "gw": "10.0.0.10", "nodes": ["romeo"]}, 
 {"addr": "10.0.0.0/24", "gw": "10.0.1.10", "nodes": ["hamlet", "ophelia"]}
]
```