# vim: ft=sls


{#-
    Stops the conduit, element container services
    and disables them at boot time.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as conduit with context %}

conduit service is dead:
  compose.dead:
    - name: {{ conduit.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if conduit.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ conduit.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if conduit.install.rootless %}
    - user: {{ conduit.lookup.user.name }}
{%- endif %}

conduit service is disabled:
  compose.disabled:
    - name: {{ conduit.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if conduit.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ conduit.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if conduit.install.rootless %}
    - user: {{ conduit.lookup.user.name }}
{%- endif %}
