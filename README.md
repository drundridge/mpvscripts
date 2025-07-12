# mpv scripts
mpv scripts for retards

## [autotag.lua](/autotag)
Allows MPV to update the tags of media watched once played beyond a certain percentage in MPV (ie: to tag as "Watched" once the credits roll).

This allows you to keep track of which episode you're up to in your file manager natively while "Group by Tags" is enabled, the horizintal "bookmark" moving further up as you watch, eliminating the need for a seperate spreadsheet or bloat online tracking sites such as MAL.

<img src="/.readme_assets/screenshot.png?raw=true" />

The name of the tag applied, requisite watch percentage, and whitelisted directories are user configurable. Supports tagging symlinked files.

Also optionally removes symlinks after the linked episode is fully watched from seperately whitelisted directories, for the usecase of -- if you've configured qBittorrent to drop all new downloads to global "New Episodes" directory as a pseudo-playlist -- removing those playlist entries after completion as well. 

Only supports Linux. (Does Windows even support tags anymore?)

### Custom input.conf Keybinds:
| Keybind | Description |
| --- | --- |
| `<key name> script-binding autotag/ApplyTag` | Apply tag manually |
| `<key name> script-binding autotag/RemoveTag` | Remove Tag manually, then disable autotagging that file for the remainder of this viewing |
