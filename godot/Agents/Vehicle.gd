extends KinematicBody2D

var ray_number = 8
var ray_length = 40
var senzors = []

const MAX_SPEED = 250
const ACCELERATION = 750
const FRICTION = 1000
const TURN_SPEED = 10
var velocity = Vector2.ZERO

onready var sprite = get_node("Sprite")

var input_vector = Vector2.ZERO
var stopped_frames = 0

func _ready():
	_init_sensors()

func _physics_process(delta):
	if input_vector != Vector2.ZERO:
		var target_rotation = atan2(input_vector.y, input_vector.x)
		self.rotation = lerp_angle(self.rotation, target_rotation, delta*TURN_SPEED)
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity)
	
	count_stopped_frames()

func _init_sensors():
	for i in range(0, ray_number):
		var ray_angle = i * 2 * PI / (ray_number)
		var ray = RayCast2D.new()
		ray.set_cast_to(Vector2.UP.rotated(ray_angle) * ray_length)
		ray.enabled = true
		add_child(ray)
		senzors.append(ray)

func update_input_vector(new_input_vector):
	input_vector = new_input_vector

func get_sensor_status():
	var status = []
	status.resize(len(senzors))
	for sensor_idx in len(senzors):
		var sensor = senzors[sensor_idx]
		status[sensor_idx] = ray_length
		if sensor.is_colliding():
			var collision_point = sensor.get_collision_point()
			var distance = Utils.get_distance(collision_point, self.global_position)
			status[sensor_idx] = stepify(distance, 0.01)
	return status

func count_stopped_frames():
	var min_speed = MAX_SPEED * 0.25
	if abs(velocity.x) >= min_speed or abs(velocity.y) >= min_speed:
		stopped_frames = 0
	else:
		stopped_frames += 1

func mark_as_stopped():
	sprite.modulate = Color( 1, 0, 0, 0.3 )
