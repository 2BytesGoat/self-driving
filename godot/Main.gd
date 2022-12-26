extends Node2D

export var udp_control = false
export var max_stopped_frames = 420

var socket: PacketPeerUDP
var socket_host = "127.0.0.1"
var socket_port = 4242
var socket_stop = false

onready var agent = get_node("Agent")

func _ready():
	agent.manual_control = not udp_control
	agent.max_stopped_frames = max_stopped_frames
	if udp_control:
		_open_socket()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print(agent.get_state())
		print(agent.is_done())

func _process(_delta):
	if udp_control:
		var input_vector = get_socket_input()
		if input_vector:
			agent.do_action(input_vector["agent1"])
		else:
			agent.do_action(Vector2.ZERO)

func _open_socket():
	socket = PacketPeerUDP.new()
	if(socket.listen(4242, "127.0.0.1") != OK):
		print("An error occurred listening on port 4242")
		socket_stop = true
	else:
		print("Listening on port 4242 on localhost")

func get_socket_input():
	var data = socket.get_packet().get_string_from_ascii()
	if not data:
		return
	
	if data == "quit":
		print("Close Connection")
		socket_stop = false
		socket.close()
		return
	
	var evaluated_data = evaluate_expression(data)
	if evaluated_data:
		return evaluated_data
	
	print("Could not evaluate")
	return

func evaluate_expression(command, variable_names = [], variable_values = []):
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		push_error(expression.get_error_text())
		return

	var result = expression.execute(variable_values, self)
	if expression.has_execute_failed():
		return null
	return result
