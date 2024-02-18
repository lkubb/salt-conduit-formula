# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as conduit with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

Conduit Matrix Homeserver user account is present:
  user.present:
{%- for param, val in conduit.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ conduit.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false
  file.append:
    - names:
      - {{ conduit.lookup.user.home | path_join(".bashrc") }}:
        - text:
          - export XDG_RUNTIME_DIR=/run/user/$(id -u)
          - export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

      - {{ conduit.lookup.user.home | path_join(".bash_profile") }}:
        - text: |
            if [ -f ~/.bashrc ]; then
              . ~/.bashrc
            fi

    - require:
      - user: {{ conduit.lookup.user.name }}

Conduit Matrix Homeserver user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ conduit.lookup.user.name }}
    - enable: {{ conduit.install.rootless }}
    - require:
      - user: {{ conduit.lookup.user.name }}

Conduit Matrix Homeserver paths are present:
  file.directory:
    - names:
      - {{ conduit.lookup.paths.base }}
      - {{ conduit.lookup.paths.db }}:
        - unless:
          - fun: file.directory_exists
            path: {{ conduit.lookup.paths.db }}
    - user: {{ conduit.lookup.user.name }}
    - group: {{ conduit.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ conduit.lookup.user.name }}

# The container image currently assumes uid 1000 runs it
# and does not consider rootless mode.
Conduit database directory has the correct owner:
  cmd.run:
    - name: podman unshare chown -R 1000:1000 {{ conduit.lookup.paths.db }}
    - onchanges:
      - file: {{ conduit.lookup.paths.db }}
{%- if conduit.install.rootless %}
    - runas: {{ conduit.lookup.user.name }}
{%- endif %}

{%- if conduit.install.podman_api %}

Conduit Matrix Homeserver podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman.socket
    - user: {{ conduit.lookup.user.name }}
    - require:
      - Conduit Matrix Homeserver user session is initialized at boot

Conduit Matrix Homeserver podman API is available:
  compose.systemd_service_running:
    - name: podman.socket
    - user: {{ conduit.lookup.user.name }}
    - require:
      - Conduit Matrix Homeserver user session is initialized at boot
{%- endif %}

Conduit Matrix Homeserver compose file is managed:
  file.managed:
    - name: {{ conduit.lookup.paths.compose }}
    - source: {{ files_switch(
                    ["docker-compose.yml", "docker-compose.yml.j2"],
                    config=conduit,
                    lookup="Conduit Matrix Homeserver compose file is present",
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ conduit.lookup.rootgroup }}
    - makedirs: true
    - template: jinja
    - makedirs: true
    - context:
        conduit: {{ conduit | json }}

Conduit Matrix Homeserver is installed:
  compose.installed:
    - name: {{ conduit.lookup.paths.compose }}
{%- for param, val in conduit.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- for param, val in conduit.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ conduit.lookup.paths.compose }}
{%- if conduit.install.rootless %}
    - user: {{ conduit.lookup.user.name }}
    - require:
      - user: {{ conduit.lookup.user.name }}
{%- endif %}

{%- if conduit.install.autoupdate_service is not none %}

Podman autoupdate service is managed for Conduit Matrix Homeserver:
{%-   if conduit.install.rootless %}
  compose.systemd_service_{{ "enabled" if conduit.install.autoupdate_service else "disabled" }}:
    - user: {{ conduit.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if conduit.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
