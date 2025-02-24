extends Node

const BASIC_BADGE_COLOR: = "#e69d00"
const BRO_BADGE_COLOR: = "#9d00e6"
const PAL_BADGE_COLOR: = "#ff2688"


#onready var Players: Players = get_node("/root/ToesSocks/Players")
#onready var Chat: Chat = get_node("/root/ToesSocks/Chat")
onready var Players = get_node("/root/ToesSocks/Players")
onready var Chat = get_node("/root/ToesSocks/Chat")

var History: Dictionary

var just_joined := true
# var greet_queue := [] # TODO Unused

func _init() -> void:
	_load_store()

func _ready() -> void:
	Players.connect("player_added", self, "init_player")
	Players.connect("player_removed", self, "init_player")
	Players.connect("ingame", self, "_on_game_entered")



#func _process(delta: float) -> void:
#	# breakpoint
#	if not Players.in_game: return


func _on_game_entered():
	var players: Array = Players.get_players()
#	if players.empty(): return

	var buddies = []
	for player in players:
		var id = Players.get_id(player)
		buddies.append({
			"id": id,
			"username": Players.get_username(player),
			"times_seen": get_times_seen(id)
		})
	buddies.sort_custom(self, "sort_buddies")

	Chat.write("== Buddy Radar ==")
	var found_some = false
	for buddy in buddies:
		if buddy.times_seen < 2: continue
		found_some = true
		Chat.write(get_times_seen_badge(buddy.id, false) + " (" + str(buddy.times_seen) + ") " + buddy.username )
	if !found_some: Chat.write("...No buddies here yet!")

	yield (get_tree().create_timer(10.0), "timeout")
	just_joined = false


func get_times_seen(id: String) -> int:
	if id == Players.get_id(Players.local_player): return 0
	var history: Dictionary = History.get(id, {})
	return history.get("times_seen", 1)



func _load_store() -> void:
	# print("LOADING SEENT STORE")
	var STORE_PATH = "user://seent_history.json"
	var config_file = File.new()
	if config_file.file_exists(STORE_PATH):
		config_file.open(STORE_PATH, File.READ)
		var user_config_content = config_file.get_as_text()
		# print("STORE CONTENT", user_config_content)
		config_file.close()

		var parsed_json: JSONParseResult = JSON.parse(user_config_content)
		if parsed_json.error == OK:
			History = parsed_json.result
		else:
			print("Seent: Failed to parse history.json!!!!!!!!!")
			print(parsed_json.error_string)
			push_error(parsed_json.error_string)
			History["76561198017477230"] = {
				"username": "Toes",
				"times_seen": 1,
				"last_seen_in": 109775242119639488,
				"first_seen_at": "1993-05-01",
				"last_seen_at": "2025-02-01"
			}
			_save_store()
	else:
		print("Seent:History does not exist!!!!!!!!")
		History["76561198017477230"] = {
				"username": "Toes",
				"times_seen": 1,
				"last_seen_in": 109775242119639488,
				"first_seen_at": "1993-05-01",
				"last_seen_at": "2025-02-01"
			}
		_save_store()


func _save_store() -> void:
	var STORE_PATH = "user://seent_history.json"
	var config_file = File.new()
	config_file.open(STORE_PATH, File.WRITE)
	config_file.store_string(JSON.print(History, "	"))
	config_file.close()


func init_player(player: Actor) -> void:
	if not Players.is_player_valid(player): return
	var player_username = Players.get_username(player)
	var player_id = Players.get_id(player)
	var current_lobby = Network.STEAM_LOBBY_ID
	var is_friend = Steam.getFriendRelationship(player.owner_id) == 3

	if player_id == Players.get_id(Players.local_player): return

	var today = Time.get_date_string_from_system(true)
	if History.has(player_id):
		var history = History[player_id]
		var is_new_sighting = history.last_seen_at != today and history.last_seen_in != current_lobby
		if not is_new_sighting: return
		history.times_seen += 1
		history.last_seen_in = current_lobby
		history.last_seen_at = today

	else:
		if !just_joined: Chat.notify("It's your first time meeting " + player_username + ". Say hi!")
		History[player_id] = {
			"username": player_username,
			"times_seen": 1,
			"last_seen_in": current_lobby,
			"last_seen_at": today,
			"first_seen": today,
			"is_friend": is_friend
		}
	_save_store()



func get_times_seen_badge(id: String, rich: bool = true) -> String:
	var times_badge:= ""
	var times_seen = get_times_seen(id)
	var is_friend = Steam.getFriendRelationship(int(id)) == 3


	if times_seen > 10: times_badge += "*".repeat(min(5, max((times_seen -1) / 5, 1)))
	elif times_seen > 5: times_badge += "+".repeat(min(5, max((times_seen - 1)  / 5, 1)))
	elif times_seen > 1: times_badge += "•".repeat(min(5, max(times_seen -1, 1)))
	else: return ""

	var color: String = BRO_BADGE_COLOR if times_seen >= 20 else BASIC_BADGE_COLOR
	if is_friend: color = PAL_BADGE_COLOR
	if rich: times_badge = ("[color=%s]" % color) + (times_badge + "[/color]")

	times_badge = "[wave amp=25 freq=2]" +times_badge+ "[/wave]"
	times_badge = times_badge.trim_suffix(" ")
	if rich: times_badge = times_badge + "\n"
	# Chat.write(id + ":" + times_badge)
	return times_badge

func get_player_history(id: String):
	if !History.has(id): return false
	return History[id]


static func sort_buddies(budA, budB):
	return budA.times_seen > budB.times_seen
