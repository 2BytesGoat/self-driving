import pickle
import neat

class NeatTrainer:
    def __init__(self, env, config_file, checkpoint=None, episode_len=420):
        self.env = env
        self.episode_len = episode_len

        # Load configuration.
        config = neat.Config(neat.DefaultGenome, neat.DefaultReproduction,
                            neat.DefaultSpeciesSet, neat.DefaultStagnation,
                            config_file)

        # Create the population, which is the top-level object for a NEAT run.
        self.population = neat.Population(config)

        if checkpoint:
            self.population = neat.Checkpointer.restore_checkpoint(checkpoint)

        # Add a stdout reporter to show progress in the terminal.
        self.population.add_reporter(neat.StdOutReporter(True))
        self.stats = neat.StatisticsReporter()
        self.population.add_reporter(self.stats)
        self.population.add_reporter(neat.Checkpointer(5))

    def batch_genomes(self, genomes, n=1):
        l = len(genomes)
        for ndx in range(0, l, n):
            yield genomes[ndx:min(ndx + n, l)]

    def eval_genomes(self, genomes, config):
        nb_agents = self.env.env_info["agents_nb"]

        for genome_batch in self.batch_genomes(genomes, nb_agents):
            # initialize genome networks
            genome_nets = [
                neat.nn.FeedForwardNetwork.create(genome, config) 
                for _, genome in genome_batch
            ]
            state = self.env.reset()

            # consider replacing episode_len with config stagnation
            for step_n in range(self.episode_len):
                if not state:
                    continue
                done_cnt = 0 # count how many genomes/agents are done
                action = {}
                # may be lesser genomes in one batch due to mutations
                for genome_idx in range(len(genome_nets)):
                    agent_name = f"agent{genome_idx}"
                    agent_state = state.get(agent_name, None)
                    if not agent_state:
                        continue
                    done = agent_state["done"]
                    if done: # skipe genome/agent if it's done
                        done_cnt += 1
                        continue
                    agent_state = agent_state["state"]
                    # get action for agent based on network
                    action[agent_name] = genome_nets[genome_idx].activate(agent_state)
                if done_cnt == nb_agents: # if all genomes/agents are done stop
                    break 
                state = self.env.step(action)

            for genome_idx in range(len(genome_nets)):
                agent_name = f"agent{genome_idx}"
                agent_state = state.get(agent_name, None)
                if not agent_state:
                    continue
                reward = state[agent_name]["reward"]
                genome_idx, genome = genome_batch[genome_idx]
                genome.fitness = reward

    def find_winner(self):
        # Run for up to 300 generations.
        winner = self.population.run(self.eval_genomes, 300)

        # Display the winning genome.
        print('\nBest genome:\n{!s}'.format(winner))

        with open('models/neat-model.pkl', 'wb') as f:
            pickle.dump(winner, f)

        return winner