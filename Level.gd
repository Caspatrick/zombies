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
var controlled = null 

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
#	build_city()
	make_humans()

func _process(delta):
	check_input(delta)
	if nhumans == 0 :
		get_node("/root/Zombies").win()
	if nzombies == 0 :
		get_node("/root/Zombies").lose()
		
	
func check_input(delta) :
	if controlled == null :
		if Input.is_action_pressed("left") : 
			$Camera2D.position.x -= camera_speed * delta
		elif Input.is_action_pressed("up") :  
			$Camera2D.position.y -= camera_speed * delta
		elif Input.is_action_pressed("right") :  
			$Camera2D.position.x += camera_speed * delta
		elif Input.is_action_pressed("down") :  
			$Camera2D.position.y += camera_speed * delta
	else:
		$Camera2D.position = controlled.position
		if Input.is_action_pressed("exit") : 
			controlled.controlled = false
			controlled = null
		
func build_city():
	var floor_id = $TileMap.tile_set.find_tile_by_name("floor")

	#procedurally build city
	city = [[]]
	for x in range(city_xsize):
		city.append([])
		for y in range(city_ysize):
			city[x].append(floor_id)
	#0 = empty; 1 = house
	
	

	
	#build houses
	var x = 1
	var y = 1
	
	var walls_id = $TileMap.tile_set.find_tile_by_name("walls")
	while x < (city_xsize- house_minsize):
		while y < (city_ysize-house_minsize):

			if (city[x][y] == floor_id) and (rng.randf() < houseprob):

				#build new house
				var xsize = rng.randi_range(house_minsize, house_maxsize)
				xsize = min(xsize, city_xsize - x - 2)
				var ysize = rng.randi_range(house_minsize, house_maxsize)
				ysize = min(ysize, city_ysize - y - 2)
				#borders
#				for dx in range(xsize):
#					city[x+dx][y] = 1
#					city[x+dx][y+ysize-1] = 1
#				for dy in range(ysize):
#					city[x][y+dy]=1
#					city[x+xsize-1][y+dy] = 1
				for dx in range(1,xsize-1):
					for dy in range(1,ysize-1):
						city[x+dx][y+dy] = walls_id
				y += ysize+1
			else :
				y+=1
		y = 0
		x+=1
		
	#build trees around city
	var trees_id = $TileMap.tile_set.find_tile_by_name("trees")
	for i in range(city_xsize):
		$TileMap.set_cell(i,-1,trees_id,false,false,false,Vector2(1,0))
		$TileMap.set_cell(i,city_ysize,trees_id, false,false,false,Vector2(1,2))

	for i in range(city_ysize):
		$TileMap.set_cell(-1,i,trees_id, false,false,false,Vector2(0,1))
		$TileMap.set_cell(city_xsize,i,trees_id, false,false,false,Vector2(2,1))
		
	$TileMap.set_cell(-1,-1,trees_id, false,false,false,Vector2(0,0))
	$TileMap.set_cell(city_xsize, city_ysize,trees_id, false,false,false,Vector2(2,2))
	$TileMap.set_cell(city_xsize,-1,trees_id, false,false,false,Vector2(2,0))
	$TileMap.set_cell(-1, city_ysize,trees_id, false,false,false,Vector2(0,2))
	for i in range(city_xsize):
		for j in range(city_ysize):
			$TileMap.set_cell(i,j, city[i][j])

	$TileMap.update_bitmask_region(Vector2(1,1), Vector2(city_xsize-2,city_ysize-2))

func create_human(human) :
	var h = human.instance()

	var x = rng.randi_range(0,city_xsize-1)
	var y = rng.randi_range(0,city_ysize-1)
	#make sure it doesn't stand on a wall
#	while city[x][y] == $TileMap.tile_set.find_tile_by_name("walls"):
#		x = x-1
#		if x< 0 :
#			x = city_xsize
	h.position = Vector2(x*tilesize+tilesize/2,y*tilesize+tilesize/2)
	add_child(h)
	human_list.append(h);
	return h
	
func make_humans():
	var human = load("Human.tscn")
	human_list = [];
	for n in range(nhumans):
		#create humans		
		create_human(human)
	
	#create patient 0:
	var h = create_human(human)
	h.go_zombie()
	control_zombie(h)

func control_zombie( zombie ):
	if (controlled != null ):
		controlled.controlled = false
	controlled = zombie
	zombie.control_me()
	
