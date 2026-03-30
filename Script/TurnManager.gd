extends Node

enum States { PLAYER_TURN, ENEMY_TURN, BUSY }
var state = States.PLAYER_TURN

@onready var player: CharacterBody2D = $"../Player"
@onready var gui: CanvasLayer = $"../Ui"

var enemies: Array = []
var current_enemy_index := 0

func _ready() -> void:
	enemies = get_tree().get_nodes_in_group("enemy")
	gui.end_turn_pressed.connect(end_turn)

func player_turn():
	state = States.PLAYER_TURN
	player.on_turn(true)
	gui.disable_end_button(false)


func end_turn():
	player.on_turn(true)
	player.on_turn(false)
	gui.disable_end_button(true)
	state = States.ENEMY_TURN
	current_enemy_index = 0
	enemy_turn()

func enemy_turn():
	if current_enemy_index >= enemies.size():
		player_turn()
		return
	var enemy = enemies[current_enemy_index]
	if not enemy:
		current_enemy_index += 1
		enemy_turn()
		return
	state = States.BUSY
	enemy.take_turn()
	await enemy.turn_finished
	current_enemy_index += 1
	enemy_turn()
