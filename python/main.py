import time
import socket

import random

for pings in range(100):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client_socket.settimeout(1.0)

    x, y = random.randrange(-10, 10, 1) / 10, random.randrange(-10, 10, 1) / 10
    message = "{" + f'"agent1": Vector2({x}, {y})' + "}"
    message = message.encode()
    addr = ("127.0.0.1", 4242)

    client_socket.sendto(message, addr)