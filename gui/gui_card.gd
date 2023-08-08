## A generic full page GUI element containing a [VBoxContainer] of GUI elements.
class_name GUICard
extends PanelContainer

## Emitted when a request is made to change to a root GUI card.
signal change_requested(card_name: String)

## Emitted when a request is made to clear the stack of GUI cards.
signal close_requested

## Make a request to change to a root GUI card. Emit [signal change_requested].
func change_card(card_name: String) -> void:
	change_requested.emit(card_name)


## Make a request to clear the stack of GUI cards. Emit
## [signal close_requested].
func close_card() -> void:
	close_requested.emit()
