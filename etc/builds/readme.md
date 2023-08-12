[![Afrogalypse logo.](/etc/images/logo.png)](/readme.md)

# Contents
1. [Building Afrogalypse](#building-afrogalypse)
2. [Dependencies](#dependencies)
   * [Godot Engine](#godot-engine)
   * [Rcedit](#rcedit)
   * [Python](#python)
   * [Butler](#butler)
   * [Build Configuration File](#build-configuration-file)
3. [Channels](#channels)
4. [Running the Build Script](#running-the-build-script)

# Building Afrogalypse
Afrogalypse is built from the command line using a custom script. This document
contains detailed documentation on setting up the build script's dependencies
and running the build script.

# Dependencies
Several dependencies must be met before the game can be built successfully. It
is important to read the following information carefully to make sure they are
set up correctly.

## Godot Engine
The game is created with [Godot Engine](https://godotengine.org), which is
needed to safely edit and export the game.

Different versions of the game expect different versions of Godot Engine. A
table of versions is shown below:
| Afrogalypse version | Godot Engine version |
| :------------------ | :------------------- |
| `1.0.0` - `1.1.0`   | `4.1.1`              |
| `1.0.0-jam`         | `4.0.3`              |

To export the game, export templates must be installed. This can be done in the
Godot Engine editor at `Editor > Manage Export Templates...`.

The game may need to be opened in the editor several times before exporting to
reimport assets.

The editor should be fully closed before exporting the game from the command
line.

## Rcedit
Godot Engine uses [rcedit](https://github.com/electron/rcedit) to set the icon
and metadata for Windows builds. Download an rcedit executable to a safe
location, and configure it in the Godot Engine editor at
`Editor > Editor Settings... > Export > Windows > rcedit`.

## Python
The game is built from the command line using a build script at
`etc/builds/build.py`. A modern version of [Python](https://python.org) is
needed to run this script.

The build script should ideally be run from `etc/builds/`, but the build script
will try to change to this directory and check that the necessary files can be
found.

The batch file `build.bat` allows Windows users to run this script as `build`
from the root of the repository.

## Butler
The game can optionally be published to [itch.io](https://itch.io) using
[butler](https://itchio.itch.io/butler). Butler allows games to be uploaded
with version numbers and creates patches between versions.

Butler is not used directly in the building process, but it is an optional
dependency for the build script.

## Build Configuration File
For exporting and publishing, the build script expects an
[INI](https://en.wikipedia.org/wiki/INI_file)-style configuration file at
`etc/builds/build.cfg`. This provides the build script with the commands to run
for Godot Engine and butler. Because this will vary between users and may
expose personal information, the build configuration file is ignored by the
repository.

An example of a possible build configuration file is shown below:
```ini
; Both keys must be in a section named 'commands'.
[commands]

; A key named 'godot' must exist containing the path or command to run Godot
; Engine. Paths may be absolute, or relative to the build script.
godot=C:\Users\Username\Documents\Godot\Godot_v4.1.1-stable_win64.exe

; A key named 'butler' must exist containing the path or command to run butler.
; This may be dummied out (e.g. 'butler=echo') if butler is not installed and
; you do not intend on publishing.
butler=butler
```

Other configuration data can be found near the top of the build script as
constants.

# Channels
The game is built to several 'channels' depending on the target platform. These
are names shared by the Godot Engine export presets, the build output
directories in `etc/builds/`, and the itch.io release channels.

The build output directories each contain a `.itch` file. These files make sure
that the directories are tracked by Git, but are ignored by butler. Do not
delete these files.

The available channels are `web`, `win`, `linux`, and `mac`.

# Running the Build Script
Building is done with a handful of commands once all of the
[dependencies](#dependencies) are met:

```bat
build clean [channel]
```
Delete the build output for all channels. Optionally delete the build output
for a single channel.

```bat
build export [channel]
```
Clean and export all channels. Optionally clean and export a single channel.

```bat
build publish
```
Clean, export, and publish all channels. A randomized passcode must be entered
for safety.

Building from the command line sometimes produces warnings. It is unclear what
the exact cause of this is. These warnings are usually cleared after the game
is first exported.
