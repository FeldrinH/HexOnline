extends Polygon2D

export(float, 0, 360, 0.1) var rotation_offset = 0.0

func _ready():
	$AnimationPlayer.play("RotatingBorder")
	$AnimationPlayer.seek(rotation_offset / 360 * $AnimationPlayer.current_animation_length)
