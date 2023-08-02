## A generic full page GUI element containing a [VBoxContainer] of GUI elements.
class_name GUICard
extends PanelContainer

## Emitted when a request is made to change or close the GUI card.
signal change_requested(card_name: String)

## Make a request to change the GUI card. Emit [signal change_requested].
func change_card(card_name: String) -> void:
	change_requested.emit(card_name)


## Make a request to close the GUI card. Emit [signal change_requested].
func close_card() -> void:
	change_requested.emit("")
