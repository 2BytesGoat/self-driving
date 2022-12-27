extends Node2D

export var udp_control = false
export var max_stopped_frames = 420

var socket: PacketPeerUDP
var socket_host = "127.0.0.1"
var socket_port = 4242

onready var agent_scene = preload("res://Agent.tscn")
onready var agent_node = get_node("Agents")
onready var follow_path = get_node("Path2D")
var agents = {}
var agents_nb = 1

func _ready():
	spawn_agents()
	if udp_control:
		_open_socket()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print(agents["agent0"].get_state())
		print(agents["agent0"].is_done())

func _process(_delta):
	if not (udp_control and socket):
		return
	
	var command = read_from_socket()
	if command:
		execute_command(command)

func _open_socket():
	socket = PacketPeerUDP.new()
	if(socket.listen(4242, "127.0.0.1") != OK):
		print("An error occurred listening on port 4242")
		_close_socket()
	else:
		print("Listening on port 4242 on localhost")

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
			return command
		print("Could not evaluate")
	stop_agents()
	
func execute_command(command):
	match command["type"]:
		"init":
			pass
		"step":
			step(command)
		"reset":
			pass
		"quit":
			_close_socket()

func step(command):
	for agent_name in agents:
		var agent_action = command.get(agent_name, null)
		if agent_action:
			var agent = agents[agent_name]
			agent.do_action(Vector2(agent_action.x, agent_action.y))
	
func stop_agents():
	for agent_name in agents:
		agents[agent_name].do_action(Vector2.ZERO)
