extends Node2D

var astar := AStarGrid2D.new()
var static_walls := {}
@onready var tilemap : TileMapLayer = $"../Obstacle"
@onready var player : CharacterBody2D = $"../Player"

func _ready():
	astar.region = tilemap.get_used_rect()
	astar.cell_size = Vector2i(1, 1) # IMPORTANT: grid space, not pixels
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.update()
	bake_static_obstacles()
	

func bake_static_obstacles():
	for cell in tilemap.get_used_cells():
		var tile_data = tilemap.get_cell_tile_data(cell)
		if tile_data:
			static_walls[cell] = true
			astar.set_point_solid(cell, true)

func update_unit_blocking():
	var rect = tilemap.get_used_rect()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var cell = Vector2i(x, y)
			astar.set_point_solid(cell, false)
	for cell in static_walls.keys():
		astar.set_point_solid(cell, true)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var cell = tilemap.local_to_map(enemy.global_position)
		astar.set_point_solid(cell, true)
