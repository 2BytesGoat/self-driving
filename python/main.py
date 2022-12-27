import socket
import random
import json
 
EPISODE_LEN = 420

addr = ("127.0.0.1", 4240)
client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
client_socket.settimeout(1.0)

action = {"type": "init"}
message = str(action).encode()
client_socket.sendto(message, addr)

enc_state, _ = client_socket.recvfrom(1024)
state = json.loads(enc_state.decode())

for pings in range(EPISODE_LEN):
    action = {"type": "step"}
    for agent_name in state:
        if state[agent_name]["done"]:
            continue

        x, y = random.randrange(-10, 10, 1) / 10, random.randrange(-10, 10, 1) / 10

        action[agent_name] = {
            'x': x,
            'y': y
        }

    message = str(action).encode()
    client_socket.sendto(message, addr)
        
    enc_state, _ = client_socket.recvfrom(1024)
    state = json.loads(enc_state.decode())

action = {"type": "reset"}
message = str(action).encode()
client_socket.sendto(message, addr)