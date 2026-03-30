extends Node2D

@export var tilemap : TileMapLayer

func _ready() -> void:
	queue_redraw()

func _draw():
	for cell in tilemap.get_used_cells():
		var world_pos = tilemap.to_global(tilemap.map_to_local(cell))
		var local_pos = to_local(world_pos)

		var text = str(cell)
		var font = ThemeDB.fallback_font
		var size = 4

		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size)

		var pos = local_pos - text_size / 2 + Vector2(0, 4)

		draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color("black"))
		draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size)
