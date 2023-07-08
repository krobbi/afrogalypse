class_name GUICard
extends PanelContainer

func change_card(card_name: String) -> void:
	Global.gui_card_changed.emit(card_name)


func close_card() -> void:
	Global.gui_card_changed.emit("")
