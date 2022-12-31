import os

from godot_environment import GodotEnv
from neat_trainer import NeatTrainer
 
EPISODE_LEN = 1000
GENERATIONS = 300
CONFIG_FILE = "configs/neat.cfg"
CHECKPOINT_FILE = None

local_dir = os.path.dirname(__file__)
config_path = os.path.join(local_dir, CONFIG_FILE)
checkpoint_path = None if not CHECKPOINT_FILE else os.path.join(local_dir, CHECKPOINT_FILE)

env = GodotEnv()
neat = NeatTrainer(env, config_path, checkpoint_path, EPISODE_LEN)
winner = neat.find_winner(GENERATIONS)

# TODO: add call to get node names from Godot
node_names = {
    -1: 'Agent Rotation', 
    -2: 'Trajectory Rad',
    -3: 'Distance', 
    0: 'Direction X',
    1: 'Direction Y'
}
neat.visualize_winner(winner, node_names)