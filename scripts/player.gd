class_name Player
extends CharacterBody2D
## 8-direction player with attack (Space/J), dodge roll (Shift/K).

signal hp_changed(hp: int)
signal died

@export var speed := 110.0
@export var max_hp := 8
@export var attack_damage := 14
@export var attack_range := 38.0
@export var attack_cooldown := 0.35
@export var roll_speed := 260.0
@export var roll_time := 0.22

var hp := max_hp
var facing := Vector2.DOWN
var _atk_cd := 0.0
var _roll_t := 0.0
var _iframes := 0.0
var boss: Node2D
var _flash := 0.0

func _ready() -> void:
	hp = max_hp
	add_to_group("player")

func _physics_process(delta: float) -> void:
	_atk_cd = max(_atk_cd - delta, 0.0)
	_iframes = max(_iframes - delta, 0.0)
	_flash = max(_flash - delta, 0.0)
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if _roll_t > 0.0:
		_roll_t -= delta
		velocity = facing * roll_speed
	else:
		velocity = dir * speed
		if dir != Vector2.ZERO:
			facing = dir.normalized()
		if Input.is_action_just_pressed("roll") and dir != Vector2.ZERO:
			_roll_t = roll_time
			_iframes = roll_time + 0.1
		elif Input.is_action_just_pressed("attack") and _atk_cd == 0.0:
			_attack()
	move_and_slide()
	queue_redraw()

func _attack() -> void:
	_atk_cd = attack_cooldown
	_flash = 0.12
	if boss and is_instance_valid(boss):
		var to_b := boss.global_position - global_position
		if to_b.length() <= attack_range + 16.0 and to_b.normalized().dot(facing) > 0.2:
			boss.take_damage(attack_damage)

func take_damage(amount: int) -> void:
	if _iframes > 0.0 or hp <= 0:
		return
	hp = max(hp - 1 if amount < 15 else hp - 2, 0)
	_iframes = 0.8
	hp_changed.emit(hp)
	if hp == 0:
		died.emit()

func _draw() -> void:
	var col := Color(0.95, 0.95, 1.0)
	if _iframes > 0.0 and int(_iframes * 20) % 2 == 0:
		col.a = 0.4
	draw_circle(Vector2.ZERO, 8, col)
	draw_rect(Rect2(-8, -2, 16, 6), Color(0.8, 0.15, 0.15))  # red cloak
	draw_line(Vector2.ZERO, facing * 12, Color.WHITE, 2)
	if _flash > 0.0:
		draw_arc(Vector2.ZERO, attack_range, facing.angle() - 0.9, facing.angle() + 0.9, 12, Color(1, 1, 0.6), 3)
