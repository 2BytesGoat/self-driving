# Self Driving

## TODOs for MVP
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
- [ ] tackle multiple agents in single run
    - [x] fix - running for only one generation
    - [x] fix - done condition and stagnation does not seem to work
    - [x] batch genomes for single run
- [ ] fix agent state to be descriptive enough
- [ ] obtain AI using genetic algorithms

## After MVP
- [ ] replace UDP communication with TCP to fix package loss
- [ ] use godot env info/init godot env with config info
    - [ ] pass number of genomes to Godot to spawn agents
- [ ] make simulator more appeling
    - [ ] configure ip and port
    - [ ] easily identify agents
    - [ ] know when an agent is done
    - [ ] toggle debug for visualizing sensors
    - [ ] button to connect and disconnect communication
- [ ] make a more complicated environment with object avoidance