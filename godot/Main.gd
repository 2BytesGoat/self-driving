extends Node2D

onready var curve = get_node("Path2D").get_curve()
onready var agent = get_node("Agent")

var prev_perc

func _ready():
	prev_perc = get_completion_perc()

func _input(event):
	if event is InputEventKey:
		if Input.is_action_just_pressed("ui_accept"):
			var perc = get_completion_perc()
			if prev_perc >= 0.95 and perc <= 0.1:
				print('score')
			elif prev_perc <= 0.1 and perc >= 0.95:
				print('undo point')
			prev_perc = perc

func get_completion_perc():
	var agent_position = agent.global_position
	var offset = curve.get_closest_offset(agent_position)
	return offset/curve.get_baked_length()
