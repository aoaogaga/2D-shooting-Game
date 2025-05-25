extends Node2D
class_name CapturableBaseManager


signal player_captured_all_bases
signal player_lost_all_bases

var capturable_bases: Array = []


func _ready() -> void:
	capturable_bases = get_children()
	for base in capturable_bases:
		(base as CapturableBase).base_captured.connect(handle_base_captured)
	
	GlobalMediator.capturable_base_manager = self


func handle_base_captured(_input_base: CapturableBase, _actors: Array[Actor]):
	var player_base_count = 0
	var enemy_base_count = 0
	for base in capturable_bases:
		match ((base as CapturableBase).team.side):
			Team.Side.PLAYER:
				player_base_count += 1
			Team.Side.ENEMY:
				enemy_base_count += 1
			_:
				return
	if player_base_count == capturable_bases.size():
		player_captured_all_bases.emit()
	if enemy_base_count == capturable_bases.size():
		player_lost_all_bases.emit()


func get_capturable_bases() -> Array:
	return capturable_bases
