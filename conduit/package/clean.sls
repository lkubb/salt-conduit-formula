# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as conduit with context %}

include:
  - {{ sls_config_clean }}

Conduit Matrix Homeserver is absent:
  compose.removed:
    - name: {{ conduit.lookup.paths.compose }}
    - volumes: {{ conduit.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if conduit.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ conduit.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if conduit.install.rootless %}
    - user: {{ conduit.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

Conduit Matrix Homeserver compose file is absent:
  file.absent:
    - name: {{ conduit.lookup.paths.compose }}
    - require:
      - Conduit Matrix Homeserver is absent

Conduit Matrix Homeserver user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ conduit.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ conduit.lookup.user.name }}

Conduit Matrix Homeserver user account is absent:
  user.absent:
    - name: {{ conduit.lookup.user.name }}
    - purge: {{ conduit.install.remove_all_data_for_sure }}
    - require:
      - Conduit Matrix Homeserver is absent
    - retry:
        attempts: 5
        interval: 2

{%- if conduit.install.remove_all_data_for_sure %}

Conduit Matrix Homeserver paths are absent:
  file.absent:
    - names:
      - {{ conduit.lookup.paths.base }}
    - require:
      - Conduit Matrix Homeserver is absent
{%- endif %}
