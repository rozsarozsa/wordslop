extends Label

var max_health = 2
var health = max_health
var letter = "_"
var main
var color_sq

# Called when the node enters the scene tree for the first time.
func _ready():
	main = get_tree().get_root().get_node("Main")
	

func init_real(used_chars):
	while text in used_chars:
		var chars = "eeeeeaaaaiiiioooonnnnnnrrrrrrttttttllllssssuuuddddgggbbccmmppffhhvvwwyykjxqz"
		letter = chars[randi() % 76]
		text = letter

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		name = "DEAD!"
		visible = false
		main.adjust_letters()
		queue_free()

func take_hit(dmg):
	health -= dmg
	add_theme_color_override("font_outline_color", Color.GREEN.darkened(float(max_health - health) / float(max_health)))

func die():
	name = "DEAD!"
	visible = false
	queue_free()
