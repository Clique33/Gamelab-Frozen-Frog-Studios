extends CanvasLayer
class_name HUDLayer

signal go_to_menu

func _on_menu_button_pressed() -> void:
	emit_signal("go_to_menu")
