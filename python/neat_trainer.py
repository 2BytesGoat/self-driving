import pickle
import neat

class NeatTrainer:
    def __init__(self, env, config_file, episode_len=420):
        self.env = env
        self.episode_len = episode_len

        # Load configuration.
        config = neat.Config(neat.DefaultGenome, neat.DefaultReproduction,
                            neat.DefaultSpeciesSet, neat.DefaultStagnation,
                            config_file)

        # Create the population, which is the top-level object for a NEAT run.
        self.population = neat.Population(config)

        # Add a stdout reporter to show progress in the terminal.
        self.population.add_reporter(neat.StdOutReporter(True))
        self.stats = neat.StatisticsReporter()
        self.population.add_reporter(self.stats)
        self.population.add_reporter(neat.Checkpointer(5))

    def eval_genomes(self, genomes, config):
        for genome_id, genome in genomes:
            genome.fitness = 0.0
            net = neat.nn.FeedForwardNetwork.create(genome, config)
            state = self.env.reset()
            # consider replacing episode_len with config stagnation
            for step_n in range(self.episode_len):
                state = state["agent0"]["state"]
                action = {"agent0": net.activate(state)}
                state = self.env.step(action)
                reward = state["agent0"]["reward"]
                done = state["agent0"]["done"]
                genome.fitness += reward
                if done:
                    break

    def find_winner(self):
        # Run for up to 300 generations.
        winner = self.population.run(self.eval_genomes, 300)

        # Display the winning genome.
        print('\nBest genome:\n{!s}'.format(winner))

        with open('models/neat-model.pkl', 'wb') as f:
            pickle.dump(winner, f)

        return winner