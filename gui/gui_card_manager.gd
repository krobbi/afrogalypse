extends Control

var card: Control = null
var is_changing: bool = false

@onready var navigate_player: AudioStreamPlayer = $NavigatePlayer

func _ready() -> void:
	Global.gui_card_changed.connect(change_card)


func change_card(card_name: String) -> void:
	if is_changing:
		return
	
	is_changing = true
	
	if card:
		navigate_player.play()
		var tween: Tween = card.create_tween()
		tween.tween_property(card, "modulate", Color.TRANSPARENT, 0.1)
		await tween.finished
		card.queue_free()
	
	if card_name.is_empty():
		card = null
		is_changing = false
		return
	
	card = load("res://gui/cards/%s_gui_card.tscn" % card_name).instantiate()
	card.modulate = Color.TRANSPARENT
	add_child(card)
	var tween: Tween = card.create_tween()
	tween.tween_property(card, "modulate", Color.WHITE, 0.1)
	await tween.finished
	
	var focus: Node = get_tree().get_first_node_in_group("focus")
	
	if focus is Control:
		focus.grab_focus()
	
	is_changing = false
