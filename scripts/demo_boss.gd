class_name DemoBoss
extends Node2D
## Placeholder boss: IDLE(chase) -> TELEGRAPH -> ATTACK -> COOLDOWN, Phase 2 at 50% HP.

signal died

enum S { CHASE, TELEGRAPH, ATTACK, COOLDOWN, DEAD }

var max_hp := 300
var hp := 300
var phase := 1
var state := S.CHASE
var t := 0.0
var skill := ""
var player: Node2D
var companion: Node2D
var _hit_done := false
var _hurt := 0.0

func _physics_process(delta: float) -> void:
	_hurt = max(_hurt - delta, 0.0)
	t -= delta
	match state:
		S.CHASE:
			var d := player.global_position - global_position
			global_position += d.normalized() * (45.0 if phase == 1 else 65.0) * delta
			if d.length() < 150.0:
				skill = _pick(d.length())
				state = S.TELEGRAPH
				t = 0.7 if phase == 1 else 0.45
		S.TELEGRAPH:
			if t <= 0.0:
				state = S.ATTACK
				t = 0.25
				_hit_done = false
		S.ATTACK:
			if not _hit_done:
				_hit_done = true
				_apply()
			if t <= 0.0:
				state = S.COOLDOWN
				t = 1.1 if phase == 1 else 0.6
		S.COOLDOWN:
			if t <= 0.0:
				state = S.CHASE
	queue_redraw()

func _pick(dist: float) -> String:
	var opts := ["slam"] if dist < 70.0 else ["sweep", "volley"]
	if phase == 2:
		opts.append("snuff")  # targets companion
	return opts.pick_random()

func _radius() -> float:
	return {"slam": 55.0, "sweep": 85.0, "volley": 130.0, "snuff": 60.0}[skill]

func _target_pos() -> Vector2:
	return companion.global_position if skill == "snuff" else global_position

func _apply() -> void:
	var c := _target_pos()
	for who in [player, companion]:
		if who and who.global_position.distance_to(c) <= _radius() and (skill != "snuff" or who == companion):
			who.take_damage(20 if skill == "slam" else 10)

func take_damage(a: int) -> void:
	if state == S.DEAD:
		return
	hp = max(hp - a, 0)
	_hurt = 0.1
	if hp == 0:
		state = S.DEAD
		died.emit()
	elif phase == 1 and hp <= max_hp / 2:
		phase = 2

func _draw() -> void:
	if state == S.DEAD:
		draw_circle(Vector2.ZERO, 10, Color(0.2, 0.2, 0.2))
		return
	var body := Color(0.15, 0.12, 0.15) if _hurt == 0.0 else Color.WHITE
	draw_circle(Vector2.ZERO, 18, body)
	draw_arc(Vector2.ZERO, 20, 0, TAU, 24, Color(1, 0.2, 0.1) if phase == 2 else Color(0.8, 0.4, 0.2), 3)
	if state == S.TELEGRAPH or state == S.ATTACK:
		var c := to_local(_target_pos())
		var a := 0.25 if state == S.TELEGRAPH else 0.6
		draw_circle(c, _radius(), Color(1, 0.15, 0.1, a))
