extends Node2D
class_name Ball

enum Colors{YELLOW = 0xffffffff, RED = 0xff1c76ff, GREEN = 0x00ff00ff}

@export var color : Colors = Colors.YELLOW:
	set(value):
		color = value
		self.modulate = color
