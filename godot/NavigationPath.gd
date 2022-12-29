extends Path2D

var checkpoint_cls = preload("res://Checkpoint.tscn")
onready var checkpoint_node = get_node("Checkpoints")

func _ready():
	for point_idx in curve.get_point_count() - 1:
		var point_pos = curve.get_point_position(point_idx)
		
		var prev_point_idx = point_idx - 1
		if prev_point_idx == -1:
			prev_point_idx = curve.get_point_count() - 1
		var prev_point = curve.get_point_position(prev_point_idx)
		
		var next_point_idx = point_idx + 1
		if next_point_idx == curve.get_point_count():
			next_point_idx = 0
		var next_point = curve.get_point_position(next_point_idx)
		
		var point_rot = Vector2.RIGHT.angle_to(prev_point - next_point)
		
		var checkpoint = checkpoint_cls.instance()
		checkpoint.position = point_pos
		checkpoint.rotation = point_rot
		checkpoint.name = str(point_idx)
		checkpoint.index = point_idx
		checkpoint.prev_checkpoint = prev_point
		checkpoint.next_checkpoint = next_point
		checkpoint_node.add_child(checkpoint)
