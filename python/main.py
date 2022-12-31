import os
import typer

from godot_environment import GodotEnv
from neat_trainer import NeatTrainer
 
def main(
    episode_len:int = 1000, 
    generations:int = 300, 
    config_file:str = "configs/neat.cfg", 
    checkpoint_file:str = None
    ):
    local_dir = os.path.dirname(__file__)
    config_path = os.path.join(local_dir, config_file)
    checkpoint_path = None if not checkpoint_file else os.path.join(local_dir, checkpoint_file)

    env = GodotEnv()
    neat = NeatTrainer(env, config_path, checkpoint_path, episode_len)
    winner = neat.find_winner(generations)

    # TODO: add call to get node names from Godot
    node_names = {
        -1: 'Agent Rotation', 
        -2: 'Trajectory Rad',
        -3: 'Distance', 
        0: 'Direction X',
        1: 'Direction Y'
    }
    neat.visualize_winner(winner, node_names)

if __name__ == "__main__":
    typer.run(main)