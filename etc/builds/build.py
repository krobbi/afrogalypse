#!/usr/bin/env python3

import configparser
import os
import random
import shutil
import subprocess
import sys

from collections.abc import Callable
from typing import Self

VERSION: str = "1.0.1"
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

class BuildError(Exception):
    """ An error raised by a build command. """
    
    message: str
    """ The build error's error message. """
    
    def __init__(self: Self, message: str) -> None:
        """ Initialize the build error's error message. """
        
        super().__init__(message)
        self.message = message


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


def check_channel(channel: str) -> None:
    """ Raise an error if a channel does not exist. """
    
    if channel not in CHANNELS:
        raise BuildError(f"Channel '{channel}' does not exist.")


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
    
    check_channel(channel)
    
    try:
        return clean_dir(channel, 0)
    except OSError:
        return err(f"Could not clean channel '{channel}'.")


def export_channel(channel: str) -> bool:
    """ Export a channel and return whether it was successful. """
    
    check_channel(channel)
    
    if (
            not check_godot()
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
    
    check_channel(channel)
    
    return (
            check_godot()
            and check_butler()
            and export_channel(channel)
            and call_process(
                    butler, "push", f"--userversion={VERSION}", channel,
                    f"{PROJECT}:{channel}"))


def publish_all_channels() -> None:
    """ Publish all channels and return whether it was successful. """
    
    passcode: str = f"Yes. Version {VERSION}. #{random.randint(111, 999)}"
    print(f"Are you sure you want to publish? Enter '{passcode}' to continue.")
    prompt: str = input("> ")
    
    if prompt == passcode:
        for_each_channel(publish_channel)
    else:
        print("Publishing canceled.")


def for_each_channel(action: Callable[[str], bool]) -> None:
    """
    Call an action function for each channel and return whether they
    were all successful.
    """
    
    for channel in CHANNELS:
        if not action(channel):
            raise BuildError(f"Action failed on channel '{channel}'.")


def raise_usage_error() -> None:
    """ Raise a build command usage error. """
    
    raise BuildError(
            "Usage:"
            "\n * 'build clean'            - Clean all channels."
            "\n * 'build clean <channel>'  - Clean a channel."
            "\n * 'build export'           - Export all channels."
            "\n * 'build export <channel>' - Export a channel."
            "\n * 'build publish'          - Publish all channels.")


def run_command(command: list[str]) -> bool:
    """ Run a build command and return whether it was successful. """
    
    if len(command) == 1:
        if command[0] == "clean":
            for_each_channel(clean_channel)
        elif command[0] == "export":
            for_each_channel(export_channel)
        elif command[0] == "publish":
            publish_all_channels()
        else:
            raise_usage_error()
    elif len(command) == 2:
        if command[0] == "clean":
            return clean_channel(command[1])
        elif command[0] == "export":
            return export_channel(command[1])
        else:
            raise_usage_error()
    else:
        raise_usage_error()
    
    return True


def main() -> None:
    """
    Run the build script from arguments and exit if an error occured.
    """
    
    try:
        if not run_command(sys.argv[1:]):
            raise BuildError("An error occured during the build command.")
    except BuildError as build_error:
        sys.exit(build_error.message)


if __name__ == "__main__":
    main()
