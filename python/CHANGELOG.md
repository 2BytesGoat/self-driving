# Change Log

## Backlog
- [ ] spawn agents at random positions on the path

## [0.0.2] - Unreleased - Boer

### Tasks
- [ ] replace UDP communication with TCP to fix package loss
- [ ] use godot env info/init godot env with config info
    - [ ] pass number of genomes to Godot to spawn agents
- [ ] make simulator more appeling
    - [ ] configure ip and port
    - [ ] easily identify agents
    - [x] know when an agent is done
    - [ ] toggle debug for visualizing sensors
    - [ ] button to connect and disconnect communication
- [ ] make more environments

## [0.0.1] - 2022-12-31 - Appenzell
Finished the first draft of the simulator and integration with Python NEAT.

### Tasks
- [x] create communication between Godot and Python
- [x] create Python function to do random actions in environment
- [x] implement checkpointing logic
- [x] define state, actions, reward and done state
    - [x] state - sensor distance around vehicle
    - [x] actions - Vector2 for direction
    - [x] reward - combination of progression and laps
    - [x] done - no velocity for **n** frames
- [x] build a OpenAI gym wrapper around game
- [x] create function to spawn multiple agents
- [x] tackle multiple agents in single run
- [x] fix agent state to be descriptive enough
- [x] obtain AI using genetic algorithms
