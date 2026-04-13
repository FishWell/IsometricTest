extends Node

enum States { PLAYER_TURN, ENEMY_TURN, BUSY, PREPARATION }
var state = States.PREPARATION

@onready var player: CharacterBody2D = $"../Player"
@onready var gui: CanvasLayer = $"../Ui"
@onready var battle = $"../BattleManager"

@onready var phaseText : Label = gui.phases

var enemies: Array = []
var current_enemy_index := 0


func _ready() -> void:
	enemies = get_tree().get_nodes_in_group("enemy")
	gui.end_turn_pressed.connect(end_turn)
	gui.refreshdeck()
	gui.update_ui()
	gui.update_decks_ui()

func change_states(new_state):
	if typeof(new_state) == TYPE_INT: state = new_state
	elif typeof(new_state) == TYPE_STRING: state = States.get(new_state)
	print(States.keys()[state])

func player_turn():
	gui.drawhand()
	phaseText.text = "PLAYER TURN"
	change_states(States.PLAYER_TURN)
	player.on_turn(true)
	gui.disable_end_button(false)

func preparing():
	phaseText.text = "PICK YOUR HANDS!"
	change_states(States.PREPARATION)
	gui.show_enemyUI(false)
	gui.disable_end_button(false)
	gui.discardhand()
	gui.refreshdeck()
	gui.preparing = true

func end_turn():
	enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0: get_tree().quit()
	if state == States.PREPARATION:
		player_turn()
		return
	player.on_turn(true)
	player.on_turn(false)
	gui.disable_end_button(true)
	change_states(States.ENEMY_TURN)
	current_enemy_index = 0
	for enemy in enemies:
		enemy.can_attack = false
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
	if not enemy.can_attack: enemy.take_turn()
	await enemy.turn_finished
	if enemy.can_attack:
		change_states(States.BUSY)
		enemy.show_attack(true)
		await battle.enemy_attack(enemy.damage_range, enemy.hand)
		enemy.show_attack(false)
		change_states(States.ENEMY_TURN)
	current_enemy_index += 1
	enemy_turn()
