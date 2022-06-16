wtwitch(1) ["Version 2.4.0"]

# NAME

wtwitch - terminal user interface for Twitch

# SYNOPSIS

wtwitch *[COMMAND]* _[args]_

# DESCRIPTION

Wtwitch is a terminal program that uses the Twitch API and the streamlink package to provide Twitch browsing, subscription, and playback functionality without signing up for a Twitch account and without loading or executing Twitch's proprietary JavaScript.

# COMMANDS

## Viewing and browsing streams

*w* _streamer_, *watch* _streamer_
	Watch the specified _streamer_.++
e.g. wtwitch *w* _dratnos_

*v* _streamer_ [optional VOD number], *vod* _streamer_ [optional VOD number]
	List the latest VODs from a _streamer_. Optionally, supply the number of the VOD you want to watch to open it in your default player.++
e.g. wtwitch *v* _dratnos_++
e.g. wtwitch *v* _dratnos 5_

*t*, *top*
	View the top games and streams on Twitch.++
e.g. wtwitch *t*

*g* _game_, *game* _game_
	View the top streamers for a specified _game_. Game names with spaces must be quoted, or the spaces must be escaped with \\.++
e.g. wtwitch *g* _"world of warcraft"_++
e.g. wtwitch *g* _world\\ of\\ warcraft_

*e* _search-term_
	Search games and categories for _search-term_. Search terms with spaces must be quoted, or the spaces must be escaped with \\.++
e.g. wtwitch *e* _warcraft_

*n* _search-term_
	Search streamers and channels for _search-term_. Search terms with spaces must be quoted, or the spaces must be escaped with \\.++
e.g. wtwitch *n* _warcraft_

*b* _streamer_, *block* _streamer_
	Block a specified _streamer_, preventing them from being listed in any output. If the streamer is already blocked, blocking them again will remove them from the blocklist. Use *b* without specifying a streamer to show your blocklist.++
You can block or unblock multiple streamers at once, by separating them with a space.++
e.g. wtwitch *b* _dratnos_++
e.g. wtwitch *b* _dratnos_ _emongg_ _sleepy_++
e.g. wtwitch *b*

## Subscriptions

*s* _streamer_, *sub* _streamer_
	Subscribe to a specific _streamer_.++
You can subscribe to multiple streamers at once, by separating them with a space.++
e.g. wtwitch *s* _dratnos_++
e.g. wtwitch *s* _dratnos_ _emongg_ _sleepy_

*u* _streamer_, *unsub* _streamer_
	Unsubscribe from a specified _streamer_.++
You can unsubscribe from multiple streamers at once, by separating them with a space.++
e.g. wtwitch *u* _dratnos_++
e.g. wtwitch *u* _dratnos_ _emongg_ _sleepy_

*c*, *check*
	View your player/quality settings and the status of the streamers you are subscribed to.++
e.g. wtwitch *c*

*o*
	View all online streamers you are subscribed to, and optionally open streams, with fzf. You must have fzf installed to use this feature.++
e.g. wtwitch *o*

## Configuration options

*p* _player_, *player* _player_
	Change the default _player_ that gets passed to Streamlink.++
e.g. wtwitch *p* _vlc_

*q* _quality_, *quality* _quality_
	Change the default _quality_ that gets passed to Streamlink. 1080p60, 720p60, 720p, 480p, 360p, 160p, best, worst, and audio_only are acceptable qualities. You can specify fallback qualities separated by a comma.++
e.g. wtwitch *q* _720p60,720p,best_

*f*
	Toggle the printing of offline subscriptions with wtwitch *c*.++
e.g. wtwitch *f*

*l*
	Toggle the usage of colors in wtwitch output.++
e.g. wtwitch *l*

## Miscellaneous

*h*, *help*
	Print a short usage guide.++
e.g. wtwitch *h*

*version*
	Print the current version of wtwitch.++
e.g. wtwitch *version*

# TAB COMPLETION

Wtwitch will try its best to complete your input. When tabbing after wtwitch *u*, wtwitch will list/fill in your current subscriptions, since it only makes sense to unsubscribe from someone you're subscribed to.

When tabbing after wtwitch *w*, wtwitch will get a list of your subscriptions that are online, and only list/fill in your subscribed streamers that are currently streaming (even though these are not the only streamers you can watch with *w*).

# DEFAULT BEHAVIOR

## Player

Wtwitch will tell Streamlink to use mpv by default. Wtwitch favors mpv because mpv supports Wayland and custom window titles, such as "Watching dratnos on Twitch". Wtwitch will use VLC automatically if you have VLC installed and don't have mpv installed.

You can set which video player you'd like wtwitch to pass to Streamlink with wtwitch *p* _player_. You can pass any player you'd pass to Streamlink, and wtwitch will make sure the player you're trying to set as the default player is in your \$PATH.

## Quality

Wtwitch tells Streamlink to choose the "best" quality by default. You can set which quality you'd like wtwitch to pass to Streamlink with wtwitch *q* _quality_. You can pass any quality you'd pass to Streamlink, including fallback qualities (like "720p,480p,worst"), and wtwitch will make sure your input is valid.

## Ads

Wtwitch tells Streamlink to bypass Twitch ads. If you want to support a streamer, consider donating to them directly rather than subscribing to them on Twitch, as Twitch takes a substantial portion (30-50%) of the subscription fee.

# FILES

Wtwitch supports the XDG Base Directory specification. If your $XDG_CONFIG_HOME and $XDG_CACHE_HOME are their default values (~/.config and ~/.cache respectively), the configuration and blocklist files are at ~/.config/wtwitch/config.json, and cache files are kept in ~/.cache/wtwitch.

You should never need to edit these files manually; you should use the commands listed under *COMMANDS* above.

## environment.sh

This file exists in wtwitch's config directory, and wtwitch will source this file before running. You can put commands or variables here for wtwitch to source. This is useful on macOS, for example, to set a custom $PATH or $PYTHONPATH to support non-standard dependency locations specifically for wtwitch.

# SYNCING SUBSCRIPTIONS

Wtwitch does not natively support syncing subscriptions across computers, but syncing subscriptions can be achieved easily using Syncthing and a utility already installed on your GNU/Linux computer. Syncthing is a powerful synchronization program for multiple operating systems licensed under the Mozilla Public License v2, which is FSF approved. You can look at Syncthing's homepage for more information, as well as their user documentation:

https://docs.syncthing.net/intro/getting-started.html

After setting up Syncthing on the computers on which you wish to sync subscriptions, copy your subscriptions file from ~/.config/wtwitch/config.json to a directory that you are syncing with Syncthing. Then link the file to the previous location. For example, if you copied your subscriptions file to ~/Documents/Config, you can link it to the correct location with the command:

ln -sf ~/Documents/Config/config.json ~/.config/wtwitch/config.json

# CHANGELOG

View the changelog for the latest installed version of wtwitch with the command:

pacman -Qc wtwitch

# LANGUAGES

Full support:++
	English

Partial support:++
	French/Français++
	German/Deutsch++
	Spanish/Español

User-contributed translations are welcome!

# BUGS

Please file requests and report any bugs at: https://github.com/krathalan/wtwitch/issues

*If you are reporting a bug, please attach a debug log.*

To start wtwitch in debug mode, set the environment variable WTWITCH_DEBUG=on. You should also redirect all output to a _log file_. You can run wtwitch in debug mode in a one-off command like so:

WTWITCH_DEBUG=on wtwitch [command] _&> debug.log_

# LICENSES

Wtwitch itself is licensed under the GPLv3.

## Dependencies

jq is licensed under the MIT license.

Streamlink is licensed under the 2-clause BSD license.

cURL is licensed under the MIT license.

VLC and mpv, should you choose either as your player, are both licensed under both the GPLv2 and LGPLv2.1 licenses.

All licenses, for wtwitch itself and its dependencies, are FSF approved: https://www.gnu.org/licenses/license-list.html
