extends Node2D

export var agents_nb = 5
export var udp_control = false
export var max_stopped_frames = 420

var socket: PacketPeerUDP
var socket_host = "127.0.0.1"
var socket_port = 4242

onready var agent_scene = preload("res://Agent.tscn")
onready var agent_node = get_node("Agents")
onready var follow_path = get_node("Path2D")
var agents = {}

func _ready():
	reset_agents()
	if udp_control:
		_open_socket()

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
	print("Close Connection")
	socket.close()
	socket = null

func spawn_agents():
	var agent_spawn = follow_path.curve.get_baked_points()[0]
	for i in agents_nb:
		var agent_name = "agent" + str(i)
		var agent = agent_scene.instance()
		agent.position = agent_spawn
		agent.follow_path = follow_path
		agent.manual_control = not udp_control
		agent.max_stopped_frames = max_stopped_frames
		agent_node.add_child(agent)
		agents[agent_name] = agent

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
	var pack = JSON.print(data).to_ascii()
	socket.put_packet(pack)

func execute_command(command):
	match command["type"]:
		"info":
			send_env_info()
		"step":
			step(command)
			send_agent_state()
		"reset":
			reset_agents()
			send_agent_state()
		"quit":
			_close_socket()

func step(command):
	for agent_name in agents:
		var agent_action = command.get(agent_name, null)
		if agent_action:
			var agent = agents[agent_name]
			agent.do_action(Vector2(agent_action[0], agent_action[1]))

func get_agents_state():
	var state = {}
	for agent_name in agents:
		var agent = agents[agent_name]
		state[agent_name] = {
			"time": OS.get_ticks_msec() % 1000,
			"state": agent.get_state(),
			"done": agent.is_done(),
			"reward": agent.calculate_reward()
		}
	return state

func send_agent_state():
	var state = get_agents_state()
	write_to_socket(state)

func send_env_info():
	var agent = agents[agents.keys()[0]]
	var info = {
		"agents_nb": agents_nb,
		"agent_state_shape": agent.get_state_shape(),
		"agent_action_shape": agent.get_input_shape()
	}
	write_to_socket(info)

func clear_agents():
	for agent_name in agents:
		var agent = agents[agent_name]
		agent_node.remove_child(agent)
		agent.queue_free()

func reset_agents():
	clear_agents()
	spawn_agents()

func stop_agents():
	for agent_name in agents:
		agents[agent_name].do_action(Vector2.ZERO)
