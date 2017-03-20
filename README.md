## March

### Getting Started

1. Clone this repository to a working directory.
2. Copy the directory /.march to your home directory.
3. Execute the command ```vagrant up``` in the repository directory.
4. Execute the command ```vagrant ssh``` in the repository directory.

### Included Configuration

- Mosquitto Server (MQTT & Websocket Support)
- Mosquitto Client
  - [mosquitto_sub](https://mosquitto.org/man/mosquitto_sub-1.html) - e.g. ```mosquitto_sub -h localhost -t "my_topic" -v```
  - [mosquitto_pub](https://mosquitto.org/man/mosquitto_pub-1.html) - e.g. ```mosquitto_pub -h localhost -t "my_topic" -m "Hello MQTT"```
- [Wireshark](https://www.wireshark.org) - Network protocol analyzer (included in GUI)

### Port Forwarding

All virtual machine ports are forward to the host machine on the following ports:

- 1883 - MQTT
- 8883 - MQTT (TLS/SSL)
- 9001 - MQTT Websockets
- 9883 - MQTT Websockets (TLS/SSL)

### Coming Soon

- [MQTT Web Client](https://github.com/hivemq/hivemq-mqtt-web-client)