## A collection of event [Signal]s for coupling gameplay.
extends Node

## Emitted when a new game is started.
signal new_game_started

## Emitted when a level is started.
signal level_started

## Emitted when a level is finished.
signal level_finished

## Emitted when the score is changed.
signal score_changed(score: int)

## Emitted when energy is gained.
signal energy_gained

## Emitted when energy is lost.
signal energy_lost

## Emitted when a sign is passed.
signal sign_passed

## Emitted when a boost is used.
signal boost_used

## Emitted when a boost is available.
signal boost_available

## Emitted on game over.
signal game_over

## Emitted when a [GameOverGUICard] is closed.
signal game_over_cleared

## Connect an event [Signal] to a target [Callable].
func on(event: Signal, callable: Callable) -> void:
	if not event.is_connected(callable):
		event.connect(callable)
