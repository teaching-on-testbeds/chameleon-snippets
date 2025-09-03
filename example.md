::: {.cell .markdown}
### Define configuration for this experiment (example)
:::

::: {.cell .code}
```python
username = os.getenv('USER')

node_conf = [
 {'name': "romeo",   'flavor': 'm1.small', 'image': 'CC-Ubuntu24.04', 'duration': 6, 'packages': ['mtr']}, 
 {'name': "juliet",  'flavor': 'm1.small', 'image': 'CC-Ubuntu24.04', 'duration': 6, 'packages': []}, 
 {'name': "hamlet",  'flavor': 'm1.small', 'image': 'CC-Ubuntu24.04', 'duration': 6, 'packages': []}, 
 {'name': "ophelia", 'flavor': 'm1.small', 'image': 'CC-Ubuntu24.04', 'duration': 6, 'packages': []}, 
 {'name': "router",  'flavor': 'm1.small', 'image': 'CC-Ubuntu24.04', 'duration': 6, 'packages': []}
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
:::
