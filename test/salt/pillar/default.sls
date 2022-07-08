# -*- coding: utf-8 -*-
# vim: ft=yaml
---
conduit:
  lookup:
    master: template-master
    # Just for testing purposes
    winner: lookup
    added_in_lookup: lookup_value
    compose:
      create_pod: null
      pod_args: null
      project_name: conduit
      remove_orphans: true
      service:
        container_prefix: null
        ephemeral: true
        pod_prefix: null
        restart_policy: on-failure
        restart_sec: 2
        separator: null
        stop_timeout: null
    paths:
      base: /opt/containers/conduit
      compose: docker-compose.yml
      config_conduit: conduit.env
      config_element: element.env
      db: db
      element_config_js: element_config.js
    user:
      groups: []
      home: null
      name: conduit
      shell: /usr/sbin/nologin
      uid: null
      gid: null
    containers:
      conduit:
        image: docker.io/matrixconduit/matrix-conduit:latest
      element:
        image: docker.io/vectorim/element-web:latest
  install:
    rootless: true
    remove_all_data_for_sure: false
  config:
    address: 0.0.0.0
    allow_federation: true
    allow_registration: true
    database_backend: rocksdb
    database_path: /var/lib/matrix-conduit/
    log: info,rocket=off,_=off,sled=off
    max_concurrent_requests: 100
    max_request_size: 20000000
    port: 6167
    server_name: your.server.name
    trusted_servers:
      - matrix.org
  element:
    config:
      brand: Element
      bug_report_endpoint_url: https://element.io/bugreports/submit
      default_country_code: GB
      default_federate: true
      default_server_name: conduit
      default_theme: light
      disable_3pid_login: false
      disable_custom_urls: false
      disable_guests: false
      disable_login_language_selector: false
      enable_presence_by_hs_url:
        https://matrix-client.matrix.org: false
        https://matrix.org: false
      features: {}
      integrations_rest_url: https://scalar.vector.im/api
      integrations_ui_url: https://scalar.vector.im/
      integrations_widgets_urls:
        - https://scalar.vector.im/_matrix/integrations/v1
        - https://scalar.vector.im/api
        - https://scalar-staging.vector.im/_matrix/integrations/v1
        - https://scalar-staging.vector.im/api
        - https://scalar-staging.riot.im/scalar/api
      jitsi:
        preferred_domain: meet.element.io
      map_style_url: https://api.maptiler.com/maps/streets/style.json?key=fU3vlMsMn4Jb6dnEIFsx
      room_directory:
        servers:
          - matrix.org
          - gitter.im
          - libera.chat
      setting_defaults:
        breadcrumbs: true
      show_labs_settings: false
      uisi_autorageshake_app: element-auto-uisi
    enable: false
    host_port: 3737

  tofs:
    # The files_switch key serves as a selector for alternative
    # directories under the formula files directory. See TOFS pattern
    # doc for more info.
    # Note: Any value not evaluated by `config.get` will be used literally.
    # This can be used to set custom paths, as many levels deep as required.
    files_switch:
      - any/path/can/be/used/here
      - id
      - roles
      - osfinger
      - os
      - os_family
    # All aspects of path/file resolution are customisable using the options below.
    # This is unnecessary in most cases; there are sensible defaults.
    # Default path: salt://< path_prefix >/< dirs.files >/< dirs.default >
    #         I.e.: salt://conduit/files/default
    # path_prefix: template_alt
    # dirs:
    #   files: files_alt
    #   default: default_alt
    # The entries under `source_files` are prepended to the default source files
    # given for the state
    # source_files:
    #   conduit-config-file-file-managed:
    #     - 'example_alt.tmpl'
    #     - 'example_alt.tmpl.jinja'

    # For testing purposes
    source_files:
      Conduit Matrix Homeserver environment file is managed:
      - conduit.env.j2

  # Just for testing purposes
  winner: pillar
  added_in_pillar: pillar_value
