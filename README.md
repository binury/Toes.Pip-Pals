# Pip Pals

<img src="https://i.imgur.com/2GzpE1W.gif">
<br/>
<br/>


_Keep track of when and how you meet new buds! Cute badges show above players you've met before in past islands/lives._


<br/>
<img src="https://i.imgur.com/tBYFSla.png">
<br/>
<a href='https://ko-fi.com/A0A3YDMVY' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi4.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

## Known issues
- There is an unresolvable mod conflict with [TitleAPI](https://thunderstore.io/c/webfishing/p/LoafWF/TitleAPI/). 
And it cannot be used alongside Pip Pals. You can safely disable or uninstall it as it is an optional dependency.


## Changelog

### 1.3.1
- Fixed leveling up while busy possibly soft-locking player. Sorry!
- Added low % chance for message with total # of pals (for funsies)
- When seeing a pal whose name has changed, players will be notified about the change
    - This keeps track of aliases your pals have been seen with
    - Lets you know their old name and new name whenever they join, for the first time

### 1.3.0
- *New* 30+ pal power pip effect
- Proximity powering up now shows an animation for you and your pal

### 1.2.4
- For all purposes, players which you have ignored are no longer considered to be your Pals

### 1.2.3
- Revert [change](#122) allowing pals seen once to be found by radar

### 1.2.2
- *Change* Minor rephrasing of buddies -> pals for consistency
- *Fixed* brand new pals were sometimes skipped by the radar, if met _once_ before

### 1.2.1
- *Fixed* Crash on joining due to proximity charge with known Pals

### 1.2.0
- *NEW* Pals can now collect `1x` additional pip _per day_ by powering up in proximity to each other long enough to charge up (~25min)
- This Pal Power metric is stored separately from `times-seen` but for your badges counts the same 1x encounter 

### 1.1.3
- Added TitleAPI incompatibility warning

### 1.1.0
- Changed pip display to: above name

### 1.0.4
- Hotfixed pip display bug
- Pips will now always animate
- Pip animations are more subtle

### 1.0.3
- Fixed local_player/self `seen_count` being always `15` (rather than always `0`)