extends Node2D

var follow_path: Node2D
var manual_control = false
onready var vehicle = get_node("Vehicle")

var checkpoint = null
var trajectory_angle = 0.0
var laps_completed = 0
var prev_completion = 0.0
var max_stopped_frames = 10

var state = []
var reward = 0
var done = false

func _ready():
	update_state()

func _input(event):
	if manual_control:
		do_action(get_keyboard_input())

func get_keyboard_input():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	return input_vector

func do_action(input_vector: Vector2):
	vehicle.update_input_vector(input_vector)
	update_state()

func update_state():
	update_trajectory()
	update_laps()
	check_if_done()
	
	var distance = 100
	if checkpoint:
		distance = vehicle.global_position.distance_to(checkpoint.next_point_pos)
	
	state = []
	# state += vehicle.get_sensor_status()
	state += [vehicle.rotation]
	state += [trajectory_angle]
	state += [distance / 100] # normalize distance for network

func get_state_shape():
	return len(state)

func get_input_shape():
	# TODO: think of a better way to do this
	return 2

func check_if_done():
	if max_stopped_frames != INF:
		done = vehicle.stopped_frames >= max_stopped_frames or calculate_reward() < 0
	if done:
		vehicle.update_input_vector(Vector2.ZERO)
		vehicle.mark_as_stopped()

func update_trajectory():
	trajectory_angle = 0
	if checkpoint:
		trajectory_angle = vehicle.to_local(checkpoint.next_point_pos * vehicle.get_scale()).angle()

func update_laps():
	var completion = get_completion_perc()
	if prev_completion >= 0.95 and completion <= 0.1:
		laps_completed += 1 # condition for starting new lap
	elif prev_completion <= 0.1 and completion >= 0.95:
		laps_completed -= 1 # condition for going in reverse
	prev_completion = completion

func get_completion_perc():
	var curve = follow_path.get_curve()
	var offset = curve.get_closest_offset(vehicle.global_position)
	return offset/curve.get_baked_length()

func calculate_reward():
	var modifier = prev_completion
	if sign(laps_completed) == -1:
		modifier = - (1 - prev_completion)
	return laps_completed + prev_completion

func _on_Area2D_area_entered(area):
	checkpoint = area.get_parent()
