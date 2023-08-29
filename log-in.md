
::: {.cell .markdown}

### Log in to resources

At this point, we should be able to log in to our resources over SSH! Run the following cell, and observe the output - you will see an SSH command for each of the nodes in your topology.

:::


::: {.cell .code}
```python
import pandas as pd
pd.set_option('display.max_colwidth', None)
slice_info = [{'Name': n['name'], 'SSH command': "ssh cc@" + server_ips[i] } for i, n in enumerate(node_conf)]
pd.DataFrame(slice_info).set_index('Name')
```
:::



::: {.cell .markdown}

Now, you can open an SSH session on any of the nodes as follows:

* In Jupyter, from the menu bar, use File > New > Terminal to open a new terminal.
* Copy an SSH command from the output above, and paste it into the terminal.
* You can repeat this process (open several terminals) to start a session on each node. Each terminal session will have a tab in the Jupyter environment, so that you can easily switch between them.

Alternatively, you can use your local terminal to log on to each node, if you prefer. (On your local terminal, you may need to also specify your key path as part of the SSH command, using the `-i` argument followed by the path to your private key.)

:::
     
