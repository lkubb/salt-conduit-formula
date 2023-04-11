# vim: ft=sls

{#-
    Starts the conduit, element container services
    and enables them at boot time.
    Has a dependency on `conduit.config`_.
#}

include:
  - .running
