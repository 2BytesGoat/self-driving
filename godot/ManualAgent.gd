extends Node2D

export(NodePath) onready var follow_path = get_node(follow_path)
var prev_completion = 0.0
var laps_completed = 0

onready var vehicle = get_node("Vehicle")

func _ready():
	prev_completion = get_completion_perc()

func _physics_process(delta):
	move_vehicle()

func move_vehicle():
	var input_vector = get_keyboard_input()
	vehicle.update_input_vector(input_vector)

func get_keyboard_input():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	return input_vector

func get_completion_perc():
	var curve = follow_path.get_curve()
	var offset = curve.get_closest_offset(vehicle.global_position)
	return offset/curve.get_baked_length()

func calculate_score():
	var modifier = prev_completion
	if sign(laps_completed) == -1:
		modifier = - (1 - prev_completion)
	var score = laps_completed + prev_completion

func update_laps():
	var completion = get_completion_perc()
	if prev_completion >= 0.95 and completion <= 0.1:
		laps_completed += 1
	elif prev_completion <= 0.1 and completion >= 0.95:
		laps_completed -= 1
	prev_completion = completion
