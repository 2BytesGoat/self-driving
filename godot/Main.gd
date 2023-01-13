extends Node2D

export var ai_agents_nb = 50
export var udp_control = false
export var max_stopped_frames = 10

var socket: PacketPeerUDP
var socket_host = "127.0.0.1"
var socket_port = 4242

onready var agent_scene = preload("res://Agents/Agent.tscn")
onready var agent_node = get_node("Agents")
onready var follow_path = get_node("Path2D")

func _ready():
	reset_agents()
	reset_connection()

func _process(_delta):
	if not (udp_control and socket):
		return
	
	var command = read_from_socket()
	if command:
		execute_command(command)

func _open_socket():
	socket = PacketPeerUDP.new()
	if(socket.listen(socket_port, socket_host) != OK):
		print("An error occurred listening on port " + str(socket_port))
		_close_socket()
	else:
		print("Listening on port " + str(socket_port) + " on localhost")

func _close_socket():
	if socket:
		print("Close Connection")
		socket.close()
		socket = null

func spawn_agents(agents_nb, stopped_frames):
	var agent_spawn = follow_path.curve.get_baked_points()[0]
	for i in agents_nb:
		var agent_name = "agent" + str(i)
		var agent = agent_scene.instance()
		agent.position = agent_spawn
		agent.follow_path = follow_path
		agent.manual_control = not udp_control
		agent.max_stopped_frames = stopped_frames
		agent.name = agent_name
		agent_node.add_child(agent)

func read_from_socket():
	var data = socket.get_packet().get_string_from_ascii()
	if data:
		var command = Utils.evaluate_expression(data)
		if command:
			var IP_CLIENT = socket.get_packet_ip()
			var PORT_CLIENT = socket.get_packet_port()
			socket.set_dest_address(IP_CLIENT, PORT_CLIENT)
			return command
		print("Could not evaluate")
	stop_agents()

func write_to_socket(data: Dictionary):
	var pack = JSON.print(data).to_utf8()
	socket.put_packet(pack)

func execute_command(command):
	match command["type"]:
		"info":
			send_env_info()
		"step":
			step(command)
			send_agent_state()
		"reset":
			ai_agents_nb = command["agents_nb"]
			reset_agents()
			send_agent_state()
		"quit":
			_close_socket()

func step(command):
	for agent in agent_node.get_children():
		var agent_action = command.get(agent.name, null)
		if agent_action:
			agent.do_action(Vector2(agent_action[0], agent_action[1]))

func get_agents_state():
	var state = {}
	for agent in agent_node.get_children():
		state[agent.name] = {
			"time": OS.get_ticks_msec() % 1000,
			"state": agent.state,
			"done": agent.done,
			"reward": agent.calculate_reward()
		}
	return state

func send_agent_state():
	var state = get_agents_state()
	write_to_socket(state)

func send_env_info():
	var agent = agent_node.get_children()[0]
	var info = {
		"agents_nb": ai_agents_nb,
		"agent_state_shape": agent.get_state_shape(),
		"agent_action_shape": agent.get_input_shape()
	}
	write_to_socket(info)

func clear_agents():
	for agent in agent_node.get_children():
		agent_node.remove_child(agent)
		agent.queue_free()

func stop_agents():
	for agent in agent_node.get_children():
		agent.do_action(Vector2.ZERO)

func reset_agents():
	clear_agents()
	if udp_control:
		spawn_agents(ai_agents_nb, max_stopped_frames)
	else:
		spawn_agents(1, INF)

func reset_connection():
	if udp_control:
		_open_socket()
	else:
		_close_socket()

func _on_CheckButton_toggled(button_pressed):
	udp_control = not button_pressed
	reset_agents()
	reset_connection()
