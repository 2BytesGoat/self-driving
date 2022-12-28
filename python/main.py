import os

from godot_environment import GodotEnv
from neat_trainer import NeatTrainer
 
EPISODE_LEN = 100
CONFIG_FILE = r"configs\neat"

local_dir = os.path.dirname(__file__)
config_path = os.path.join(local_dir, CONFIG_FILE)

env = GodotEnv()
neat = NeatTrainer(env, config_path, EPISODE_LEN)
neat.find_winner()
