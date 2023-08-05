## A collection of event [Signal]s for coupling gameplay.
extends Node

## Emitted when a new game is started.
signal new_game_started

## Emitted when a [GameOverGUICard] is closed.
signal game_over_cleared

## Connect an event [Signal] to a target [Callable].
func on(event: Signal, callable: Callable) -> void:
	if not event.is_connected(callable):
		event.connect(callable)
