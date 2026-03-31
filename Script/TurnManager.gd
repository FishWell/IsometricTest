extends Node

enum States { PLAYER_TURN, ENEMY_TURN, BUSY, PREPARATION }
var state = States.PREPARATION

@onready var player: CharacterBody2D = $"../Player"
@onready var gui: CanvasLayer = $"../Ui"
@onready var phaseText : Label = gui.phases

var enemies: Array = []
var current_enemy_index := 0


func _ready() -> void:
	enemies = get_tree().get_nodes_in_group("enemy")
	gui.end_turn_pressed.connect(end_turn)
	gui.get_player_stat(player.health, player.deck_size, player.power_min, player.power_max)
	gui.refreshdeck()

func player_turn():
	phaseText.text = "PLAYER TURN"
	state = States.PLAYER_TURN
	player.on_turn(true)
	gui.disable_end_button(false)

func preparing():
	phaseText.text = "PICK YOUR HANDS!"
	state = States.PREPARATION
	gui.disable_end_button(false)
	gui.discardhand()
	gui.drawhand(true)
	gui.preparing = true

func end_turn():
	if state == States.PREPARATION:
		player_turn()
		return
	player.on_turn(true)
	player.on_turn(false)
	gui.disable_end_button(true)
	state = States.ENEMY_TURN
	current_enemy_index = 0
	enemy_turn()

func enemy_turn():
	phaseText.text = "ENEMY TURN..."
	if current_enemy_index >= enemies.size():
		preparing()
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
