
::: {.cell .markdown}
### Configure environment
:::

::: {.cell .code}
```python
import openstack, chi, chi.ssh, os    
```
:::


::: {.cell .markdown}
In this section, we configure the Chameleon Python client. 

For this experiment, we’re going to use the KVM@TACC site, which we indicate below. 

We also need to specify the name of the Chameleon "project" that this experiment is part of. The project name will have the format “CHI-XXXXXX”, where the last part is a 6-digit number, and you can find it on your [user dashboard](https://chameleoncloud.org/user/dashboard/).
:::


::: {.cell .markdown}
In the cell below, replace the project ID with your own project ID, then run the cell.

:::



::: {.cell .code}
```python
chi.use_site("KVM@TACC")
PROJECT_NAME = "CHI-XXXXXX"
chi.set("project_name", PROJECT_NAME)

# configure openstacksdk for actions unsupported by python-chi
os_conn = chi.clients.connection()

```
:::
