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
    - [ ] fix - running for only one generation
    - [ ] fix - done condition and stagnation does not seem to work
    - [ ] use godot env info/init godot enb with config info
    - [ ] batch genomes for single run
- [ ] train AI using genetic algorithms