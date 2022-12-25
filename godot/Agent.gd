extends KinematicBody2D

export var manual_control = true
var socket: PacketPeerUDP
var socket_host = "127.0.0.1"
var socket_port = 4242
var socket_stop = false

export var ray_number = 5
export var ray_length = 50
var front_senzors = []

const MAX_SPEED = 200
const TURN_SPEED = 20
var velocity = Vector2.ZERO

func _ready():
	_init_rays()
	_open_socket()

func _init_rays():
	for i in range(1, ray_number+1):
		var ray_angle = i * PI / (ray_number + 1)
		var ray = RayCast2D.new()
		ray.set_cast_to(Vector2.UP.rotated(ray_angle) * ray_length)
		ray.enabled = true
		add_child(ray)

func _open_socket():
	socket = PacketPeerUDP.new()
	if(socket.listen(4242,"127.0.0.1") != OK):
		print("An error occurred listening on port 4242")
		socket_stop = true
	else:
		print("Listening on port 4242 on localhost")

func _physics_process(delta):
	if manual_control:
		velocity = get_keyboard_input()
	else:
		velocity = get_socket_input()
	
	if velocity != Vector2.ZERO:
		var target_rotation = atan2(velocity.y, velocity.x)
		self.rotation = lerp_angle(self.rotation, target_rotation, delta*TURN_SPEED)
	
	move_and_collide(velocity * delta * MAX_SPEED)

func get_keyboard_input():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	return input_vector

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
	
	var evaluated_data = evaluate(data)
	if evaluated_data:
		return evaluated_data

	print("Could not evaluate")
	return input_vector

func evaluate(command, variable_names = [], variable_values = []):
	var expression = Expression.new()
	var error = expression.parse(command, variable_names)
	if error != OK:
		push_error(expression.get_error_text())
		return

	var result = expression.execute(variable_values, self)
	if expression.has_execute_failed():
		return null
	return result
