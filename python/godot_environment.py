import socket
import random
import json

class GodotEnv:
    def __init__(self, server_ip="127.0.0.1", server_port=4242):
        self.addr = (server_ip, server_port)
        self.client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.client_socket.settimeout(1.0)

        self.env_info = self._get_env_info()

    def _get_env_info(self):
        action = {"type": "info"}
        self._send_message(str(action))
        return self._read_message()

    def step(self, action):
        action["type"] = "step"
        self._send_message(str(action))
        state = self._read_message()
        return state

    def reset(self):
        action = {"type": "reset"}
        self._send_message(str(action))
        state = self._read_message()
        return state

    def sample_action(self):
        def get_random_action():
            return random.randrange(-10, 10, 1) / 10
        action = [get_random_action() for _ in range(self.env_info["agent_action_shape"])]
        return action

    def _send_message(self, message:str):
        self.client_socket.sendto(message.encode(), self.addr)

    def _read_message(self):
        enc_state, _ = self.client_socket.recvfrom(1024*24)
        state = json.loads(enc_state.decode())
        return state