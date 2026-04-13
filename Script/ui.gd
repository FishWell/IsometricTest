extends CanvasLayer

signal end_turn_pressed
@onready var black_bar : Control = $"decksUI"
@onready var menuUI : Control = $"menuUI"
@onready var end_button : Button = $"menuUI/Decks/EndTurnButton"
@onready var move_button : Button = $"menuUI/Decks/Move"
@onready var attack_button : Button = $"menuUI/Decks/Attack"
@onready var scrollui : ScrollContainer = $"decksUI/Scroll"
@onready var decks : GridContainer = $"decksUI/Scroll/Decks"
@onready var hands : HBoxContainer = $Hands
@onready var phases : Label = $Phases
@onready var state: Node2D = $"../TurnManager"
@onready var player : CharacterBody2D = $"../Player"
@onready var playerUI : Control = $playerUI
@onready var playerHealth : Label = $"playerUI/HP"
@onready var playerAttack : Label = $"playerUI/Attack"
@onready var playerDecks : Label = $"playerUI/Decks"
@onready var playerMove : Label = $"playerUI/Move"
@onready var enemyUI : Control = $enemyUI
@onready var enemyname : Label = $"enemyUI/Name"
@onready var enemyHealth : Label = $"enemyUI/HP"
@onready var enemyAttack : Label = $"enemyUI/Attack"
@onready var enemyDecks : Label = $"enemyUI/Decks"
@onready var enemyMove : Label = $"enemyUI/Move"
@onready var card_left : Label = $"decksUI/Cardleft"

var cards = preload("res://Scene/Card.tscn")
var deck := []
var hand := []
var preparing : bool = true
var playerstat := {
	"HP":0,
	"deckSize":0,
	"handSize":0,
	"minPower":0,
	"maxPower":0,
	"move":0
}

func get_player_stat():
	playerstat.set("HP",player.health)
	playerstat.set("deckSize",player.deck_size)
	playerstat.set("handSize",player.hand_size)
	playerstat.set("minPower",player.power_min)
	playerstat.set("maxPower",player.power_max)
	playerstat.set("move",player.move_range)

func update_ui():
	get_player_stat()
	playerHealth.text = str(playerstat.get("HP"))
	playerAttack.text = str(playerstat.get("minPower")) + "-" + str(playerstat.get("maxPower"))
	playerDecks.text = str(playerstat.get("handSize")) + "/" + str(playerstat.get("deckSize"))
	playerMove.text = "Move " + str(playerstat.get("move"))

func show_enemyUI(showing: bool):
	if showing:
		enemyUI.show()
		menuUI.hide()
	else:
		enemyUI.hide()
		if state.state == state.States.PLAYER_TURN or state.state == state.States.PREPARATION: menuUI.show()

func enemy_stat_show(showstats: bool, hp: int = 0, move: int = 0, dmg: Array = [0,0], deckss: Array = [0], nama: String = "Enemy" ):
	if not showstats:
		show_enemyUI(false)
		return
	show_enemyUI(true)
	enemyname.text = nama
	enemyHealth.text = str(hp)
	enemyAttack.text = str(dmg[0]) + "-" + str(dmg[1])
	enemyDecks.text = \
		"R" + str(deckss.count(0)) + \
		" P" + str(deckss.count(1)) + \
		" S" + str(deckss.count(2)) + \
		" X" + str(deckss.count(3))
	enemyMove.text = "Move " + str(move)

func _on_button_pressed() -> void:
	end_turn_pressed.emit()
	if preparing: preparing = false

func disable_end_button(dis: bool):
	end_button.disabled = dis

func refreshdeck():
	get_player_stat()
	if deck.size() > 0: return
	for card in deck: card.queue_free()
	deck.clear()
	for child in decks.get_children(): child.queue_free()
	for i in range(playerstat.get("deckSize")):
		var type : int = randi_range(0,2)
		var power : int = randi_range(playerstat.get("minPower"),playerstat.get("maxPower"))
		drawdeck(type, power)

func drawdeck(type, power):
	var new_card = cards.instantiate()
	decks.add_child(new_card)
	new_card.setup(type, power)
	new_card.card_clicked.connect(select_card)
	deck.append(new_card)
	#update_spacing(decks)
	return
	
func drawhand():
	decks.hide()
	black_bar.hide()
	hand.reverse()
	for card in hand:
		card.animation.play("default")
		decks.remove_child(card)
		hands.add_child(card)
		deck.erase(card)

func select_card(card):
	if not preparing: return
	if not card.is_selected:
		if hand.size() > playerstat.get("handSize") - 1: return
		hand.append(card)
	else: hand.erase(card)
	update_decks_ui()
	card.card_selected()

func discardhand():
	for card in hand: 
		card.queue_free()
	hand.clear()
	black_bar.show()
	decks.show()
	update_decks_ui()
	
func update_decks_ui():
	card_left.text = str(playerstat.get("handSize") - hand.size()) + " / " + str(playerstat.get("handSize"))
	return

func play_hand(win):
	if hands.get_children().size() < 1 : return
	hand.pop_back()
	var played_hand = hands.get_children()[-1]
	if win: played_hand.animation.play("win")
	else: played_hand.animation.play("lose")
	await played_hand.animation.animation_finished
	played_hand.queue_free()

func _on_scroll_gui_input(event: InputEvent) -> void:
	#print(scrollui.size.y)
	var page_size = scrollui.size.y
	if event.is_action_released("move") : 
		scrollui.scroll_vertical -= 1
		print(scrollui.scroll_vertical, "/", page_size)
	if event.is_action_released("scrolldown") : 
		var calibrated_page_size = page_size -4
		@warning_ignore("narrowing_conversion")
		if fmod(scrollui.scroll_vertical, calibrated_page_size): scrollui.scroll_vertical = ceilf(scrollui.scroll_vertical/calibrated_page_size) * calibrated_page_size
		print(scrollui.scroll_vertical, "/", page_size)
	if event.is_action_released("scrollup") :
		var calibrated_page_size = page_size -4
		@warning_ignore("narrowing_conversion")
		if fmod(scrollui.scroll_vertical, calibrated_page_size): scrollui.scroll_vertical = floorf(scrollui.scroll_vertical/calibrated_page_size) * calibrated_page_size
		print(scrollui.scroll_vertical, "/", page_size)
		
		



#func update_spacing(kontainer: GridContainer):
	#var konten = kontainer.get_children()
	#var count = konten.size()
	#if count == 0: return
	#var container_width = kontainer.size.x / 2
	#var separation = container_width / max(count - 1, 1)
	#separation = clamp(separation, 10, 40)
	#decks.add_theme_constant_override("h_separation", separation)
	#decks.add_theme_constant_override("v_separation", separation)
