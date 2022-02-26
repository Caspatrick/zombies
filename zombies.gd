extends Node2D

const city_xsize = 50
const city_ysize = 50
const tilesize = 32
const house_minsize = 5
const house_maxsize = 12
const houseprob = .02
const camera_speed = 400

var nzombies = 0
var nhumans = 20
var rng
var human_list
var city
var cur_level
var controlled = null 

func _ready():
	cur_level = $ExLevel

func _process(delta):
	pass
		
func win():
	$Label.text = " You Win! "
	$Panel.visible = true

func newgame():
	$Panel.visible = false
	cur_level.queue_free()
	var level = load("Level.tscn")
	cur_level = level.instance()
	add_child(cur_level)


	
func lose():
#	$Panel/Label.text = " You Lose! "
	$Panel.visible = true

