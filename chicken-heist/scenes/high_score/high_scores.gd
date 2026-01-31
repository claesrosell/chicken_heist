extends Control

# The URL to your API
const SCORE_URL = "https://theball.se/TreGubbar/services/hiscore.php"

var score_header_settings:LabelSettings
var score_label_settings:LabelSettings

const RESULT_COLOR := Color("932d2b") # Dark Red (Unselected)
const RESULT_OUTLINE_COLOR := Color.WHITE

@onready var http_request: HTTPRequest = $HTTPRequest
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
	
	# Set up the request signal
	http_request.request_completed.connect(_on_request_completed)

	add_header_row()

	# Fetch the data
	fetch_highscores()

func add_header_row() -> void:
	# Headers must match the GridContainer column count (4)
	var headers = ["Pos", "Rocky", "Foxy", "Score"]
	for title in headers:
		var label = Label.new()
		label.text = title
		label.label_settings = self.score_header_settings
		label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		score_grid.add_child(label)

func fetch_highscores() -> void:
	# Create the request
	var error = http_request.request(SCORE_URL)
	if error != OK:
		print("An error occurred in the HTTP request.")

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Error: ", response_code)
		return

	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		print("JSON Parse Error: ", json.get_error_message())
		return

	# Get the data dictionary
	var response = json.data
	
	# Check if "data" key exists in your specific JSON structure
	if response.has("data"):
		populate_table(response["data"])
	else:
		print("Unexpected JSON structure")

func populate_table(data_array: Array) -> void:
	# Loop through the list of scores
	for entry in data_array:
		create_cell("%d" % entry["position"], HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
		create_cell(entry["name1"], HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
		create_cell(entry["name2"], HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)
		create_cell("%d" % entry["score"], HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT)


func create_cell(text: String, h_align:int) -> void:
	var label = Label.new()
	label.text = text
	label.label_settings = self.score_label_settings
	label.horizontal_alignment = h_align
	# Expand ensures the label takes up available space in the column
	label.size_flags_horizontal = SIZE_EXPAND_FILL
	score_grid.add_child(label)

func format_unix_time(timestamp: int) -> String:
	# Convert Unix int (e.g. 1769520221) to a dictionary
	var date_dict = Time.get_datetime_dict_from_unix_time(timestamp)
	
	# Format: YYYY-MM-DD HH:MM
	# %02d ensures "5" becomes "05"
	var date_string = "%d-%02d-%02d %02d:%02d" % [
		date_dict.year, 
		date_dict.month, 
		date_dict.day, 
		date_dict.hour, 
		date_dict.minute
	]
	return date_string
