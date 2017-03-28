

[TOC]

## Getting Started

1. Clone this repository to a working directory.
2. Copy the directory /.march to your home directory.
3. Execute the command ```vagrant up``` in the repository directory.
4. Execute the command ```vagrant ssh``` in the repository directory.

## Configured Software

### Mosquitto

- Mosquitto Server (MQTT & Websocket Support) ```/etc/mosquitto/mosquitto.conf```
  - 1883 - MQTT
  - 8883 - MQTT (TLS/SSL)
  - 9001 - MQTT Websockets
  - 9883 - MQTT Websockets (TLS/SSL)
- Mosquitto Client (CLI)
  - MQTT
    - ```mosquitto_pub -h localhost -t "my_topic" -m "Hello MQTT"```
    - ```mosquitto_sub -h localhost -t "my_topic" -v```
  - MQTT (TLS/SSL)
    - ```mosquitto_pub --cafile /etc/ssl/march/ca.crt -h localhost -t "test" -m "message" -p 8883```
    - ```mosquitto_sub -t \$SYS/broker/bytes/\# -v --cafile /etc/ssl/march/ca.crt -p 8883```



## System Configuration

### Port Forwarding

All virtual machine ports are forward to the host machine on the following ports:

### Self-Signed Certificates (TLS/SSL)

The virtual machine is configured with self-signed certificated that are located at ```/etc/ssl/march/```. 



## Coming Soon...

- [MQTT Web Client](https://github.com/hivemq/hivemq-mqtt-web-client)
- [Wireshark](https://www.wireshark.org) - Network protocol analyzer (included in GUI)