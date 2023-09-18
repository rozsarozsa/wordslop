extends Node2D


var dic = []
var l0
var l1
var l2
var l3
var l4
var l5

var u0
var u1
var u2
var u3
var u4
var u5

var score = 0

var letters
var label

var message_box
var score_box
var level_box

var level_limit = 10
var level_subst = 0
var timer = 0
var level_count = 0
var level = 1

var game_over = false
var title_screen = true

var GRID = 6

var used_words = []
# Called when the node enters the scene tree for the first time.
func _ready():
	label = preload("res://label.tscn")
	load_file("res://text/dictionary.txt")
	message_box = get_node("Control/messagebox/Message")
	score_box = get_node("Control/messagebox/Score")
	level_box = get_node("Control/messagebox/Level")
	
	level_box.text = "Level " + str(level)
	add_row(5)
	if not exist_vowel():
		add_vowel()
	get_bottom_row()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	
	if not title_screen and not game_over and timer > 15 - level_subst:
		timer -= (15 - level_subst)
		if check_upper_row():
			game_over = true
			get_node("Control/gameoverscreen").visible = true
			get_node("Control/gameoverscreen/Score").text += str(score)
		add_row(0)
		level_count = level_count + 1
		level_subst = int(score / 2000)
		if level_subst > 10:
			level_subst = 10
		level = 1 + level_subst
		level_box.text = "Level " + str(level)

func _input(ev):
	
	if title_screen and ev.is_action_pressed("s"):
		start_game()
	elif game_over and ev.is_action_pressed("r"):
		restart_game()
	elif ev.is_action_pressed("ui_text_indent"):
		refresh_bottom()	
		get_bottom_row()
	elif ev.is_action_pressed("ui_text_backspace"):
		get_node("Control/InputBox/ColorRect/Label").text = get_node("Control/InputBox/ColorRect/Label").text.left(-1)
	elif ev.is_action_pressed("ui_text_submit"):
		print_debug(submit(get_node("Control/InputBox/ColorRect/Label").text))
		get_node("Control/InputBox/ColorRect/Label").text = ""
	elif ev is InputEventKey and ev.pressed and not ev.is_action("ui_text_backspace"):
		if len(OS.get_keycode_string(ev.keycode)) == 1:
			get_node("Control/InputBox/ColorRect/Label").text += OS.get_keycode_string(ev.keycode)
func load_file(file):
	var f = FileAccess.open(file, FileAccess.READ)
	var index = 1
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		dic.append(line)
		# print_debug(line)

func submit(word):
	var length = len(word)
	# reject too short words, return -3
	if length < 3:
		message_box.text = "Too short! Use at least 3 letters."
		return -3
	# else if it has been used before, return -2
	elif word in used_words:
		message_box.text = "You've already used the word \"" + word + "\". Try another!"
		return -2
	# else look it up in the dictionary
	# if a real word, return the score 
	elif dic.find(word) != -1:
		# sum is for score
		var sum = 0
		# list of letters in the bottom row
		var current_letters = []
		for l in letters:
			if l != null:
				current_letters.append(l.text)
		var count = 0
		# for each letter in the bottom row, count the amount of times it appears, subtract it from health
		while count < len(word):
			if word[count].to_lower() not in current_letters:
				return 0
			count += 1
		count = 0
		# for each letter in the bottom row, count the amount of times it appears, subtract it from health
		while count < len(letters):
			if letters[count] != null:
				var char_count = word.countn(letters[count].text)
				if char_count > 0:
					letters[count].take_hit(char_count)
					sum += char_count
				# print_debug(current_letters[count])
				# print_debug(char_count)
			count += 1
		used_words.append(word)
		message_box.text = "\"" + word.to_upper() + "\"! Very good..."
		score = score + sum * 100
		score_box.text = str(score)
		
		return sum
	# if not a real word, return -1
	else:
		message_box.text = "\"" + word.to_upper() + "\"? Never heard of that before..."
		return -1
		
		
func adjust_letters():
	var i = GRID
	while i > 0:
		i -= 1
		var j = GRID
		while j > 0:
			j -= 1
			if not get_node("Control/VBoxContainer/GridContainer/" + str(i) + str(j) + "/Label"):
				var source = get_node("Control/VBoxContainer/GridContainer/" + str(i - 1) + str(j) + "/Label")

				if source:
					var target = get_node("Control/VBoxContainer/GridContainer/" + str(i) + str(j))
					get_node("Control/VBoxContainer/GridContainer/" + str(i - 1) + str(j)).remove_child(source)
					target.add_child(source)
					source.set_owner(target)
					source.position = Vector2.ZERO
	if not exist_vowel():
		add_vowel()
	get_bottom_row()
	

func get_bottom_row():
	l0 = get_node("Control/VBoxContainer/GridContainer/50/Label")
	l1 = get_node("Control/VBoxContainer/GridContainer/51/Label")
	l2 = get_node("Control/VBoxContainer/GridContainer/52/Label")
	l3 = get_node("Control/VBoxContainer/GridContainer/53/Label")
	l4 = get_node("Control/VBoxContainer/GridContainer/54/Label")
	l5 = get_node("Control/VBoxContainer/GridContainer/55/Label")
	letters = [l0, l1, l2, l3, l4, l5]

func add_row(row_n):
	var used_chars = [" "]
	var j = GRID
	while j > 0:
		j -= 1
		var instance = label.instantiate()
		instance.init_real(used_chars)
		get_node("Control/VBoxContainer/GridContainer/" + str(row_n) + str(j)).add_child(instance)
		used_chars.append(instance.text)
		print_debug(instance.text)
	get_bottom_row()
	adjust_letters()
	adjust_letters()
	adjust_letters()
	adjust_letters()
	adjust_letters()
	
func check_upper_row():
	u0 = get_node("Control/VBoxContainer/GridContainer/00/Label")
	u1 = get_node("Control/VBoxContainer/GridContainer/01/Label")
	u2 = get_node("Control/VBoxContainer/GridContainer/02/Label")
	u3 = get_node("Control/VBoxContainer/GridContainer/03/Label")
	u4 = get_node("Control/VBoxContainer/GridContainer/04/Label")
	u5 = get_node("Control/VBoxContainer/GridContainer/05/Label")
	
	if u0 or u1 or u2 or u3 or u4 or u5:
		return true
	else:
		return false
		
func exist_vowel():
	for l in letters:
		if l != null and l.visible and l.text in "aeiou":
			return true
	for l in letters:
		if l != null and l.visible:
			return false
	return true
	
func add_vowel():
	if not exist_vowel():
		for l in letters:
			if l and l.visible:
				l.text = "aeiou"[randi() % 5]
				return 0
	return -1

func refresh_bottom():
	for l in letters:
		if l != null:
			l.die()
	add_row(5)

func clear():
	var count = 0
	while count < GRID:	
		for l in letters:	
			if l != null:
				l.die()
		adjust_letters()
		count += 1

func restart_game():
	print_debug("hi")
	get_tree().reload_current_scene()
	
func start_game():
	title_screen = false
	get_node("Control/titlescreen").visible = false
