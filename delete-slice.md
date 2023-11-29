::: {.cell .markdown}

### Delete resources

When you finish your experiment, you should delete your resources! The following cells deletes all the resources in this experiment, freeing them for other experimenters.

:::


::: {.cell .code}
```python
# delete the nodes
server_ids = [chi.server.get_server_id(n['name'] + "_" + username) for n in node_conf]
for server_id in server_ids:
    chi.server.delete_server(server_id)
```
:::


::: {.cell .code}
```python
# release the floating IP addresses used for SSH
for server_ip in server_ips:
    ip_details = chi.network.get_floating_ip(server_ip)
    chi.neutron().delete_floatingip(ip_details["id"])
```
:::

::: {.cell .code}
```python
# delete the router used for public Internet access
router = chi.network.get_router("inet_router_" + username)
public_subnet = chi.network.get_subnet("public_subnet_" + username)
public_net = chi.network.get_network("public_net_" + username)
chi.network.remove_subnet_from_router(router.get("id"), public_subnet.get("id"))
chi.network.delete_router(router.get("id"))
```
:::


::: {.cell .code}
```python
# delete the public network
chi.network.delete_subnet(public_subnet.get('id'))
chi.network.delete_network(public_net.get("id"))
```
:::


::: {.cell .code}
```python
# delete the experiment networks
subnets = [chi.network.get_subnet("exp_subnet_" + n['name']  + '_' + username) for n in net_conf]
nets    = [chi.network.get_network("exp_" + n['name']  + '_' + username) for n in net_conf]
for subnet, net in zip(subnets, nets):
    chi.network.delete_subnet(subnet.get('id'))
    chi.network.delete_network(net.get('id'))
```
:::

