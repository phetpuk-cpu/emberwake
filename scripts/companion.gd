class_name Companion
extends CharacterBody2D
## Single follower. FOLLOW / WAIT in exploration, SUPPORT in boss rooms.
## Expected children: NavigationAgent2D, Timer "SupportTimer".

enum State { FOLLOW, WAIT, SUPPORT }

@export var player: Node2D
@export var follow_distance: float = 48.0   # start following beyond this
@export var stop_distance: float = 24.0     # wait when closer than this
@export var speed: float = 90.0
@export var support_interval: float = 2.5
@export var support_damage: int = 8
@export var boss_room_mode: bool = false : set = set_boss_room_mode

var state: State = State.WAIT
var boss: Node2D

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var support_timer: Timer = $SupportTimer

func _ready() -> void:
	support_timer.wait_time = support_interval
	support_timer.timeout.connect(_on_support_tick)
	nav.velocity_computed.connect(_on_velocity_computed)

func set_boss_room_mode(v: bool) -> void:
	boss_room_mode = v
	if not is_node_ready():
		return
	if v:
		state = State.SUPPORT
		support_timer.start()
	else:
		support_timer.stop()
		state = State.WAIT

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	var dist := global_position.distance_to(player.global_position)
	if state != State.SUPPORT:
		# Hysteresis avoids jitter between follow/wait
		if dist > follow_distance:
			state = State.FOLLOW
		elif dist < stop_distance:
			state = State.WAIT
	match state:
		State.FOLLOW:
			nav.target_position = player.global_position
			if nav.is_navigation_finished():
				_on_velocity_computed(Vector2.ZERO)
			else:
				var dir := (nav.get_next_path_position() - global_position).normalized()
				nav.velocity = dir * speed
		State.SUPPORT:
			# Hover near the player, not on top of them
			if dist > follow_distance * 1.5:
				nav.target_position = player.global_position
				var d := (nav.get_next_path_position() - global_position).normalized()
				nav.velocity = d * speed
			else:
				nav.velocity = Vector2.ZERO
		_:
			nav.velocity = Vector2.ZERO

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _on_support_tick() -> void:
	if boss != null and boss.has_method("take_damage"):
		boss.take_damage(support_damage)
	# Alternative: buff player, e.g. player.apply_buff("light_ward", 3.0)

func take_damage(_amount: int) -> void:
	pass  # TODO: companion stagger/downed state
