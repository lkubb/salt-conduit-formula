# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as conduit with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Conduit Matrix Homeserver environment files are managed:
  file.managed:
    - names:
      - {{ conduit.lookup.paths.config_conduit }}:
        - source: {{ files_switch(
                        ["conduit.env", "conduit.env.j2"],
                        config=conduit,
                        lookup="conduit environment file is managed",
                        indent_width=10,
                     )
                  }}
{%- if conduit.element.enable %}
      - {{ conduit.lookup.paths.config_element }}:
        - source: {{ files_switch(
                        ["element.env", "element.env.j2"],
                        config=conduit,
                        lookup="element environment file is managed",
                        indent_width=10,
                     )
                  }}
{%- endif %}
    - mode: '0640'
    - user: root
    - group: {{ conduit.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ conduit.lookup.user.name }}
    - require_in:
      - Conduit Matrix Homeserver is installed
    - context:
        conduit: {{ conduit | json }}

{%- if conduit.element.enable %}

Element config file is managed:
  file.serialize:
    - name: {{ conduit.lookup.paths.element_config_js }}
    - serializer: json
    - mode: '0644'
    - user: root
    - group: {{ conduit.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ conduit.lookup.user.name }}
    - dataset: {{ conduit.element.config | json }}
{%- endif %}
