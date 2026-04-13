extends Node

enum CardType {ROCK,PAPER,SCISSORS,NONE}
@onready var player : CharacterBody2D = $"../Player"
@onready var gui : CanvasLayer = $"../Ui"
@onready var state : Node2D = $"../TurnManager"

func rps_result(a: CardType, b: CardType = CardType.NONE) -> int:
	if (a == CardType.ROCK and b == CardType.SCISSORS) \
	or (a == CardType.PAPER and b == CardType.ROCK) \
	or (a == CardType.SCISSORS and b == CardType.PAPER) \
	or b == CardType.NONE:
		return 1
	return 0

func enemy_attack(_range: Array, type: int = 0):
	var player_card = CardType.NONE
	if gui.hand.size() > 0 : player_card = gui.hand[-1].type
	var win : int = rps_result(type,player_card)
	player.health -= win * randi_range(_range[0],_range[1])
	await player.attacked(not bool(win))
	await gui.play_hand(not bool(win))
	gui.update_ui()
	return

func player_attack(enemy):
	if state.state == state.States.BUSY: return
	var player_type = CardType.NONE
	var damage = 0
	if gui.hand.size() > 0 :
		player_type = gui.hand[-1].type
		damage = gui.hand[-1].power
	print(player_type, " VS ", enemy.hand)
	var win : int = rps_result(player_type,enemy.hand)
	enemy.health -= win * damage
	state.change_states(state.States.BUSY)
	await enemy.attacked(bool(win))
	await gui.play_hand(bool(win))
	state.change_states(state.States.PLAYER_TURN)
	gui.update_ui()
	return
