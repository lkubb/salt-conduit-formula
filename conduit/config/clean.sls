# vim: ft=sls

{#-
    Removes the configuration of the conduit, element containers
    and has a dependency on `conduit.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as conduit with context %}

include:
  - {{ sls_service_clean }}

Conduit Matrix Homeserver environment files are absent:
  file.absent:
    - names:
      - {{ conduit.lookup.paths.config_conduit }}
{%- if conduit.element.enable %}
      - {{ conduit.lookup.paths.config_element }}
      - {{ conduit.lookup.paths.element_config_js }}
{%- endif %}
    - require:
      - sls: {{ sls_service_clean }}
