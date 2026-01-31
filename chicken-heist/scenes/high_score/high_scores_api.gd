extends Node
class_name HighScoresApi
# Signals
signal scores_loaded(data)
signal score_submitted(rank)
signal eligibility_checked(is_eligible) # New signal for the HEAD check

@onready var http = $HTTPRequest
var api_url = "https://theball.se/TreGubbar/services/hiscore.php"

# We use this flag to know how to process the response
enum RequestType { FETCH, SUBMIT, CHECK }
var current_request_type = RequestType.FETCH

func _ready():
	http.request_completed.connect(_on_request_completed)

# -------------------------------------------------------------
# 1. CHECK ELIGIBILITY (HEAD)
# -------------------------------------------------------------
func check_eligibility(score: int):
	# Store the score temporarily so we can compare inside the callback
	# or just pass it via bind, but here we will just emit true/false.
	# Actually, we need to know the score to compare against the threshold.
	# We will attach metadata to the object or simply store it in a variable.
	self.set_meta("pending_score_check", score)

	http.cancel_request()
	current_request_type = RequestType.CHECK
	
	# HEAD request method is technically not a named constant in Godot 3, 
	# but in Godot 4 it is HTTPClient.METHOD_HEAD.
	http.request(api_url, [], HTTPClient.METHOD_HEAD)

# -------------------------------------------------------------
# 2. FETCHING & SUBMITTING (Existing)
# -------------------------------------------------------------
func fetch_around_rank(target_rank: int, window_size: int = 10):
	http.cancel_request()
	current_request_type = RequestType.FETCH
	var start_rank = int(max(1, target_rank - floor(window_size / 2)))
	var url = api_url + "?rank_start=%d&count=%d" % [start_rank, window_size]
	http.request(url)

func submit_score(p1_name: String, p2_name: String, score: int):
	http.cancel_request()
	current_request_type = RequestType.SUBMIT
	var data = {"name1": p1_name, "name2": p2_name, "score": score}
	var headers = ["Content-Type: application/json"]
	http.request(api_url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))

# -------------------------------------------------------------
# 3. RESPONSE HANDLING
# -------------------------------------------------------------
func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Server Error: ", response_code)
		# If checking eligibility fails, maybe default to TRUE to be safe?
		if current_request_type == RequestType.CHECK:
			self.eligibility_checked.emit(true)
		return

	# --- HANDLE HEAD REQUEST (CHECK) ---
	if current_request_type == RequestType.CHECK:
		_handle_check_response(headers)
		return

	# --- HANDLE JSON RESPONSES (GET/POST) ---
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK: return
	var response = json.data

	if current_request_type == RequestType.FETCH:
		if response.has("data"):
			self.scores_loaded.emit(response["data"])

	elif current_request_type == RequestType.SUBMIT:
		if response.has("status") and response["status"] == "saved":
			self.score_submitted.emit(response["rank"])
			fetch_around_rank(response["rank"]) # Auto-refresh

# -------------------------------------------------------------
# 4. HEADER PARSING HELPER
# -------------------------------------------------------------
func _handle_check_response(headers: PackedStringArray):
	var meta = {}
	
	# Godot returns headers as ["Header-Name: Value", "Header-Two: Value"]
	# We need to parse this into a Dictionary
	for h in headers:
		if ":" in h:
			var parts = h.split(":", true, 1) # Split only on first ':'
			var key = parts[0].strip_edges().to_lower()
			var val = parts[1].strip_edges()
			meta[key] = val

	# Extract values sent by PHP
	var count = int(meta.get("x-highscore-count", "0"))
	var limit = int(meta.get("x-highscore-limit", "100"))
	var threshold = int(meta.get("x-highscore-threshold", "0"))
	
	var user_score = self.get_meta("pending_score_check")
	var is_eligible = false

	if count < limit:
		# List isn't full, ANY score gets in
		is_eligible = true
	else:
		# List is full. 
		# In PHP we sort by Score DESC, Timestamp ASC (Older is better).
		# If user_score == threshold (lowest score), user is NEWER, so they lose tie.
		# Therefore, user strictly needs GREATER than threshold.
		is_eligible = (user_score > threshold)

	print("Eligibility Check: Score %d vs Threshold %d (Full: %s) -> %s" % [user_score, threshold, str(count==limit), str(is_eligible)])
	self.eligibility_checked.emit(is_eligible)
