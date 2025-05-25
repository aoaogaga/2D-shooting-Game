extends Area2D
class_name CapturableBase

signal base_captured(base: CapturableBase, actors: Array[Actor])
signal exited_screen(base: CapturableBase)
signal entered_screen(base: CapturableBase)

@export var neutral_color: Color = Color(1, 1, 1)
@export var player_color: Color = Color(0, 1, 0)
@export var enemy_color: Color = Color(0, 0.5, 1)
@export var point_code: String

@onready var team: Team = $Team
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var captured_info: RichTextLabel = $CapturedInfo
@onready var captured_info_timer: Timer = $CapturedInfoTimer
@onready var out_screen_notifier: VisibleOnScreenNotifier2D = $OutScreenNotifier

var player_unit_count: int = 0
var enemy_unit_count: int = 0
var team_to_capture: Team.Side = Team.Side.NEUTRAL
# 对应多少秒后占领目的地
var max_occupy_progress: float = 8.0
var occupy_progress: float = 0.0

func _ready() -> void:
	progress_bar.max_value = max_occupy_progress
	progress_bar.set_value_no_signal(occupy_progress)
	name_label.text = name
	v_box_container.visible = false
	captured_info.visible = false


func _process(delta: float) -> void:
	var majority_team: Team.Side = get_team_with_majority()
	if majority_team == Team.Side.NEUTRAL:
		return
	var diff_abs = abs(player_unit_count - enemy_unit_count)
	# 这里不判断的话，会在已占领的情况下重复显示占领信息
	if majority_team == team_to_capture and occupy_progress == max_occupy_progress:
		return
	# 占领进度会发生改变，需要显示
	if not v_box_container.visible:
		v_box_container.visible = true
	if majority_team == team_to_capture:
		# 将要占领方占优，增加占领进度
		occupy_progress = min(occupy_progress + delta * diff_abs, max_occupy_progress);
		if (occupy_progress == max_occupy_progress):
			set_team(majority_team)
			v_box_container.visible = false
			# 占领信息只显示一秒
			captured_info.text = get_captured_info_bbcode(team_to_capture)
			captured_info.visible = true
			captured_info_timer.start()
	else:
		# 抵抗占领方占优，扣减占领进度
		occupy_progress -= delta * diff_abs;
		if (occupy_progress < 0):
			team_to_capture = majority_team
			occupy_progress = -occupy_progress
			progress_bar.modulate = get_color(majority_team)
	progress_bar.set_value_no_signal(occupy_progress)


func _on_captured_info_timer_timeout() -> void:
	captured_info.visible = false


func get_captured_info_bbcode(side: Team.Side) -> String:
	match (side):
		Team.Side.ENEMY:
			return "[center]Captured by [color=red]ENEMY team[/color]!!![/center]"
		Team.Side.PLAYER:
			return "[center]Captured by [color=green]PLAYER team[/color]!!![/center]"
		_:
			return "Neutralized"


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_team_side"):
		var body_team_side = body.get_team_side()
		if body_team_side == Team.Side.ENEMY:
			enemy_unit_count += 1
		elif body_team_side == Team.Side.PLAYER:
			player_unit_count += 1


func _on_body_exited(body: Node2D) -> void:
	if body.has_method("get_team_side"):
		var body_team_side = body.get_team_side()
		if body_team_side == Team.Side.ENEMY:
			enemy_unit_count -= 1
		elif body_team_side == Team.Side.PLAYER:
			player_unit_count -= 1


func get_team_with_majority() -> Team.Side:
	if enemy_unit_count == player_unit_count:
		return Team.Side.NEUTRAL
	elif enemy_unit_count > player_unit_count:
		return Team.Side.ENEMY
	else:
		return Team.Side.PLAYER


func set_team(new_team: Team.Side):
	if (team.side == new_team):
		return
	team.side = new_team
	var actors: Array[Actor] = []
	for body in get_overlapping_bodies():
		if body is Actor and body.get_team_side() == new_team:
			actors.append(body as Actor)
	base_captured.emit(self, actors)
	sprite_2d.modulate = get_color(new_team)


func get_color(team_side: Team.Side) -> Color:
	match team_side:
		Team.Side.ENEMY:
			return enemy_color
		Team.Side.PLAYER:
			return player_color
		_:
			return neutral_color


func _on_out_screen_notifier_screen_exited() -> void:
	exited_screen.emit(self)


func _on_out_screen_notifier_screen_entered() -> void:
	entered_screen.emit(self)
