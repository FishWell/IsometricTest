extends CharacterBody2D

@export var move_range := 5
@export var deck_size: int = 5
@export var hand_size: int = 3
@export var power_min: int = 1
@export var power_max: int = 5
@export var health: int = 20
@export var attack_range: int = 1

@onready var ground: TileMapLayer = $"../Ground"
@onready var obstacle: TileMapLayer = $"../Obstacle"
@onready var turn_mngr := $"../TurnManager"
@onready var astar_mngr = $"../ASM"
@onready var battle_mngr : Node2D = $"../BattleManager"
@onready var astar : AStarGrid2D = astar_mngr.astar
@onready var original_pos: Vector2 = position

var shake_tween: Tween
var current_path: Array = []
var speed := 100.0
var debug_path: Array = []
enum States { IDLE, READY, MOVING , COMBAT}
var state = States.IDLE
var playable := true


func on_turn(val : bool):
	playable = val
	change_state(States.IDLE)


func attacked(hit: bool):
	if hit: return
	if health <= 0:
		queue_free()
		get_tree().quit()
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
	shake_tween = create_tween()
	var strength = 1.0
	var duration = 0.1
	for i in range(3):
		shake_tween.tween_property(self, "position:x", original_pos.x - strength, duration)
		shake_tween.tween_property(self, "position:x", original_pos.x + strength, duration)
	shake_tween.tween_property(self, "position", original_pos, duration)

func change_state(st):
	if not playable : return
	var reachable = get_attack_range(ground.local_to_map(global_position))
	if st == States.READY:
		reachable = get_reachable(obstacle.local_to_map(global_position), move_range)
		for cell in reachable.keys(): if cell: obstacle.set_cell(cell,0,Vector2i(0,1))
	elif st == States.COMBAT:
		reachable = get_attack_range(ground.local_to_map(global_position), false)
		print(reachable)
		for cell in reachable.keys(): if cell: obstacle.set_cell(cell,0,Vector2i(1,1))
		#var enemies = get_tree().get_nodes_in_group("enemy")
	else: for cell in reachable.keys(): if cell: obstacle.erase_cell(cell)
	print("STATE: ", st)
	state = st

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("move") and event.pressed :
		if state == States.IDLE: change_state(States.READY)
		elif state == States.READY: change_state(States.IDLE)
	
func _unhandled_input(event):
	var mouse_pos = get_global_mouse_position()
	if event.is_action_pressed("move") and state == States.READY:
		var start = ground.local_to_map(global_position)
		var end = ground.local_to_map(mouse_pos)
		var path = astar.get_id_path(start, end)
		current_path.clear()
		path.pop_front()
		if path.size() <= move_range and path.size() > 0:
			change_state(States.MOVING)
			for cell in path:
				current_path.append(ground.map_to_local(cell))
	#if event.is_action_pressed("move") and state == States.COMBAT:
		#turn_mngr.end_turn()

func enemy_clicked(enemy_target):
	if state == States.COMBAT:
		var diff = ground.local_to_map(enemy_target.global_position) - ground.local_to_map(global_position)
		if abs(diff.x) + abs(diff.y) <= attack_range: battle_mngr.player_attack(enemy_target)

func _process(delta):
	if current_path.is_empty(): return
	var target = current_path[0]
	var direction = (target - global_position).normalized()
	global_position += direction * speed * delta
	if global_position.distance_to(target) < 4:
		global_position = target
		original_pos = position
		current_path.pop_front()
		if current_path.is_empty(): change_state(States.COMBAT)

func get_attack_range(start: Vector2i, check_range: bool = true) -> Dictionary:
	var visited : Dictionary = {}
	var rect = ground.get_used_rect()
	var obs = astar_mngr.get_obs_tiles()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var cell = Vector2i(x, y)
			var diff = start - cell
			var distance = abs(diff.x) + abs(diff.y)
			if distance <= attack_range or check_range: 
				if not obs.has(cell) and cell != start: visited[cell] = range
	return visited

func get_reachable(start: Vector2i, max_dist: int) -> Dictionary:
	astar_mngr.update_unit_blocking()
	var visited := {}
	var queue := []
	queue.append({"pos": start, "dist": 0})
	#visited[start] = 0
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
			if n != start: visited[n] = dist + 1
			queue.append({"pos": n, "dist": dist + 1})
	return visited
