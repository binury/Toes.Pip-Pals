extends Node

const BASIC_BADGE_COLOR: = "#e69d00"
const BRO_BADGE_COLOR: = "#9d00e6"
const PAL_BADGE_COLOR: = "#ff2688"


#onready var Players: Players = get_node("/root/ToesSocks/Players")
#onready var Chat: Chat = get_node("/root/ToesSocks/Chat")
onready var Players = get_node("/root/ToesSocks/Players")
onready var Chat = get_node("/root/ToesSocks/Chat")

var History: Dictionary

export var proximity_charge_bank = {}

var just_joined := true
# var greet_queue := [] # TODO Unused

func _init() -> void:
	_load_store()

func _ready() -> void:
	Players.connect("player_added", self, "init_player")
	Players.connect("player_removed", self, "init_player")
	Players.connect("ingame", self, "_on_game_entered")



func _process(delta: float) -> void:
	if not Players.in_game: return
	if just_joined: return

	var CHARGE_RANGE := 15.00
	var MINUTES_TO_FULL_CHARGE = 25
	var CHAT_CHAR_WIDTH := 30 # Apprx
	var players_within_range := []
	# TODO: Refactor this out of here
	var pos: Vector3 = Players.get_position(Players.local_player)
	for player in Players.get_players():
		var id = Players.get_id(player)
		var player_visible = not Players.is_player_ignored(id)
		if player_visible and pos.distance_to(Players.get_position(player)) <= CHARGE_RANGE:
			players_within_range.append(id)
	for player in players_within_range:
		var new_charge_level = proximity_charge_bank.get(player, 0.0) + delta
		var today := Time.get_date_string_from_system(true)
		var history: Dictionary = History.get(player, {})
		var last_bonus_received_on: String = history.get("last_bonus_received", "Never")
		if new_charge_level >= MINUTES_TO_FULL_CHARGE * 60.0:
			proximity_charge_bank[player] = 0.0
			if last_bonus_received_on != today:
				history.proximity_power = history.get("proximity_power", 0) + 1
				history.last_bonus_received = today
				_save_store()
				Players.local_player._level_up()
				Players.get_player(player)._level_up()


				Chat.write("[center][rainbow]" + "o".repeat(CHAT_CHAR_WIDTH) + "[/rainbow][/center]")
				Chat.write("[center]%s[/center]" % Players.get_username(player))
				Chat.write("[center][rainbow]PAL PROXIMITY POWER-UP![/rainbow][/center]")
				Chat.write("[center][rainbow]" + "o".repeat(CHAT_CHAR_WIDTH) + "[/rainbow][/center]")
		else:
			proximity_charge_bank[player] = new_charge_level





func _on_game_entered():
	just_joined = true
	_warn_if_incompat()

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

	Chat.write("== Pal Scanner ==")
	var found_some = false
	for buddy in buddies:
		if buddy.times_seen <= 1 or Players.is_player_ignored(buddy.id): continue
		found_some = true
		Chat.write(get_times_seen_badge(buddy.id, false) + " (" + str(buddy.times_seen) + ") " + buddy.username )
	if !found_some: Chat.write("...No pals here, yet!")

	yield (get_tree().create_timer(30.0), "timeout")
	just_joined = false


func get_times_seen(id: String) -> int:
	if id == Players.get_id(Players.local_player): return 0
	var history: Dictionary = History.get(id, {})
	return history.get("times_seen", 1)

func get_pal_power(id: String) -> int:
	if id == Players.get_id(Players.local_player) or Players.is_player_ignored(id): return 0
	var history: Dictionary = History.get(id, {})
	return history.get("proximity_power", 0)


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

func _exit_tree() -> void:
	if !History.empty(): _save_store()


func _save_store() -> void:
	var STORE_PATH = "user://seent_history.json"
	var config_file = File.new()
	config_file.open(STORE_PATH, File.WRITE)
	config_file.store_string(JSON.print(History, "	"))
	config_file.close()


func init_player(player: Actor) -> void:
	if !(Players.is_player_valid(player) and Players.is_player_valid(Players.local_player)) :
		# Chat.notify("PP: Invalid player received")
		return
	var player_username = Players.get_username(player)
	var player_id = Players.get_id(player)
	if Players.is_player_ignored(player_id):
		return
	var current_lobby = Network.STEAM_LOBBY_ID
	# var is_friend = Steam.getFriendRelationship(player.owner_id) == 3

	if Players.check(player_id) and player_id == Players.get_id(Players.local_player): return

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
			"proximity_power": 0,
			# "is_friend": is_friend
		}
	_save_store()



func get_times_seen_badge(id: String, rich: bool = true) -> String:
	if Players.check(id) == false or Players.is_player_ignored(id):
		return ""
	var times_badge:= ""
	var times_seen = get_times_seen(id)
	var pal_power = get_pal_power(id)
	var pip_sum = times_seen + pal_power
	var is_friend = Steam.getFriendRelationship(int(id)) == 3


	if pip_sum > 10: times_badge += "*".repeat(min(5, max((pip_sum -1) / 5, 1)))
	elif pip_sum > 5: times_badge += "+".repeat(min(5, max((pip_sum - 1)  / 5, 1)))
	elif pip_sum > 1: times_badge += "•".repeat(min(5, max(pip_sum -1, 1)))
	else: return ""

	var color: String = BRO_BADGE_COLOR if times_seen >= 20 else BASIC_BADGE_COLOR
	if is_friend: color = PAL_BADGE_COLOR
	if rich: times_badge = ("[color=%s]" % color) + (times_badge + "[/color]")
	if times_seen >= 30:
		times_badge = "[rainbow]" + times_badge + "[/rainbow]"

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

func _warn_if_incompat():
	if History.has("_warned"): return
	var TitleAPI = get_node_or_null("/root/TitleAPI")
	if is_instance_valid(TitleAPI):
		Chat.write(
			"[color=#8c0a22]You appear to have installed a conflicting mod which is known to [u]break Pip Pals!! [/u][/color]" +
			"If you encounter issues, [u]disable or uninstall TitleAPI[/u]"
		)
		History["_warned"] = true
