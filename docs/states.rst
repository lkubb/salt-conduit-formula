Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``conduit``
^^^^^^^^^^^
*Meta-state*.

This installs the conduit, element containers,
manages their configuration and starts their services.


``conduit.package``
^^^^^^^^^^^^^^^^^^^
Installs the conduit, element containers only.
This includes creating systemd service units.


``conduit.config``
^^^^^^^^^^^^^^^^^^
Manages the configuration of the conduit, element containers.
Has a dependency on `conduit.package`_.


``conduit.service``
^^^^^^^^^^^^^^^^^^^
Starts the conduit, element container services
and enables them at boot time.
Has a dependency on `conduit.config`_.


``conduit.clean``
^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``conduit`` meta-state
in reverse order, i.e. stops the conduit, element services,
removes their configuration and then removes their containers.


``conduit.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the conduit, element containers
and the corresponding user account and service units.
Has a depency on `conduit.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``conduit.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the conduit, element containers
and has a dependency on `conduit.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``conduit.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the conduit, element container services
and disables them at boot time.


