extends Control

@onready var icon := $Hands

enum hands {ROCK,PAPER,SCISSORS,NONE}
var hand = {
	hands.ROCK: preload("res://Sprite/hands0.png"),
	hands.PAPER: preload("res://Sprite/hands1.png"),
	hands.SCISSORS: preload("res://Sprite/hands2.png")
}

func setup(type: int):
	if type == hands.NONE:
		icon.hide()
		return
	icon.show()
	icon.texture = hand[type]
