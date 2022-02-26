extends Area2D


func _ready():
	pass

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
#		pass
		var this_zombie = get_parent()
		var scenenode = get_node("/root/Zombies").cur_level
		scenenode.control_zombie(this_zombie)
