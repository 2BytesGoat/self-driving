extends Node2D

var follow_path: Node2D
var manual_control = false

var max_stopped_frames = 10
var prev_completion = 0.0
var checkpoint_obj = null
var laps_completed = 0
var trajectory = 0.0
var dist = 1

onready var vehicle = get_node("Vehicle")


func _ready():
	update_laps()

func _input(event):
	if manual_control:
		do_action(get_keyboard_input())
		print(get_state())

func do_action(input_vector):
	vehicle.update_input_vector(input_vector)
	update_laps()
	update_trajectory()

func get_state():
	var state = []
	var distance = 1
	if checkpoint_obj:
		distance = Utils.get_distance(vehicle.global_position, checkpoint_obj.next_checkpoint)
	# state += vehicle.get_sensor_status()
	state += [vehicle.rotation]
	state += [trajectory]
	state += [distance / 100]
	return state

func get_state_shape():
	return len(get_state())

func get_input_shape():
	# TODO: think of a better way to do this
	return 2

func is_done():
	return vehicle.stopped_frames >= max_stopped_frames or calculate_reward() < 0

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

func calculate_reward():
	var modifier = prev_completion
	if sign(laps_completed) == -1:
		modifier = - (1 - prev_completion)
	return laps_completed + prev_completion

func update_laps():
	var completion = get_completion_perc()
	if prev_completion >= 0.95 and completion <= 0.1:
		laps_completed += 1
	elif prev_completion <= 0.1 and completion >= 0.95:
		laps_completed -= 1
	prev_completion = completion

func update_trajectory():
	if checkpoint_obj:
		trajectory = vehicle.to_local(checkpoint_obj.next_checkpoint * vehicle.get_scale()).angle()
		get_state()

func _on_Area2D_area_entered(area):
	checkpoint_obj = area.get_parent()
