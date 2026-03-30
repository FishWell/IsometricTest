extends CharacterBody2D

signal turn_finished

@export var move_range := 5
@export var speed := 200.0

@onready var tilemap : TileMapLayer = $"../Obstacle"
@onready var player : CharacterBody2D = $"../Player"
@onready var astar_mngr = $"../ASM"
@onready var astar : AStarGrid2D = astar_mngr.astar
var path : Array = []
var moving := false

func take_turn():
	astar_mngr.update_unit_blocking()
	var start = tilemap.local_to_map(global_position)
	var target = tilemap.local_to_map(player.global_position)
	var full_path = astar.get_id_path(start, target)
	if full_path.size() > move_range + 1:
		full_path = full_path.slice(0, move_range + 1)
	path.clear()
	for cell in full_path: path.append(tilemap.map_to_local(cell))
	moving = true
	
func _process(delta: float) -> void:
	if not moving: return
	if path.is_empty():
		var diff = tilemap.local_to_map(global_position) - tilemap.local_to_map(player.global_position)
		if abs(diff.x) + abs(diff.y) == 1: print("Attack")
		moving = false
		emit_signal("turn_finished")
		return
	var target = path[0]
	var dir = (target - global_position).normalized()
	if target == player.position : path.pop_front()
	else :
		global_position += dir * speed * delta
		if global_position.distance_to(target) < 4:
			path.pop_front()
			global_position = target
