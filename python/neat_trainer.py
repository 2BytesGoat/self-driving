import pickle
import neat
import visualize

class NeatTrainer:
    def __init__(self, env, config_file, checkpoint=None, episode_len=420):
        self.env = env
        self.episode_len = episode_len

        # Load configuration.
        self.config = neat.Config(neat.DefaultGenome, neat.DefaultReproduction,
                            neat.DefaultSpeciesSet, neat.DefaultStagnation,
                            config_file)

        # Create the population, which is the top-level object for a NEAT run.
        self.population = neat.Population(self.config)

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
        genome_networks = self._init_genome_networks(genomes, config)
        
        state = None
        # reset environment for new episode
        state = self.env.reset(len(genomes))

        for _ in range(self.episode_len):               
            # act and count how many genomes/agents are done
            action, done_cnt = self.get_actions_for_state(state, genome_networks)
            
            # if all genomes/agents are done stop
            if done_cnt == len(genomes): 
                break 
            
            state = self.env.step(action)
            # state may be absent because of package loss
            # TODO: replace UDP with TCP
            if not state:
                break

        # set fitness to determine winner
        self.set_fitness(state, genomes)

    def find_winner(self, generations=300):
        # Run for up to 300 generations.
        winner = self.population.run(self.eval_genomes, generations)

        # Display the winning genome.
        print('\nBest genome:\n{!s}'.format(winner))

        with open('models/neat-model.pkl', 'wb') as f:
            pickle.dump(winner, f)

        return winner

    def visualize_winner(self, winner, node_names):
        visualize.draw_net(self.config, winner, True, node_names=node_names)
        # visualize.draw_net(self.config, winner, True, node_names=node_names, prune_unused=True)
        visualize.plot_stats(self.stats, ylog=False, view=True)
        visualize.plot_species(self.stats, view=True)

    def _init_genome_networks(self, genomes, config):
        genome_networks = {}
        # initialize genome networks
        for genome_idx, (genome_id, genome) in enumerate(genomes):
            genome.fitness = 0
    
            net = neat.nn.FeedForwardNetwork.create(genome, config) 
            genome_name = f"agent{genome_idx}"
            genome_networks[genome_name] = net
        return genome_networks

    def get_actions_for_state(self, state, genome_networks):
        action = {}
        done_cnt = 0
        for genome_name in genome_networks:
            genome_info = state.get(genome_name, None)
            if not genome_info:
                done_cnt += 1
                continue
            done = genome_info["done"]
            # skip genome/agent if it's done
            if done: 
                done_cnt += 1
                continue
            genome_state = genome_info["state"]
            # get action for agent based on network
            action[genome_name] = genome_networks[genome_name].activate(genome_state)
        return action, done_cnt

    def set_fitness(self, state, genomes):
        for genome_idx, (genome_id, genome) in enumerate(genomes):
            genome_name = f"agent{genome_idx}"
            genome_info = state.get(genome_name, None)
            if not genome_info:
                print('jere')
                genome.fitness = 0
                continue
            reward = genome_info["reward"]
            genome.fitness = reward