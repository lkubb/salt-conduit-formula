# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_file = tplroot ~ '.config.file' %}
{%- from tplroot ~ "/map.jinja" import mapdata as conduit with context %}

include:
  - {{ sls_config_file }}

Conduit Matrix Homeserver service is enabled:
  compose.enabled:
    - name: {{ conduit.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if conduit.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ conduit.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - Conduit Matrix Homeserver is installed
{%- if conduit.install.rootless %}
    - user: {{ conduit.lookup.user.name }}
{%- endif %}

Conduit Matrix Homeserver service is running:
  compose.running:
    - name: {{ conduit.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if conduit.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ conduit.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if conduit.install.rootless %}
    - user: {{ conduit.lookup.user.name }}
{%- endif %}
    - watch:
      - Conduit Matrix Homeserver is installed
