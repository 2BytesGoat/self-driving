extends KinematicBody2D

var ray_number = 5
var ray_length = 50
var front_senzors = []

const MAX_SPEED = 250
const ACCELERATION = 750
const FRICTION = 1000
const TURN_SPEED = 10
var velocity = Vector2.ZERO

var input_vector = Vector2.ZERO

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

func _init_sensors():
	for i in range(1, ray_number+1):
		var ray_angle = i * PI / (ray_number + 1)
		var ray = RayCast2D.new()
		ray.set_cast_to(Vector2.UP.rotated(ray_angle) * ray_length)
		ray.enabled = true
		add_child(ray)

func update_input_vector(new_input_vector):
	input_vector = new_input_vector
