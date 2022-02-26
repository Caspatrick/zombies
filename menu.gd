extends Panel


func _ready():
	pass


func _on_Play_Button_pressed():
	get_node("/root/Zombies").newgame()
