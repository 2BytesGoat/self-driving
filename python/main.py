import os

from godot_environment import GodotEnv
from neat_trainer import NeatTrainer
 
EPISODE_LEN = 420
CONFIG_FILE = r"configs\neat.cfg"
CHECKPOINT_FILE = None

local_dir = os.path.dirname(__file__)
config_path = os.path.join(local_dir, CONFIG_FILE)
checkpoint_path = None if not CHECKPOINT_FILE else os.path.join(local_dir, CHECKPOINT_FILE)

env = GodotEnv()
neat = NeatTrainer(env, config_path, checkpoint_path, EPISODE_LEN)
neat.find_winner()
