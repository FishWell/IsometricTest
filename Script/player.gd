extends CharacterBody2D

@export var move_range := 5
@export var tilemap: TileMapLayer
@export var deck_size: int = 5
@export var power_min: int = 1
@export var power_max: int = 5
@export var health: int = 20
@onready var turn_mngr := $"../TurnManager"
@onready var astar_mngr = $"../ASM"
@onready var astar : AStarGrid2D = astar_mngr.astar
var current_path: Array = []
var speed := 100.0
var debug_path: Array = []
enum States { IDLE, READY, MOVING }
var state = States.IDLE
var playable := true

func on_turn(val : bool):
	playable = val
	change_state(States.IDLE)

func change_state(st):
	if not playable : return
	var reachable = get_reachable(tilemap.local_to_map(global_position), move_range)
	if st == States.READY: for cell in reachable.keys():
		if cell: tilemap.set_cell(cell,0,Vector2i(0,1))
	else: for cell in reachable.keys(): tilemap.erase_cell(cell)
	print("STATE: ", st)
	state = st

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("move") and event.pressed :
		if state == States.IDLE: change_state(States.READY)
		elif state == States.READY: change_state(States.IDLE)
	
func _unhandled_input(event):
	var mouse_pos = get_global_mouse_position()
	if event.is_action_pressed("move") and state == States.READY:
		var start = tilemap.local_to_map(global_position)
		var end = tilemap.local_to_map(mouse_pos)
		var path = astar.get_id_path(start, end)
		current_path.clear()
		path.pop_front()
		if path.size() <= move_range and path.size() > 0:
			change_state(States.MOVING)
			for cell in path:
				current_path.append(tilemap.map_to_local(cell))

func _process(delta):
	if current_path.is_empty(): return
	var target = current_path[0]
	var direction = (target - global_position).normalized()
	global_position += direction * speed * delta
	if global_position.distance_to(target) < 4:
		global_position = target
		current_path.pop_front()
		if current_path.is_empty(): turn_mngr.end_turn()

func get_reachable(start: Vector2i, max_dist: int) -> Dictionary:
	astar_mngr.update_unit_blocking()
	var visited := {}
	var queue := []
	queue.append({"pos": start, "dist": 0})
	visited[start] = 0
	while queue.size() > 0:
		var current = queue.pop_front()
		var pos = current.pos
		var dist = current.dist
		if dist >= max_dist: continue
		var neighbors = [
			pos + Vector2i(1, 0),
			pos + Vector2i(-1, 0),
			pos + Vector2i(0, 1),
			pos + Vector2i(0, -1),
		]
		for n in neighbors:
			if not astar.is_in_boundsv(n): continue
			if astar.is_point_solid(n): continue
			if visited.has(n): continue
			visited[n] = dist + 1
			queue.append({"pos": n, "dist": dist + 1})
	return visited
