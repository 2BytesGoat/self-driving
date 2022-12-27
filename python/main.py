import socket
import random

client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client_socket.settimeout(1.0)

# message = "init"
# message = message.encode()
# addr = ("127.0.0.1", 4242)
# client_socket.sendto(message, addr)
# state = client_socket.listen()
# print(state)

for pings in range(100):
    x, y = random.randrange(-10, 10, 1) / 10, random.randrange(-10, 10, 1) / 10

    action = {
        "type": "step",
        "agent0": {
            'x': x,
            'y': y
        }
    }
    message = str(action).encode()
    addr = ("127.0.0.1", 4242)

    client_socket.sendto(message, addr)