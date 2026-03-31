extends CanvasLayer

signal end_turn_pressed
@onready var end_button : Button = $EndTurnButton
@onready var decks : HBoxContainer = $Decks
@onready var phases : Label = $Phases
var cards = preload("res://Scene/Card.tscn")
var deck := []
var hand := []
var preparing : bool = true
var playerstat := {
	"maxHP":20,
	"handSize":5,
	"minPower":5,
	"maxPower":5
}

func get_player_stat(hp,hs,minp,maxp):
	playerstat.set("maxHP",hp)
	playerstat.set("handSize",hs)
	playerstat.set("minPower",minp)
	playerstat.set("maxPower",maxp)

func _on_button_pressed() -> void:
	end_turn_pressed.emit()
	if preparing: preparing = false
	drawhand()

func disable_end_button(dis: bool):
	end_button.disabled = dis

func refreshdeck():
	for card in deck:
		card.queue_free()
	deck.clear()
	for child in decks.get_children(): child.queue_free()
	for i in range(playerstat.get("handSize")):
		var type : int = randi_range(0,2)
		var power : int = randi_range(playerstat.get("minPower"),playerstat.get("maxPower"))
		drawdeck(type, power)

func drawdeck(type, power):
	var new_card = cards.instantiate()
	decks.add_child(new_card)
	new_card.setup(type, power)
	new_card.card_clicked.connect(select_card)
	deck.append(new_card)
	return
	
func drawhand(refill: bool = false): #Refill here means after each turn reshow the hidden cards
	if refill: print("Is Refilling...")
	print("Deck size is: ", deck.size())
	if refill and deck.size() < 1:
		refreshdeck()
		return
	for card in decks.get_children():
		if card not in hand and not refill: card.hide()
		else:card.show()

func select_card(card):
	if not preparing: return
	if not card.is_selected:
		if hand.size() > 2: return
		hand.append(card)
	else: hand.erase(card)
	card.card_selected()
	#print("DECK: ", deck)
	#print("HAND: ", hand)

func discardhand():
	for card in hand:
		card.queue_free()
		deck.erase(card)
	hand.clear()
