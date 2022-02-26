extends KinematicBody2D

var direction = 3 # 1:left 2:up 3: right 4: down 0: idle
var walking = true #for animation
export var state = 0  # 0: Human 1: Turned 2: Zombie 3: Dead
export var controlled = false
var dir = Vector2(0,0)
var age = 0
var p_infect = 0
var flee = false 
var rng
const max_age = 1000 #age at which zombies die
const p_change_dir = 0.01
const move_speed = 200


func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	
func _process(delta):
	if state == 0 :#if human, check infection level
		if p_infect >= 100 : state = 1
	if state < 3: #if not dead
		if state == 2:#if zombie
			age = age +1
			if age > max_age :
				die()
		if controlled : check_input()
		if state < 2: random_walk()
		walk(delta)
		animate()
	
func random_walk():
	var rn = rng.randf_range(0.0, 1.0)
	if rn < p_change_dir : 
		var x = rng.randf_range(-1.0,1.0)
		var y = rng.randf_range(-1.0,1.0)
		dir = Vector2(x,y) / sqrt(x*x + y*y)
#	else : direction = 0
	
# warning-ignore:unused_argument
func walk(delta):
	if direction > 0:
		walking = true
		
# warning-ignore:return_value_discarded
		move_and_slide(dir*move_speed)
	else : walking = false
	
func die():
	state = 3
	direction = 0
	walking = false
	get_node("/root/Zombies").cur_level.nzombies -= 1
	$Area2D/AnimatedSprite.play("dying")
	
func animate() :
	var anim
	if walking : anim = "walk_"
	else : anim = "idle_"
	if state == 0 : anim += "human"
	elif state == 1 : anim += "turned"
	elif state == 2 : anim += "zombie"
	
	if direction == 1 : $Area2D/AnimatedSprite.flip_h = true
	if direction == 3 : $Area2D/AnimatedSprite.flip_h = false
	$Area2D/AnimatedSprite.play(anim)
	
	#skulls animation
	if state > 1 :
		var n_anim = age*6/max_age+1
		$skulls_sprite.play("skull"+str(n_anim))

func check_input() :
	dir = Vector2(0,0)
	if state == 2 or state == 1:
		if Input.is_action_pressed("left") : direction = 1
		elif Input.is_action_pressed("up") : direction = 2
		elif Input.is_action_pressed("right") : direction = 3
		elif Input.is_action_pressed("down") : direction = 4
		else : direction = 0
		
		if direction == 1:	dir.x = -1
		elif direction ==2: dir.y = -1
		elif direction ==3: dir.x = 1
		elif direction ==4: dir.y = 1
	if Input.is_action_pressed("interact") and state == 1 :
		go_zombie() # turn "turned" into zombie
	
		
func control_me():
	controlled = true

func go_zombie():
	state = 2
	$skulls_sprite.visible = true
	get_parent().nhumans -= 1
	get_parent().nzombies += 1

func collides_with(other_person):
	#if you're infected and the other isn't, get infected
	if state == 0 and other_person.state == 2 :
		state = 1
	
		
		
		
		
		

func get_class() :
	return "Human"

func _on_Area2D_area_entered(area):
	var passme = area.get_parent() 
	#check if person
	if passme.get_class() == "Human" :
		collides_with(passme)
