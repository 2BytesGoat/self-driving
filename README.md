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
- [ ] build a OpenAI gym wrapper around game
- [ ] create function to spawn multiple agents
- [ ] train AI using genetic algorithms