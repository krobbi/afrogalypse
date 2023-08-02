## Manages changing between [GUICard]s.
class_name GUICardManager
extends Control

## The current [GUICard] to display. [code]null[/code] if no [GUICard] is being
## displayed.
var _card: GUICard = null

## Whether the current [GUICard] is changing.
var _is_changing: bool = false

## The [AudioStreamPlayer] to play when a [GUICard] is changed or closed.
@onready var _navigate_player: AudioStreamPlayer = $NavigatePlayer

## Change the current [GUICard] from its name. Close the current [GUICard] if
## [param card_name] is empty.
func change_card(card_name: String) -> void:
	if _is_changing:
		return
	
	_is_changing = true
	
	if _card:
		_navigate_player.play()
		await create_tween().tween_property(_card, "modulate", Color.TRANSPARENT, 0.1).finished
		_card.queue_free()
	
	if card_name.is_empty():
		_card = null
		_is_changing = false
		return
	
	_card = load("res://gui/cards/%s_gui_card.tscn" % card_name).instantiate()
	_card.modulate = Color.TRANSPARENT
	_card.change_requested.connect(change_card, CONNECT_ONE_SHOT)
	add_child(_card)
	await create_tween().tween_property(_card, "modulate", Color.WHITE, 0.1).finished
	
	var focus: Node = get_tree().get_first_node_in_group("focus")
	
	if focus is Control:
		focus.grab_focus()
	
	_is_changing = false
