# vim: ft=sls

{#-
    Removes the conduit, element containers
    and the corresponding user account and service units.
    Has a depency on `conduit.config.clean`_.
    If ``remove_all_data_for_sure`` was set, also removes all data.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as conduit with context %}

include:
  - {{ sls_config_clean }}

{%- if conduit.install.autoupdate_service %}

Podman autoupdate service is disabled for Conduit Matrix Homeserver:
{%-   if conduit.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ conduit.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

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

{%- if conduit.install.podman_api %}

Conduit Matrix Homeserver podman API is unavailable:
  compose.systemd_service_dead:
    - name: podman.socket
    - user: {{ conduit.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ conduit.lookup.user.name }}

Conduit Matrix Homeserver podman API is disabled:
  compose.systemd_service_disabled:
    - name: podman.socket
    - user: {{ conduit.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ conduit.lookup.user.name }}
{%- endif %}

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
