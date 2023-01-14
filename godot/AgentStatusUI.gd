extends VBoxContainer

var agent_idx = 0
var env_state = {} setget env_state_updated

var is_ui_initialized = false
onready var agent_info_ui = get_node("AgentInfo")
onready var agent_label = get_node("AgentSelector/AgentLabel")
onready var signal_text_scene = preload("res://SignalText.tscn")

func env_state_updated(new_env_state):
	env_state = new_env_state
	update_agent_info_ui()

func update_agent_info_ui():
	var agent_names = env_state.keys()
	var current_agent = agent_names[agent_idx]
	var state = env_state[current_agent]
	
	agent_label.bbcode_text = "[center]" + current_agent + "[/center]"
	
	if not is_ui_initialized:
		initialize_ui(state)
		is_ui_initialized = true
	else:
		update_ui(state)

func initialize_ui(state):
	for signal_name in state:
		var signal_key = signal_text_scene.instance()
		signal_key.text = signal_name
		signal_key.fit_content_height = true
		agent_info_ui.add_child(signal_key)
		
		var signal_value = signal_text_scene.instance()
		signal_value.text = str(state[signal_name])
		signal_value.fit_content_height = true
		agent_info_ui.add_child(signal_value)

func update_ui(state):
	var state_keys = state.keys()
	var ui_children = agent_info_ui.get_children()
	for signal_idx in range(len(state)):
		var signal_name = state_keys[signal_idx]
		ui_children[signal_idx*2+1].text = str(state[signal_name])

func _on_Previous_pressed():
	pass # Replace with function body.

func _on_Next_pressed():
	pass # Replace with function body.
