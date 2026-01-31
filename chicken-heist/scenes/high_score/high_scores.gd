extends Control

# The URL to your API
var score_header_settings:LabelSettings
var score_label_settings:LabelSettings

const RESULT_COLOR := Color("932d2b") # Dark Red (Unselected)
const RESULT_OUTLINE_COLOR := Color.WHITE

@onready var high_scores_api: HighScoresApi = $HighScoresApi
@onready var score_grid: GridContainer = $ScrollContainer/HighScoreContainer

func _ready() -> void:
	self.score_header_settings = LabelSettings.new()
	self.score_header_settings.font_size = 40
	self.score_header_settings.font_color = RESULT_COLOR
	self.score_header_settings.outline_color = Color.WHITE # The "Outline" color
	self.score_header_settings.outline_size = 10            # Size in pixels (Must be > 0 to see it)

	self.score_label_settings = LabelSettings.new()
	self.score_label_settings.font_size = 32
	self.score_label_settings.font_color = RESULT_COLOR
	self.score_label_settings.outline_color = Color.WHITE # The "Outline" color
	self.score_label_settings.outline_size = 10            # Size in pixels (Must be > 0 to see it)

	_add_header_row()

	# The API emits 'scores_loaded' with the data array. Populate the table with that payload!
	high_scores_api.scores_loaded.connect(_populate_table)

	# Fetch the data
	var fetch_around_rank = GameManager.latest_rank_achieved
	if fetch_around_rank < 1:
		fetch_around_rank = 1

	high_scores_api.fetch_around_rank(fetch_around_rank, 10)

	# create_timer returns a SceneTreeTimer which cleans itself up automatically
	get_tree().create_timer(7.0).timeout.connect(_return_to_main_menu)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("p1_button_a") or Input.is_action_just_pressed("p1_button_b") or Input.is_action_just_pressed("p2_button_a") or Input.is_action_just_pressed("p2_button_b"):
		self._return_to_main_menu()

func _add_header_row() -> void:
	# Headers must match the GridContainer column count (4)
	var headers = ["Pos", "Rocky", "Foxy", "Score"]
	for title in headers:
		var label = Label.new()
		label.text = title
		label.label_settings = self.score_header_settings
		label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		score_grid.add_child(label)

func _populate_table(data_array: Array) -> void:
	# Loop through the list of scores
	for entry in data_array:
		_create_cell("%d" % entry["position"], HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
		_create_cell(entry["name1"], HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
		_create_cell(entry["name2"], HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
		_create_cell("%d" % entry["score"], HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)

func _create_cell(text: String, h_align:int) -> void:
	var label = Label.new()
	label.text = text
	label.label_settings = self.score_label_settings
	label.horizontal_alignment = h_align
	# Expand ensures the label takes up available space in the column
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	score_grid.add_child(label)

func _return_to_main_menu() -> void:
	# 2. Check if we are still in the scene tree to avoid errors
	if not is_inside_tree():
		return
		
	# 3. Change the scene back to the Main Menu
	# Note: I used the filename 'main-menu.tscn' based on your file list
	get_tree().change_scene_to_file("res://scenes/main_menu/main-menu.tscn")
