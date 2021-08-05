extends KinematicBody2D

const MOVE_SPEED = 150
const JUMP = -550
const GRAVITY = 35
const UP = Vector2(0,-1)
const RPM = 350

const BULLET = preload('res://Scenes/Bullet.tscn')

var Hp = 100
var motion = Vector2()
var direction

enum Direction {LEFT = 0, RIGHT = 1, NONE = 2}

puppet var slave_position = Vector2()
puppet var slave_movement = Direction.NONE
puppet var slave_Hp = 100

func _ready():
	$RPM_timer.wait_time = 60.00/RPM

func _physics_process(delta):
	if is_network_master():
		if Input.is_action_pressed('ui_left'):
			direction = Direction.LEFT
		elif Input.is_action_pressed('ui_right'):
			direction = Direction.RIGHT
		else:
			direction = Direction.NONE
		rset_unreliable('slave_position',position)
		rset('slave_movement',direction)
		move(direction)
	else:
		move(slave_movement)
		position = slave_position
	
	if get_tree().is_network_server():
		Networking.update_position(int(name),position)

func move(direction):
	
	if is_on_floor():
		if Input.is_action_pressed('ui_up'):
			motion.y = JUMP
	else:
		motion.y += max(GRAVITY,0)

	match direction:
		Direction.LEFT:
			motion.x = -MOVE_SPEED
			$Sprite.flip_h = true
			$Bullet_spawn.position = Vector2(-17,0)
		Direction.RIGHT:
			motion.x = MOVE_SPEED
			$Sprite.flip_h = false
			$Bullet_spawn.position = Vector2(19,0)
		Direction.NONE:
			motion.x = 0
	move_and_slide(motion, UP)

sync func shoot():
		var bullet = BULLET.instance()
		bullet.getDirection($Sprite.flip_h)
		bullet.modulate = $Sprite.modulate
		get_parent().add_child(bullet)
		bullet.global_position = $Bullet_spawn.global_position
		$RPM_timer.start()

func _process(delta):
	if is_network_master():
		if Input.is_action_pressed('ui_accept') and $RPM_timer.is_stopped() and Hp > 0 :
			rpc('shoot')
			

sync func die():
	queue_free()

func _on_Area2D_area_entered(area):
	if is_network_master():
		if area.is_in_group('Bullets'):
			Hp -= area.damage
			rset('slave_Hp',Hp)
			if Hp <= 0:
				rpc('die')
		else:
			Hp = slave_Hp

func init(nickname, spawn,colour):
	$Name.text = str(nickname)
	global_position = spawn
	$Sprite.modulate = colour
