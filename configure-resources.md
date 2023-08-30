::: {.cell .markdown}
### Configure resources

Now, we will prepare the VMs and network links that our experiment requires.
:::

::: {.cell .markdown}
First, we will prepare a "public" network that we will use for SSH access to our VMs - 
:::


::: {.cell .code}
```python
public_net = os_conn.network.create_network(name="public_net_" + username)
public_net_id = public_net.get("id")
public_subnet = os_conn.network.create_subnet(
    name="public_subnet_" + username,
    network_id=public_net.get("id"),
    ip_version='4',
    cidr="192.168.10.0/24",
    gateway_ip="192.168.10.1",
    is_dhcp_enabled = True
)
```
:::

::: {.cell .markdown}
Next, we will prepare the "experiment" networks - 
:::

::: {.cell .code}
```python
nets = []
net_ids = []
subnets = []
for n in net_conf:
    exp_net = os_conn.network.create_network(name="exp_" + n['name']  + '_' + username)
    exp_net_id = exp_net.get("id")
    os_conn.network.update_network(exp_net, is_port_security_enabled=False)
    exp_subnet = os_conn.network.create_subnet(
        name="exp_subnet_" + n['name']  + '_' + username,
        network_id=exp_net.get("id"),
        ip_version='4',
        cidr=n['subnet'],
        gateway_ip=None,
        is_dhcp_enabled = False
    )
    nets.append(exp_net)
    net_ids.append(exp_net_id)
    subnets.append(exp_subnet)
```
:::

::: {.cell .markdown}
Now we create the VMs -
:::


::: {.cell .code}
```python
servers = []
server_ids = []
for i, n in enumerate(node_conf, start=10):
    image_uuid = os_conn.image.find_image(n['image']).id
    flavor_uuid = os_conn.compute.find_flavor(n['flavor']).id
    # find out details of exp interface(s)
    nics = [{'net-id': chi.network.get_network_id( "exp_" + net['name']  + '_' + username ), 'v4-fixed-ip': node['addr']} for net in net_conf for node in net['nodes'] if node['name']==n['name']]
    # also include a public network interface
    nics.insert(0, {"net-id": public_net_id, "v4-fixed-ip":"192.168.10." + str(i)})
    server = chi.server.create_server(
        server_name=n['name'] + "_" + username,
        image_id=image_uuid,
        flavor_id=flavor_uuid,
        nics=nics
    )
    servers.append(server)
    server_ids.append(chi.server.get_server(n['name'] + "_" + username).id)
```
:::


::: {.cell .markdown}
We wait for all servers to come up before we proceed -
:::

::: {.cell .code}
```python
for server_id in server_ids:
    chi.server.wait_for_active(server_id)
```
:::


::: {.cell .markdown}
Next, we will set up SSH access to the VMs.

First, we will make sure the "public" network is connected to the Internet. Then, we will configure it to permit SSH access on port 22 for each port connected to this network.
:::


::: {.cell .code}
```python
# connect them to the Internet on the "public" network (e.g. for software installation)
router = chi.network.create_router('inet_router_' + username, gw_network_name='public')
chi.network.add_subnet_to_router(router.get("id"), public_subnet.get("id"))
```
:::

::: {.cell .code}
```python
# prepare SSH access on the servers
# WARNING: this relies on undocumented behavior of associate_floating_ip 
# that it associates the IP with the first port on the server
server_ips = []
for server_id in server_ids:
    ip = chi.server.associate_floating_ip(server_id)
    server_ips.append(ip)
```
:::

::: {.cell .markdown}
Note: The following cells assumes that a security group named “Allow SSH” already exists in your project, and is configured to allow SSH access on port 22. If you have done the “Hello, Chameleon” experiment then you already have this security group.
:::


::: {.cell .code}
```python
security_group_id = os_conn.get_security_group("Allow SSH").id
for port in chi.network.list_ports(): 
    if port['port_security_enabled'] and port['network_id']==public_net.get("id"):
        os_conn.network.update_port(port['id'], security_groups=[security_group_id])
```
:::


::: {.cell .markdown}
We also copy our account keys to all of the servers - 
:::


::: {.cell .code}
```python
for ip in server_ips:
    chi.server.wait_for_tcp(ip, port=22)
```
:::


::: {.cell .code}
```python
server_remotes = [chi.ssh.Remote(ip) for ip in server_ips]
```
:::


::: {.cell .code}
```python
nova=chi.clients.nova()
# iterate over all keypairs in this account
for kp in nova.keypairs.list(): 
    public_key = nova.keypairs.get(kp.name).public_key 
    for remote in server_remotes:
        remote.run(f"echo {public_key} >> ~/.ssh/authorized_keys")     
```
:::

::: {.cell .markdown}

Finally, we need to configure our resources, including software package installation and network configuration.

:::

::: {.cell .code}
```python
# configure an IP address on each port that is supposed to have one
for port in chi.network.list_ports():
    if port['network_id'] in net_ids:
        i = server_ids.index(port['device_id'])
        j = net_ids.index(port['network_id'])
        port_conf =  [item for item in net_conf[j]['nodes'] if item['name'] == node_conf[i]['name'] ][0]
        if port_conf['addr']:
            server_remotes[i].run( "sudo ip addr flush dev $(ip --br link | grep '" + port['mac_address'] + "' | awk '{print $1}')" )
            cmd_prefix = "sudo ip addr add " + port_conf['addr'] + "/" + net_conf[j]['subnet'].split("/")[1] 
            server_remotes[i].run( cmd_prefix + " dev $(ip --br link | grep '" + port['mac_address'] + "' | awk '{print $1}')" )
        else:
            server_remotes[i].run( "sudo ip addr flush dev $(ip --br link | grep '" + port['mac_address'] + "' | awk '{print $1}')" )
```
:::

::: {.cell .code}
```python
for i, n in enumerate(node_conf):
    remote = server_remotes[i]
    # enable forwarding
    remote.run(f"sudo sysctl -w net.ipv4.ip_forward=1") 
    remote.run(f"sudo ufw disable") 
    # configure static routes
    for r in route_conf: 
        if n['name'] in r['nodes']:
            remote.run(f"sudo ip route add " + r['addr'] + " via " + r['gw']) 
```
:::

::: {.cell .code}
```python
for i, n in enumerate(node_conf):
    # install packages
    if len(n['packages']):
            remote.run(f"sudo apt update; sudo apt -y install " + " ".join(n['packages'])) 
```
:::

::: {.cell .code}
```python
# prepare a "hosts" file that has names and addresses of every node
hosts_txt = [ "%s\t%s" % ( n['addr'], n['name'] ) for net in net_conf  for n in net['nodes'] if type(n) is dict and n['addr']]
for remote in server_remotes:
    for h in hosts_txt:
        remote.run("echo %s | sudo tee -a /etc/hosts > /dev/null" % h)
```
:::
