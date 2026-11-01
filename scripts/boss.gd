class_name Boss
extends CharacterBody2D
## Act 2 boss: FSM with telegraphed attacks and a Phase 2 at <=50% HP.
## Expected children: AnimationPlayer ("idle","telegraph_*","attack_*","phase_change","death"),
## Timer named "CooldownTimer" (one_shot).

signal died
signal phase_changed(phase: int)

enum State { IDLE, TELEGRAPH, ATTACK, COOLDOWN, PHASE_CHANGE, DEAD }

@export var max_hp: int = 300
@export var move_speed: float = 60.0
@export var telegraph_time: float = 0.6       # fair warning window
@export var phase2_telegraph_time: float = 0.4
@export var cooldown_time: float = 1.2
@export var phase2_cooldown_time: float = 0.7

## Skills: name -> {range, damage, targets_companion}
var skills := {
	"ash_slam":    {"range": 70.0,  "damage": 20, "targets_companion": false},
	"ember_volley": {"range": 260.0, "damage": 12, "targets_companion": false},
	"cinder_sweep": {"range": 110.0, "damage": 15, "targets_companion": true},  # punishes hugging the boss
	"light_snuff":  {"range": 200.0, "damage": 10, "targets_companion": true},  # Phase 2 only: targets companion
}
const PHASE2_ONLY := ["light_snuff"]

var hp: int
var phase: int = 1
var state: State = State.IDLE
var current_skill: String = ""
var player: Node2D
var companion: Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var cooldown: Timer = $CooldownTimer

func _ready() -> void:
	hp = max_hp
	cooldown.one_shot = true
	cooldown.timeout.connect(_on_cooldown_done)
	_change_state(State.IDLE)

func _physics_process(_delta: float) -> void:
	match state:
		State.IDLE: _process_idle()
		_: velocity = Vector2.ZERO
	move_and_slide()

func _process_idle() -> void:
	if player == null:
		return
	var to_player := player.global_position - global_position
	velocity = to_player.normalized() * move_speed
	var skill := _pick_skill(to_player.length())
	if skill != "":
		current_skill = skill
		_change_state(State.TELEGRAPH)

func _pick_skill(dist: float) -> String:
	var options: Array[String] = []
	for s in skills:
		if s in PHASE2_ONLY and phase < 2:
			continue
		if dist <= skills[s]["range"]:
			options.append(s)
	return options.pick_random() if not options.is_empty() else ""

func _change_state(new_state: State) -> void:
	state = new_state
	match state:
		State.IDLE:
			anim.play("idle")
		State.TELEGRAPH:
			anim.play("telegraph_" + current_skill)
			var t := phase2_telegraph_time if phase == 2 else telegraph_time
			get_tree().create_timer(t).timeout.connect(_on_telegraph_done)
		State.ATTACK:
			anim.play("attack_" + current_skill)
			_apply_skill(current_skill)
			await anim.animation_finished
			if state == State.ATTACK:
				_change_state(State.COOLDOWN)
		State.COOLDOWN:
			anim.play("idle")
			cooldown.start(phase2_cooldown_time if phase == 2 else cooldown_time)
		State.PHASE_CHANGE:
			anim.play("phase_change")
			await anim.animation_finished
			_change_state(State.IDLE)
		State.DEAD:
			anim.play("death")
			died.emit()

func _on_telegraph_done() -> void:
	if state == State.TELEGRAPH:
		_change_state(State.ATTACK)

func _on_cooldown_done() -> void:
	if state == State.COOLDOWN:
		_change_state(State.IDLE)

func _apply_skill(skill: String) -> void:
	# Hook up Area2D hitboxes per skill here; placeholder range-check damage.
	var data: Dictionary = skills[skill]
	for target in [player, companion]:
		if target == null:
			continue
		if target == companion and not data["targets_companion"]:
			continue
		if target.global_position.distance_to(global_position) <= data["range"] and target.has_method("take_damage"):
			target.take_damage(data["damage"])

func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return
	hp = max(hp - amount, 0)
	if hp == 0:
		_change_state(State.DEAD)
	elif phase == 1 and hp <= max_hp / 2:
		phase = 2
		phase_changed.emit(phase)
		_change_state(State.PHASE_CHANGE)
