
::: {.cell .markdown}
### Configure environment
:::

::: {.cell .code}
```python
import chi, os, time, datetime
from chi import lease
from chi import server
from chi import context
from chi import hardware
from chi import network
from chi import ssh
```
:::


::: {.cell .markdown}
In this section, we configure the Chameleon Python client. 

For this experiment, we’re going to use the KVM@TACC site, which we indicate below. 

We also need to specify the name of the Chameleon "project" that this experiment is part of. The project name will have the format “CHI-XXXXXX”, where the last part is a 6-digit number, and you can find it on your [user dashboard](https://chameleoncloud.org/user/dashboard/).
:::


::: {.cell .markdown}
In the cell below, select the correct project ID, then run the cell.

:::



::: {.cell .code}
```python
context.version = "1.0" 
context.choose_project()
context.choose_site(default="KVM@TACC")
username = os.getenv('USER') # all exp resources will have this suffix

# configure openstacksdk for actions unsupported by python-chi
os_conn = chi.clients.connection()

```
:::
