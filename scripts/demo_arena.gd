extends Node2D
## Self-contained playable demo: builds player, companion, boss and HUD in code.
## Boss/Companion here are lightweight placeholder versions (no animations needed).

const ARENA := Rect2(-280, -150, 560, 300)

var player: Player
var comp: DemoCompanion
var boss: DemoBoss
var hud: Label
var msg: Label

func _ready() -> void:
	_ensure_actions()
	player = Player.new()
	player.position = Vector2(-150, 60)
	add_child(player)
	comp = DemoCompanion.new()
	comp.position = Vector2(-180, 80)
	comp.player = player
	add_child(comp)
	boss = DemoBoss.new()
	boss.position = Vector2(150, -20)
	boss.player = player
	boss.companion = comp
	add_child(boss)
	player.boss = boss
	comp.boss = boss
	player.died.connect(func(): _end("พ่ายแพ้... กด R เพื่อเริ่มใหม่"))
	boss.died.connect(func(): _end("ชนะแล้ว! กด R เพื่อเล่นอีกครั้ง"))
	var cam := Camera2D.new()
	cam.zoom = Vector2(2, 2)
	add_child(cam)
	var cl := CanvasLayer.new()
	add_child(cl)
	hud = Label.new()
	hud.position = Vector2(10, 8)
	cl.add_child(hud)
	msg = Label.new()
	msg.position = Vector2(180, 150)
	msg.add_theme_font_size_override("font_size", 28)
	cl.add_child(msg)
	var tint := CanvasModulate.new()
	tint.color = Color(0.9, 0.82, 0.72)
	add_child(tint)

func _ensure_actions() -> void:
	var map := {"attack": [KEY_SPACE, KEY_J], "roll": [KEY_SHIFT, KEY_K], "restart": [KEY_R],
		"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP], "move_down": [KEY_S, KEY_DOWN]}
	for a in map:
		if not InputMap.has_action(a):
			InputMap.add_action(a)
		for k in map[a]:
			var e := InputEventKey.new()
			e.physical_keycode = k
			InputMap.action_add_event(a, e)

func _process(_d: float) -> void:
	player.global_position = player.global_position.clamp(ARENA.position, ARENA.end)
	hud.text = "HP %s   BOSS %d/%d  (Phase %d)\nWASD เดิน | Space โจมตี | Shift กลิ้ง" % [
		"♥".repeat(player.hp), boss.hp, boss.max_hp, boss.phase]
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _end(text: String) -> void:
	msg.text = text
	get_tree().paused = false
	boss.set_physics_process(false)

func _draw() -> void:
	draw_rect(ARENA, Color(0.28, 0.22, 0.18))
	draw_rect(ARENA, Color(0.5, 0.35, 0.2), false, 3)
	for x in range(-260, 280, 40):
		for y in range(-130, 150, 40):
			draw_circle(Vector2(x, y), 1.5, Color(0.4, 0.33, 0.27))
