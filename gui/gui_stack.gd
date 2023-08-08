## A navigable stack of [GUICard]s.
class_name GUIStack
extends Control

## Emitted when a root [GUICard] is popped.
signal root_popped

## The stack of current [GUICard] names.
var _card_stack: Array[String] = []

## The current [GUICard] to display. [code]null[/code] if no [GUICard] is being
## displayed.
var _card: GUICard = null

## Whether the current [GUICard] is updating.
var _is_updating: bool = false

## The [AudioStreamPlayer] to play when a [GUICard] is changed or closed.
@onready var _navigate_player: AudioStreamPlayer = $NavigatePlayer

## Push a [GUICard] to the GUI stack from its name.
func push_card(card_name: String) -> void:
	if not _is_updating:
		_card_stack.push_back(card_name)
		_update_card()


## Pop a [GUICard] from the GUI stack. Emit [signal root_popped] if the root
## [GUICard] was popped.
func pop_card() -> void:
	if not _is_updating and not _card_stack.is_empty():
		_card_stack.pop_back()
		_update_card()
		
		if _card_stack.is_empty():
			root_popped.emit()


## Change to a root [GUICard] from its name.
func change_card(card_name: String) -> void:
	if not _is_updating:
		_card_stack.resize(1)
		_card_stack[0] = card_name
		_update_card()


## Update the current [GUICard] from the card stack.
func _update_card() -> void:
	_is_updating = true
	
	if _card:
		_card.push_requested.disconnect(push_card)
		_card.pop_requested.disconnect(pop_card)
		_card.change_requested.disconnect(change_card)
		_navigate_player.play()
		await create_tween().tween_property(_card, "modulate", Color.TRANSPARENT, 0.1).finished
		_card.queue_free()
	
	if _card_stack.is_empty():
		_card = null
	else:
		_card = load("res://gui/cards/%s_gui_card.tscn" % _card_stack[-1]).instantiate()
		_card.modulate = Color.TRANSPARENT
		_card.push_requested.connect(push_card)
		_card.pop_requested.connect(pop_card)
		_card.change_requested.connect(change_card)
		add_child(_card)
		await create_tween().tween_property(_card, "modulate", Color.WHITE, 0.1).finished
		
		var focus: Node = get_tree().get_first_node_in_group("focus")
		
		if focus is Control:
			focus.grab_focus()
	
	_is_updating = false
