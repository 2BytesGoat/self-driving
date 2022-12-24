extends KinematicBody2D

export var ray_number = 5
export var ray_length = 50

var front_senzors = []

const MAX_SPEED = 200
const TURN_SPEED = 2.5

var velocity = Vector2.ZERO

func _ready():
	_init_rays()

func _init_rays():
	for i in range(1, ray_number+1):
		var ray_angle = i * PI / (ray_number + 1)
		var ray = RayCast2D.new()
		ray.set_cast_to(Vector2.UP.rotated(ray_angle) * ray_length)
		ray.enabled = true
		add_child(ray)

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector
		var target_rotation = atan2(input_vector.y, input_vector.x)
		# self.rotation = lerp_angle(self.rotation, target_rotation, delta*TURN_SPEED)
		self.rotation = target_rotation
	else:
		velocity = Vector2.ZERO
	
	move_and_collide(velocity * delta * MAX_SPEED)
