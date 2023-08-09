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

## Emitted when the game is paused.
signal game_paused

## Emitted when the game is manually ended.
signal game_ended

## Emitted when the input mappings are changed.
signal input_mappings_changed

## Subscribe a [Node]'s [Callable] to an event [Signal].
func subscribe(event: Signal, callable: Callable) -> void:
	if not event.is_connected(callable):
		event.connect(callable)
	
	var node: Node = callable.get_object() as Node
	
	if not node.tree_exiting.is_connected(_unsubscribe):
		node.tree_exiting.connect(_unsubscribe.bind(node), CONNECT_ONE_SHOT)


## Unsubscribe a [Node] from its subscribed event [Signal]s.
func _unsubscribe(node: Node) -> void:
	for connection in node.get_incoming_connections():
		var event: Signal = connection["signal"]
		
		if event.get_object() == self:
			event.disconnect(connection.callable)
