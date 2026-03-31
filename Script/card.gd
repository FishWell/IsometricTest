extends Control

@onready var icon := $Hands
@onready var bg := $BG
@onready var animation := $Animation
enum hands {ROCK,PAPER,SCISSORS}
var is_selected: bool = false
var hand = {
	hands.ROCK: preload("res://Sprite/hands0.png"),
	hands.PAPER: preload("res://Sprite/hands1.png"),
	hands.SCISSORS: preload("res://Sprite/hands2.png")
}
var bg_type = {
	"Card": preload("res://Sprite/bg.png"),
	"Dialog": preload("res://Sprite/diabox.png")
}
var indeck : bool = true

signal card_clicked(card)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func setup(type, atk):
	bg.texture = bg_type.get("Card")
	icon.texture = hand[type]
	$Label.text = str(atk)

func pop_dialog(type, win):
	bg.texture = bg_type["Dialog"]
	icon.texture = hand[type]
	$Button.disabled = true
	animation.play(win)


func _on_button_pressed() -> void:
	emit_signal("card_clicked", self)

func card_selected():
	if indeck: 
		if is_selected:
			is_selected = false
			animation.play("selected")
			#print("Unselected")
			return
		#print("Selected")
		is_selected = true
		animation.play("hover")


func _on_mouse_entered() -> void:
	position.y -= 10
	z_index += 1
	scale = Vector2(1.2,1.2)
	if is_selected or not indeck: return
	animation.play("default")


func _on_mouse_exited() -> void:
	position.y += 10
	z_index -= 1
	scale = Vector2(1,1)
	if is_selected or not indeck: return
	animation.play("selected")
