class_name DemoCompanion
extends Node2D
## Placeholder companion: follows with hysteresis, throws a spark at the boss every few seconds.

var player: Node2D
var boss: Node2D
var follow_dist := 50.0
var stop_dist := 26.0
var speed := 95.0
var moving := false
var _cd := 2.5
var _spark := 0.0
var _iframes := 0.0

func _physics_process(delta: float) -> void:
	_iframes = max(_iframes - delta, 0.0)
	_spark = max(_spark - delta, 0.0)
	var d := player.global_position - global_position
	if d.length() > follow_dist:
		moving = true
	elif d.length() < stop_dist:
		moving = false
	if moving:
		global_position += d.normalized() * speed * delta
	_cd -= delta
	if _cd <= 0.0 and boss and boss.get("hp") and boss.hp > 0:
		_cd = 2.5
		_spark = 0.2
		boss.take_damage(8)
	queue_redraw()

func take_damage(_a: int) -> void:
	_iframes = 0.5

func _draw() -> void:
	draw_circle(Vector2.ZERO, 6, Color(1, 0.6, 0.2) if _iframes == 0.0 else Color.WHITE)
	draw_rect(Rect2(-6, 0, 12, 3), Color(0.9, 0.4, 0.1))  # orange scarf
	if _spark > 0.0 and boss:
		draw_line(Vector2.ZERO, to_local(boss.global_position), Color(0.5, 0.9, 1), 2)
