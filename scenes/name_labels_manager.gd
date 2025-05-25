extends Control
class_name NameLabelsManager

func handle_unit_spawned(actor: Actor):
	# 玩家不生成标签
	if actor.is_player():
		return
	
	print("name label manager handling ai unit inited:", actor.name)
	if actor.name_label_node2d == null:
		# 现在的实现比较屎，因为 RemoteTransform2D 只能把位置坐标发给继承 Node2D 的节点
		var name_label_node2d: Node2D = Node2D.new()
		name_label_node2d.name = actor.name + "NameLabelNode2D"
		name_label_node2d.global_position = actor.global_position
		add_child(name_label_node2d)
		
		var name_label: Label = Label.new()
		name_label.name = actor.name + "NameLabel"
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		# FIXME: 这里坐标写死了，需要看看有没有更好的实现方式
		name_label.position = Vector2(-32, -50)
		name_label.text = actor.name
		# 描边配置
		name_label.add_theme_color_override("font_outline_color", Color.BLACK)
		name_label.add_theme_constant_override("outline_size", 3)
		# 阴影配置
		name_label.add_theme_color_override("font_shadow_color", Color.DIM_GRAY)
		name_label.add_theme_constant_override("shadow_offset_x", 3)
		name_label.add_theme_constant_override("shadow_offset_y", 3)
		name_label.add_theme_constant_override("shadow_outline_size", 2)
		name_label.modulate = get_name_label_color(actor.team.side)
		# FIXME: 锚点貌似得在 UI Container 节点中生效，应该用 pivot。但 pivot 获取不到正确的 size
		name_label.set_anchors_preset(Control.PRESET_CENTER)	
		name_label.pivot_offset = name_label.size / 2
		name_label_node2d.add_child(name_label)
		
		actor.set_name_label_node2d(name_label_node2d)
	else:
		add_child(actor.name_label_node2d)
		# RemoteTransform2D 必须也重新赋值
		actor.set_name_label_node2d(actor.name_label_node2d)


func get_name_label_color(side: Team.Side) -> Color:
	match (side):
		Team.Side.PLAYER:
			return Color.LIGHT_GREEN
		Team.Side.ENEMY:
			return Color.LIGHT_CORAL
		_:
			return Color.WHITE
		
