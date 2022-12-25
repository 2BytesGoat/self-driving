import time
import socket

import random

for pings in range(100):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    client_socket.settimeout(1.0)

    x, y = random.random(), random.random()
    message = f"Vector2({x}, {y})".encode()
    addr = ("127.0.0.1", 4242)

    client_socket.sendto(message, addr)