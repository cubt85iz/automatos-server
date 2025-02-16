# TODO

- Refactor configuration files to allow for component customization for more complex containers. For example, user may want to install nextcloud without external CODE server or home-assistant without MQTT.
  - Ideas
    - Redesign config spec to allow for specification of components.

      ```jsonc
      # Use the current syntax, but revise opinionated implementation. User must specify every container they wish to run.
      # Don't package a group of containers together in install.sh, but automatically handle inclusion of network files.
      # Switch to `Wants=` instead of `Requires=` for container definitions.
      "containers":[
        "audiobookshelf"
        "nextcloud",
        "nextcloud-fts"
        "homeassistant"
      ]
      ```
