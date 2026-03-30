extends CanvasLayer

signal end_turn_pressed
@onready var end_button : Button = $EndTurnButton
@onready var decks : HBoxContainer = $Decks
var card = preload("res://Scene/Card.tscn")
var deck := []
var hand := []


func _ready() -> void:
	refreshdeck(5,1,10)

func _on_button_pressed() -> void:
	end_turn_pressed.emit()

func disable_end_button(dis: bool):
	end_button.disabled = dis

func refreshdeck(size, floor, ceiling):
	deck = []
	for child in decks.get_children(): child.queue_free()
	for i in range(size):
		var type : int = randi_range(0,2)
		var power : int = randi_range(floor,ceiling)
		deck.append([type,power])
		drawdeck(type, power)

func drawdeck(type, power):
	var new_card = card.instantiate()
	decks.add_child(new_card)
	new_card.setup(type, power)
	new_card.card_clicked.connect(select_card)
	return

func addHands(card):
	if hand.size() > 3: return
	hand.append(card)

func select_card(card):
	return

func emptydeck():
	return
