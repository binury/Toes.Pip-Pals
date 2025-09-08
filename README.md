# Pip Pals

![pip_pals](https://github.com/user-attachments/assets/99227833-300d-4fe3-9caf-cd2bbf2246b6)

<br/>
<br/>

_Keep track of when and how you meet new pals! Cute badges show above players you've met before in past islands/lives._

## Support Pip Pals

If it has brought you joy, and you'd like to, you can support Pip Pals with a few fishbucks by clicking this badge
<a href='https://ko-fi.com/A0A3YDMVY' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi4.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

## Known issues

- There is an unresolvable mod conflict with [TitleAPI](https://thunderstore.io/c/webfishing/p/LoafWF/TitleAPI/).
  And it cannot be used alongside Pip Pals. You can safely disable or uninstall it as it is an optional dependency.

## Changelog

## 1.4.2

- Hotfix for leveling up while you are reeling issue(s)
  - Please report any issues your encounter related to Pal-Power level-ups

## 1.4.0 - Likely the final major update to Pip Pals

- NEW Level 50 pip effect
- NEW Level 20 pip effect
- Changed jiggle effect to no longer show always -> on and after level 10
- Cleaned up proximity power-up messages to be quieter and distracting
  - They were this way before powering up trigger animations and are not as necessary anymore
- [You can no longer be your own best pal](https://github.com/binury/Toes.Pip-Pals/issues/5)
  - Thank you for your reports: Theo, ATL448 !
- [Fixed some power calculations that did not account for proximity power-ups](https://github.com/binury/Toes.Pip-Pals/issues/6)
- [Fixed pips unintentionally being shown with "rich text formatting" where they were not intended to be](https://github.com/binury/Toes.Pip-Pals/issues/3)
- Many other misc. changes!

### Thank you to everyone who's supported Pip Pals and been encouraging or shared praise for the project. It's been great to be your pal. 💖

## 1.3.3

- Hotfixed unclosed tags in Proixmity Powerup messages!

### 1.3.2

- Reduced likelihood of seeing total Pals messages (5%)
- Changed random messages to only show when Pals seen is a significant number
- **New** random chance to be shown your `PALS HALL OF FAME`
  - Lists your top three Pals of all-time!
- Pal Scanner is _no longer shown_ when joining a \*completely empty lobby
- Mod incompatibility warning now shows _always_, rather than just once, if TitleAPI mod library is installed
  - This is precautionary in the event that the mod is accidentally auto-reinstalled later (due to being erroneously declared as a dependency)

### 1.3.1

- Fixed leveling up while busy possibly soft-locking player. Sorry!
- Added low % chance for message with total # of pals (for funsies)
- When seeing a pal whose name has changed, players will be notified about the change
  - This keeps track of aliases your pals have been seen with
  - Lets you know their old name and new name whenever they join, for the first time

### 1.3.0

- _New_ 30+ pal power pip effect
- Proximity powering up now shows an animation for you and your pal

### 1.2.4

- For all purposes, players which you have ignored are no longer considered to be your Pals

### 1.2.3

- Revert [change](#122) allowing pals seen once to be found by radar

### 1.2.2

- _Change_ Minor rephrasing of buddies -> pals for consistency
- _Fixed_ brand new pals were sometimes skipped by the radar, if met _once_ before

### 1.2.1

- _Fixed_ Crash on joining due to proximity charge with known Pals

### 1.2.0

- _NEW_ Pals can now collect `1x` additional pip _per day_ by powering up in proximity to each other long enough to charge up (~25min)
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
