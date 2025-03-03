# Pip Pals

![Animated Pal](https://cdn.discordapp.com/attachments/1342324721089511484/1342329606530793636/2025-02-20_20-55-43.gif?ex=67b93d5d&is=67b7ebdd&hm=d3fe3d774862163d675b762c6a4cb3cca31ae9a0ddb4b546dfdbb3a5406e1ece&)

_Keep track of when and how you meet new buds! Cute badges show above players you've met before in past islands/lives._

## Known issues
- There is an unresolvable mod conflict with [TitleAPI](https://thunderstore.io/c/webfishing/p/LoafWF/TitleAPI/). 
And it cannot be used alongside Pip Pals. You can safely disable or uninstall it as it is an optional dependency.


## Changelog

### 1.2.1
- *Fixed* Crash on joining due to proximity charge with unknown Pals (Thanks: Annarie, RodaEssa)

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