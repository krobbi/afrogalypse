## A navigable stack of [GUICard]s.
class_name GUIStack
extends Control

## Whether the current [GUICard] was accessed from the [MainGUICard].
static var is_from_main_card: bool = false

## The stack of current [GUICard] names.
var _card_stack: Array[String] = []

## The current [GUICard] to display. [code]null[/code] if no [GUICard] is being
## displayed.
var _card: GUICard = null

## Whether the current [GUICard] is updating.
var _is_updating: bool = false

## The [AudioStreamPlayer] to play when a [GUICard] is changed or closed.
@onready var _navigate_player: AudioStreamPlayer = $NavigatePlayer

## Change to a root [GUICard] from its name.
func change_card(card_name: String) -> void:
	if not _is_updating:
		_card_stack.resize(1)
		_card_stack[0] = card_name
		_update_card()


## Clear the stack of [GUICard]s.
func close_card() -> void:
	if not _is_updating:
		_card_stack.clear()
		_update_card()


## Update the current [GUICard] from the card stack.
func _update_card() -> void:
	_is_updating = true
	
	if _card:
		if _card.change_requested.is_connected(change_card):
			_card.change_requested.disconnect(change_card)
		
		if _card.close_requested.is_connected(close_card):
			_card.close_requested.disconnect(close_card)
		
		_navigate_player.play()
		await create_tween().tween_property(_card, "modulate", Color.TRANSPARENT, 0.1).finished
		_card.queue_free()
	
	if _card_stack.is_empty():
		_card = null
	else:
		var card_name: String = _card_stack[-1]
		
		# Should probably find a better solution for this.
		if card_name == "main":
			is_from_main_card = true
		elif card_name == "options":
			is_from_main_card = false
		
		_card = load("res://gui/cards/%s_gui_card.tscn" % card_name).instantiate()
		_card.modulate = Color.TRANSPARENT
		_card.change_requested.connect(change_card)
		_card.close_requested.connect(close_card)
		add_child(_card)
		await create_tween().tween_property(_card, "modulate", Color.WHITE, 0.1).finished
		
		var focus: Node = get_tree().get_first_node_in_group("focus")
		
		if focus is Control:
			focus.grab_focus()
	
	_is_updating = false
