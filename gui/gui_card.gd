## A generic full page GUI element containing a [VBoxContainer] of GUI elements.
class_name GUICard
extends PanelContainer

## Emitted when a request is made to push a GUI card.
signal push_requested(card_name: String)

## Emitted when a request is made to pop the GUI card.
signal pop_requested

## Emitted when a request is made to change to a root GUI card.
signal change_requested(card_name: String)

## Make a request to push a GUI card. Emit [signal push_requested].
func push_card(card_name: String) -> void:
	push_requested.emit(card_name)


## Make a request to pop the GUI card. Emit [signal pop_requested].
func pop_card() -> void:
	pop_requested.emit()


## Make a request to change to a root GUI card. Emit [signal change_requested].
func change_card(card_name: String) -> void:
	change_requested.emit(card_name)
