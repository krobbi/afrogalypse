import configparser
import os
import random
import shutil
import subprocess
import sys

from collections.abc import Callable

VERSION: str = "1.0.0"
""" The version number to publish with. Only update when ready. """

PROJECT: str = "krobbizoid/afrogalypse"
""" The itch.io project to publish to. """

CHANNELS: tuple[str, str, str, str] = ("web", "win", "linux", "mac")
""" The build script's channels. """

PLAIN_CHANNELS: tuple[str] = ("web",)
""" The channels to not package with license text. """

godot: str = ""
""" The command to call Godot Engine. """

butler: str = ""
""" The command to call butler. """

has_config: bool | None = None
""" Whether the build script has a valid config file. """

has_godot: bool | None = None
""" Whether the build script has a Godot Engine command. """

has_butler: bool | None = None
""" Whether the build script has a butler command. """

def err(message: str) -> bool:
    """ Log an error message and return `False`. """
    
    print(message, file=sys.stderr)
    return False


def call_process(*args: str) -> bool:
    """ Call a process and return whether it was successful. """
    
    try:
        subprocess.check_call(args)
        return True
    except (subprocess.CalledProcessError, OSError):
        return err("Could not call process.")


def check_channel(channel: str) -> bool:
    """
    Return whether a channel exists and log an error message if it does
    not.
    """
    
    return True if channel in CHANNELS else err(
            f"Channel '{channel}' does not exist.")


def check_config() -> bool:
    """
    Return whether the build script has a valid config file and log an
    error message if it does not.
    """
    
    global has_config, godot, butler
    
    if has_config is None:
        try:
            config: configparser.ConfigParser = configparser.ConfigParser()
            config.read("build.cfg")
            godot = config.get("commands", "godot")
            butler = config.get("commands", "butler")
            has_config = True
        except configparser.Error:
            has_config = err("Could not read config.")
    
    return has_config


def check_godot() -> bool:
    """
    Return whether the build script has a Godot Engine command and log
    an error message if it does not.
    """
    
    global has_godot
    
    if has_godot is None:
        print("Checking Godot Engine...")
        has_godot = check_config() and call_process(godot, "--version")
    
    return has_godot


def check_butler() -> bool:
    """
    Return whether the build script has a butler command and log an
    error message if it does not.
    """
    
    global has_butler
    
    if has_butler is None:
        print("Checking butler...")
        has_butler = check_config() and call_process(butler, "version")
    
    return has_butler


def is_entry_file(entry: os.DirEntry[str]) -> bool:
    """ Return whether a directory entry is a file or symbolic link. """
    
    if entry.is_file(follow_symlinks=False) or entry.is_symlink():
        return True
    
    try:
        return bool(os.readlink(entry))
    except OSError:
        return False


def clean_dir(path: str, depth: int = 0) -> bool:
    """
    Recursively clean a directory and return whether it was successful.
    May raise an `OSError`.
    """
    
    if depth >= 8:
        return err(f"Cleaning depth exceeded at '{path}'.")
    
    with os.scandir(path) as dir:
        for entry in dir:
            if entry.name == ".itch" and depth == 0:
                continue
            
            if is_entry_file(entry):
                os.remove(entry)
            elif entry.is_dir(follow_symlinks=False):
                if not clean_dir(entry.path, depth + 1):
                    return False
                
                os.rmdir(entry)
            else:
                return err(f"Broken directory entry at '{entry.path}'.")
    
    return True


def clean_channel(channel: str) -> bool:
    """ Clean a channel and return whether it was successful. """
    
    if not check_channel(channel):
        return False
    
    try:
        return clean_dir(channel, 0)
    except OSError:
        return err(f"Could not clean channel '{channel}'.")


def export_channel(channel: str) -> bool:
    """ Export a channel and return whether it was successful. """
    
    if (
            not check_channel(channel)
            or not check_godot()
            or not clean_channel(channel)
            or not call_process(
                    godot, "--path", "../..", "--headless",
                    "--export-release", channel)):
        return False
    
    if channel not in PLAIN_CHANNELS:
        try:
            shutil.copy("../../license.txt", channel)
        except shutil.Error:
            return err(f"Could not copy license text to channel '{channel}'.")
    
    return True


def publish_channel(channel: str) -> bool:
    """ Publish a channel and return whether it was successful. """
    
    return (
            check_channel(channel)
            and check_godot()
            and check_butler()
            and export_channel(channel)
            and call_process(
                    butler, "push", f"--userversion={VERSION}", channel,
                    f"{PROJECT}:{channel}"))


def publish_all_channels() -> bool:
    """ Publish all channels and return whether it was successful. """
    
    passcode: str = f"Yes. Version {VERSION}. #{random.randint(111, 999)}"
    print(f"Are you sure you want to publish? Enter '{passcode}' to continue.")
    prompt: str = input("> ")
    
    if prompt != passcode:
        print("Publishing canceled.")
        return True
    
    return for_each_channel(publish_channel)


def for_each_channel(action: Callable[[str], bool]) -> bool:
    """
    Call an action function for each channel and return whether they
    were all successful.
    """
    
    is_successful: bool = True
    
    for channel in CHANNELS:
        if not action(channel):
            is_successful = False
    
    return is_successful


def run_command(command: list[str]) -> bool:
    """ Run a build command and return whether it was successful. """
    
    if len(command) == 1:
        if command[0] == "clean":
            return for_each_channel(clean_channel)
        elif command[0] == "export":
            return for_each_channel(export_channel)
        elif command[0] == "publish":
            return publish_all_channels()
    elif len(command) == 2:
        if command[0] == "clean":
            return clean_channel(command[1])
        elif command[0] == "export":
            return export_channel(command[1])
    
    return err(
            "Usage:"
            "\n * 'build clean'            - Clean all channels."
            "\n * 'build clean <channel>'  - Clean a channel."
            "\n * 'build export'           - Export all channels."
            "\n * 'build export <channel>' - Export a channel."
            "\n * 'build publish'          - Publish all channels.")


def main(args: list[str]) -> bool:
    """
    Run the build script from arguments and return whether it was
    successful.
    """
    
    try:
        builds_path: str = os.path.dirname(os.path.realpath(__file__))
    except OSError:
        if not args or args[0] in ("", "-c"):
            return err("Could not find builds path from arguments.")
        
        builds_path = os.path.realpath(args[0])
        
        if os.path.isfile(builds_path):
            builds_path = os.path.dirname(builds_path)
    
    if not os.path.isdir(builds_path):
        return err("Could not find builds path.")
    
    return_path: str = os.path.realpath(os.getcwd())
    
    if not os.path.isdir(return_path):
        return err("Could not find return path.")
    
    try:
        os.chdir(builds_path)
    except OSError:
        return err("Could not change to builds path.")
    
    is_successful: bool = run_command(args[1:])
    
    try:
        os.chdir(return_path)
    except OSError:
        return err("Could not change to return path.")
    
    return is_successful


if __name__ == "__main__":
    sys.exit(0 if main(sys.argv) else 1)
