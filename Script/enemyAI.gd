extends CharacterBody2D

signal turn_finished

enum hands{ROCK, PAPER, SCISSORS, NONE}

@export var move_range := 5
@export var speed := 200.0
@export var health := 10
@export var damage_range := [1,5]
@export var decks: Array[hands] = [
	hands.NONE,
	hands.ROCK,hands.ROCK,
	hands.PAPER,hands.PAPER,
	hands.SCISSORS,hands.SCISSORS
	]
@export var nama: String = "Enemy"

@onready var hand : hands = hands.ROCK
@onready var tilemap : TileMapLayer = $"../Ground"
@onready var player : CharacterBody2D = $"../Player"
@onready var astar_mngr = $"../ASM"
@onready var state = $"../TurnManager"
@onready var saying : Control = $DialogBox
@onready var gui : CanvasLayer = $"../Ui"
@onready var original_pos: Vector2 = position

var path : Array = []
var moving := false
var can_attack := false
var shake_tween: Tween

func _ready() -> void:
	nama = generate_name()

func generate_name():
	var vowels := "aiueoyAIUEOY"
	var characters := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	var result := ""
	
	for i in range(randi_range(5,10)):
		if result.length() < 3 or \
			vowels.contains(result.right(1)) or \
			vowels.contains(result.right(2)) or \
			vowels.contains(result.right(3)): 
			print("right3: ", result.right(3), "right2: ", result.right(2), "right1: ", result.right(1))
			result += characters[randi() % characters.length()]
		else : result += vowels[randi_range(0,5)]
	return result.to_lower().capitalize()

func show_attack(_show: bool):
	if _show:
		saying.show()
		saying.setup(hand)
	else :
		saying.hide()

func take_turn():
	astar_mngr.update_unit_blocking()
	var start = tilemap.local_to_map(global_position)
	var target = tilemap.local_to_map(player.global_position)
	var full_path = astar_mngr.astar.get_id_path(start, target)
	if full_path.size() > move_range + 1:
		full_path = full_path.slice(0, move_range + 1)
	path.clear()
	for cell in full_path: path.append(tilemap.map_to_local(cell))
	moving = true
	
func _process(delta: float) -> void:
	if not moving: return
	var diff = tilemap.local_to_map(global_position) - tilemap.local_to_map(player.global_position)
	if path.is_empty():
		moving = false
		update_hand()
		if abs(diff.x) + abs(diff.y) == 1: can_attack = true
		turn_finished.emit()
		return
	var target = path[0]
	var dir = (target - global_position).normalized()
	if abs(diff.x) + abs(diff.y) == 1:
		path.clear()
		return
	else :
		global_position += dir * speed * delta
		if global_position.distance_to(target) < 8:
			path.pop_front()
			global_position = target

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("move") and event.pressed :
		update_hand()
		player.enemy_clicked(self)

func update_hand():
	hand = decks.pick_random()
	if hand == hands.NONE : hand = decks.pick_random()

func update_stat():
	return

func _on_mouse_entered() -> void:
	if state.state == state.States.PREPARATION: return
	gui.enemy_stat_show(true, health, move_range, damage_range, decks, nama)

func _on_mouse_exited() -> void:
	if state.state == state.States.PREPARATION: return
	gui.enemy_stat_show(false)

func attacked(hit: bool):
	if not hit: return
	if health <= 0:
		gui.show_enemyUI(false)
		queue_free()
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
	shake_tween = create_tween()
	var strength = 0.1
	var duration = 0.1
	for i in range(3):
		shake_tween.tween_property(self, "position:x", original_pos.x - strength, duration)
		shake_tween.tween_property(self, "position:x", original_pos.x + strength, duration)
	shake_tween.tween_property(self, "position", original_pos, duration)
