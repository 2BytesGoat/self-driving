extends "res://ManualAgent.gd"

var socket: PacketPeerUDP
var socket_host = "127.0.0.1"
var socket_port = 4242
var socket_stop = false

func _ready():
	_open_socket()
	prev_completion = get_completion_perc()

func _open_socket():
	socket = PacketPeerUDP.new()
	if(socket.listen(4242,"127.0.0.1") != OK):
		print("An error occurred listening on port 4242")
		socket_stop = true
	else:
		print("Listening on port 4242 on localhost")

func move_vehicle():
	var input_vector = get_socket_input()
	vehicle.update_input_vector(input_vector)

func get_socket_input():
	var input_vector = Vector2.ZERO
	if socket_stop:
		return input_vector
	
	var data = socket.get_packet().get_string_from_ascii()
	if not data:
		return input_vector
	
	if data == "quit":
		print("Close Connection")
		socket_stop = false
		socket.close()
		return input_vector
	
	var evaluated_data = evaluate_expression(data)
	if evaluated_data:
		return evaluated_data

	print("Could not evaluate")
	return input_vector

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
