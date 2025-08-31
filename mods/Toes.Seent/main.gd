extends Node

const BASIC_BADGE_COLOR := "#e69d00"
const BRO_BADGE_COLOR := "#9d00e6"
const PAL_BADGE_COLOR := "#ff2688"

#onready var Players: Players = get_node("/root/ToesSocks/Players")
#onready var Chat: Chat = get_node("/root/ToesSocks/Chat")
onready var Players = get_node("/root/ToesSocks/Players")
onready var Chat = get_node("/root/ToesSocks/Chat")

var italics_font_data = preload("res://Assets/Themes/CartographCF-RegularItalic.otf")
var bold_italics_font_data = preload("res://Assets/Themes/CartographCF-BoldItalic.otf")

var History: Dictionary


class PlayerHistory:
	var username: String
	var times_seen: int
	var last_seen_in: int
#	var seen_lobby_name: String
	var first_seen_at: String
	var last_seen_at: String
	var prev_names: Array


export var proximity_charge_bank = {}

var just_joined := true
# var greet_queue := [] # TODO Unused


func _reverse(_str: String) -> String:
	var reversed := ""
	for i in range(_str.length() - 1, -1, -1):
		reversed += _str[i]
	return reversed


func _humanize_number(number: String) -> String:
	var dec: String
	if "." in number:
		dec = "." + number.split(".", false, 0)[1]
	if len(number.replace(dec, "")) < 4:
		return number
	else:
		var to_return: String
		var reversed := _reverse(number.replace(dec, ""))
		for i in range(reversed.length()):
			var item = reversed[i]
			if i != 0 and i % 3 == 0:
				item += ","
			to_return = item + to_return
		return to_return + dec


func _init() -> void:
	_load_store()


func _ready() -> void:
	Players.connect("player_added", self, "init_player")
	Players.connect("player_removed", self, "init_player")
	Players.connect("ingame", self, "_on_game_entered")


func _load_custom_italics_font():
	var fallback_font_data = load("res://Assets/Themes/unifont-16.0.01.otf")

	var gamechat = get_node("/root/playerhud/main/in_game/gamechat/RichTextLabel")

	var italics_font := DynamicFont.new()
	italics_font.font_data = italics_font_data
	italics_font.size = 22
	italics_font.outline_size = 1
	italics_font.outline_color = "#06f7f5ed"
	italics_font.add_fallback(fallback_font_data)
	gamechat["custom_fonts/italics_font"] = italics_font

	var bold_italics_font := DynamicFont.new()
	bold_italics_font.font_data = bold_italics_font_data
	bold_italics_font.size = 22
	bold_italics_font.outline_size = 1
	bold_italics_font.outline_color = "#06f7f5ed"
	bold_italics_font.add_fallback(fallback_font_data)
	gamechat["custom_fonts/bold_italics_font"] = bold_italics_font

	gamechat["custom_constants/table_vseparation"] = 5
	gamechat["custom_constants/line_separation"] = 2


func _process(delta: float) -> void:
	if not Players.in_game or not Players.local_player:
		return
	if just_joined:
		return

	var CHARGE_RANGE := 15.00
	var MINUTES_TO_FULL_CHARGE = 25
	var CHAT_CHAR_WIDTH := 30  # Apprx
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

				if Players.is_busy():
					while Players.is_busy():
						yield(get_tree().create_timer(3.0), "timeout")

				# TODO: Consolidate these?
				Players.local_player._level_up()
				Players.get_player(player)._level_up()

				Chat.write("\n[center][i]%s[/i][/center]" % Players.get_username(player))
				Chat.write("[center][rainbow][i][b]PAL PROXIMITY POWER-UP![/b][/i][/rainbow][/center]")
				Chat.write("[center][i]LEVEL\t[/i][rainbow]%s[/rainbow][/center]\n" % get_pal_power(player))

		else:
			proximity_charge_bank[player] = new_charge_level


func _on_game_entered():
	_load_custom_italics_font()

	just_joined = true
	_warn_if_incompat()

	var players: Array = Players.get_players()

	var buddies := []
	for player in players:
		var id = Players.get_id(player)
		buddies.append({"id": id, "username": Players.get_username(player), "times_seen": _get_times_seen(id)})
	buddies.sort_custom(self, "_sort_buddies")

	if players.size() > 0:
		Chat.write("[center][i]=== Pal Scanner ===[/i][/center]")
		var found_some = false
		for buddy in buddies:
			if buddy.times_seen <= 1 or Players.is_player_ignored(buddy.id):
				continue
			found_some = true
			Chat.write(
				(
					get_times_seen_badge(buddy.id, false)
					+ " ("
					+ _humanize_number(str(get_pal_power(buddy.id)))
					+ ") "
					+ buddy.username
				)
			)
		if !found_some:
			Chat.write("[i]Hmm...No pals here, yet![/i]")

	var met_min_pals = History.size() >= 100
	if (randf() <= 0.08 or players.size() < 1) and met_min_pals:
		var sorted_history := History.values()
		sorted_history.sort_custom(self, "_sort_buddies")
		buddies = sorted_history

		var ordinal_imgs := {
			0: "res://Assets/Textures/UI/countdown3.png",
			1: "res://Assets/Textures/UI/countdown2.png",
			2: "res://Assets/Textures/UI/countdown1.png"
		}

		var pal_standings := "[img]res://Assets/Textures/UI/knot_sep.png[/img][table=3]"
		# pal_standings += "[cell]Rank[/cell] [cell]Pal[/cell] [cell]Power Level[/cell]"
		for i in range(3):
			var buddy: Dictionary = buddies[i]
#			Chat.write("[img=36]%s[/img] %s - %s" % [ordinal_imgs[i], buddy.username, buddy.times_seen])
			pal_standings += "[cell][img=36]%s[/img]\t[/cell]" % ordinal_imgs[i]
			pal_standings += "[cell][i]%s[/i]\t[/cell]" % buddy.username
			pal_standings += "[cell]%s[/cell]" % _humanize_number(str(buddy.times_seen + buddy.proximity_power))
		pal_standings += "[/table]"
		var stars_img = "[img=48]res://Assets/Textures/Particles/emotion_particles2.png[/img]"
		Chat.write(
			"[center][wave amp=33 freq=1.05][i]%s PAL HALL OF FAME %s[/i][/wave][/center]" % [stars_img, stars_img]
		)
		Chat.write(pal_standings)

	if (randf() <= 0.05 or players.size() < 1) and met_min_pals:
		var follow_ups := [
			"Can you name them all?",
			"Who's your favorite?",
			"I wonder where they are now...",
			"You're pretty popular!",
			"Phenomenal!",
			"Did you know that?",
			"I hope you all stay in touch...",
			"Wow!"
		]

		var heart_img = "[img=36]res://Assets/Textures/UI/item_star.png[/img]"
		var pals_seen_msg = (
			"[i]You have met %s pals! %s %s[/i]"
			% [_humanize_number(str(History.size())), heart_img, follow_ups[randi() % follow_ups.size()]]
		)
		Chat.write(pals_seen_msg)

	if randf() <= 0.01:
		Chat.write(
			"[url=https://ko-fi.com/A0A3YDMVY][color=#008583][i]If it has brought you joy, and you'd like to, you can support Pip Pals with a few fishbucks by clicking this message[/i][/color][/url]"
		)
		Chat.write("[color=#35ffffff](This message is only shown once every 100 lobbies)[/color]")

	yield(get_tree().create_timer(30.0), "timeout")
	just_joined = false


func _get_times_seen(id: String) -> int:
	if id == Players.get_id(Players.local_player):
		return 0
	var history: Dictionary = History.get(id, {})
	return history.get("times_seen", 1)


func get_pal_power(id: String) -> int:
	if id == Players.get_id(Players.local_player) or Players.is_player_ignored(id):
		return 0
	var history: Dictionary = History.get(id, {})
	return _get_times_seen(id) + history.get("proximity_power", 0)


func _load_store() -> void:
	var STORE_PATH = "user://seent_history.json"
	var config_file = File.new()
	if config_file.file_exists(STORE_PATH):
		config_file.open(STORE_PATH, File.READ)
		var user_config_content = config_file.get_as_text()
		config_file.close()

		var parsed_json: JSONParseResult = JSON.parse(user_config_content)
		if parsed_json.error == OK:
			# TODO Hack/workaround needs rework (leftover History key)
			parsed_json.result.erase("_warned")
			History = parsed_json.result
			# TODO Sort?
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
		History["76561198017477230"] = {
			"username": "Toes",
			"times_seen": 1,
			"last_seen_in": 109775242119639488,
			"first_seen_at": "1993-05-01",
			"last_seen_at": "2025-02-01"
		}
		_save_store()


func _exit_tree() -> void:
	if !History.empty():
		_save_store()


func _save_store() -> void:
	var STORE_PATH = "user://seent_history.json"
	var config_file = File.new()
	config_file.open(STORE_PATH, File.WRITE)
	config_file.store_string(JSON.print(History, "	"))
	config_file.close()


func init_player(player: Actor) -> void:
	if !(Players.is_player_valid(player) and Players.is_player_valid(Players.local_player)):
		# Chat.notify("PP: Invalid player received")
		return
	var player_username = Players.get_username(player)
	var player_id = Players.get_id(player)
	# Quick leaves (?)
	if not Players.check(player_id):
		return
	# You can't be your own friend
	if Players.local_player == player:
		# Apparently this slipped through an early version of Pip Pals
		# so we'll erase the key just in case...
		History.erase(player_id)
		return
		# This is awkward so don't allow it
	if Players.is_player_ignored(player_id):
		return

	var current_lobby := Steam.getLobbyData(Network.STEAM_LOBBY_ID, "name")
	var lobby_code := Steam.getLobbyData(Network.STEAM_LOBBY_ID, "code")
	var today = Time.get_date_string_from_system(true)
	if History.has(player_id):
		var history = History[player_id]
		var is_new_sighting = history.last_seen_at != today and str(history.last_seen_in) != str(current_lobby)
		if not is_new_sighting:
			return
		history.times_seen += 1
		history.last_seen_in = current_lobby
		history.last_seen_at = today
		var username: String = Players.get_username(str(player_id))
		if history.username != username:
			Chat.notify("Remember your old pal %s? They're going by %s now" % [history.username, username])
			if "prev_names" in history and typeof(history.prev_names) == TYPE_ARRAY:
				history.prev_names.append(history.username)
			else:
				history.prev_names = [history.username]
			history.username = username
		var sightings = history.get("sightings", {})
		if sightings.has(current_lobby):
			sightings[current_lobby].times += 1
		else:
			sightings[current_lobby] = {
				"times": 1,
				"code": lobby_code
			}

	else:
		if !just_joined:
			Chat.notify("It's your first time meeting " + player_username + ". Say hi!")
		History[player_id] = {
			"id": player_id,
			"username": player_username,
			"times_seen": 1,
			"last_seen_in": current_lobby,
			"last_seen_at": today,
			"first_seen": today,
			"proximity_power": 0,
			"prev_names": [],
			"sightings": {
				current_lobby: {
					"times": 1,
					"code": lobby_code
				}
			}
		}
	_save_store()


func get_times_seen_badge(id: String, rich: bool = true) -> String:
	if str(Players.local_player.owner_id) == id or Players.check(id) == false or Players.is_player_ignored(id):
		return ""
	var times_badge := ""
	var pips := get_pal_power(id)

	# var is_friend = Steam.getFriendRelationship(int(id)) == 3	# var is_friend = Steam.getFriendRelationship(int(id)) == 3

	if pips > 10:
		times_badge += "*".repeat(min(5, max((pips - 1) / 5, 1)))
	elif pips > 5:
		times_badge += "+".repeat(min(5, max((pips - 1) / 5, 1)))
	elif pips > 1:
		times_badge += "•".repeat(min(5, max(pips - 1, 1)))
	else:
		return ""

	if rich:
		var badge_color: String = BRO_BADGE_COLOR if pips >= 20 else BASIC_BADGE_COLOR
		if pips >= 30:
			times_badge = "[rainbow]" + times_badge + "[/rainbow]"
		else:
			# COLOR WILL OVERRIDE RAINBOW
			times_badge = "[color=%s]%s[/color]" % [badge_color, times_badge]

		if pips >= 10:
			var clamped_amp = min(pips, 35)
			times_badge = "[wave amp=%s freq=2]%s[/wave]" % [clamped_amp, times_badge]
		if pips >= 20:
			times_badge = "[tornado radius=3 freq=2]" + times_badge + "[/tornado]"
		if pips >= 50:
			times_badge = "[shake rate=2 level=6]" + times_badge + "[/shake]"

		times_badge = times_badge.trim_suffix(" ")
		times_badge = times_badge + "\n"
	return times_badge


func _sort_buddies(budA: Dictionary, budB: Dictionary):
	return (
		budA.get("times_seen") + budA.get("proximity_power", 0)
		> budB.get("times_seen") + budB.get("proximity_power", 0)
	)


func _warn_if_incompat():
	var TitleAPI = get_node_or_null("/root/TitleAPI")
	if is_instance_valid(TitleAPI):
		Chat.write(
			(
				"[color=#8c0a22]You appear to have installed a conflicting mod which is known to [u]break Pip Pals!! [/u][/color]"
				+ "If you encounter issues, [u]disable or uninstall TitleAPI[/u]"
			)
		)
