::: {.cell .code}
```python
# turn segment offload off
for port in chi.network.list_ports():
    if port['network_id'] in net_ids:
        i = server_ids.index(port['device_id'])
        j = net_ids.index(port['network_id'])
        for offload in ["gro", "gso", "tso"]:
            server_remotes[i].run( "sudo ethtool -K $(ip --br link | grep '" + port['mac_address'] + "' | awk '{print $1}') " + offload + " off" )
```
:::
