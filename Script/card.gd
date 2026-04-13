extends Control

@onready var icon := $Hands
@onready var animation := $Animation

@export var type : hands = hands.ROCK
@export var power : int = 99

enum hands {ROCK,PAPER,SCISSORS}
var is_selected: bool = false
var hand = {
	hands.ROCK: preload("res://Sprite/hands0.png"),
	hands.PAPER: preload("res://Sprite/hands1.png"),
	hands.SCISSORS: preload("res://Sprite/hands2.png")
}
var indeck : bool = true

signal card_clicked(card)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func setup(inputted_type, atk):
	icon.texture = hand[inputted_type]
	type = inputted_type
	$Label.text = str(atk)
	power = atk

func _on_button_pressed() -> void:
	emit_signal("card_clicked", self)

func card_selected():
	if indeck: 
		if is_selected:
			is_selected = false
			animation.play("selected")
			return
		is_selected = true
		animation.play("hover")


func _on_mouse_entered() -> void:
	z_index += 1
	scale = Vector2(1.1,1.1)
	if is_selected or not indeck:
		return
	animation.play("default")


func _on_mouse_exited() -> void:
	z_index -= 1
	scale = Vector2(1,1)
	if is_selected or not indeck:
		return
	animation.play("selected")
