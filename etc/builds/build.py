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

CHANNELS: list[str] = ["web", "win", "linux", "mac"]
""" The channels to build. """

PLAIN_CHANNELS: list[str] = ["web"]
""" The channels to not package with license text. """

godot: str = ""
""" The command to call Godot Engine with. """

butler: str = ""
""" The command to call butler with. """

has_checked_files: bool = False
""" Whether expected files have been checked for. """

has_checked_config: bool = False
""" Whether a valid config file has been checked for. """

has_checked_godot: bool = False
""" Whether a Godot Engine command has been checked for. """

has_checked_butler: bool = False
""" Whether a butler command has been checked for. """

class BuildError(Exception):
    """ An error raised by the build script. """
    
    message: str
    """ The build error's error message. """
    
    def __init__(self: Self, message: str) -> None:
        """ Initialize the build error's error message. """
        
        super().__init__(message)
        self.message = message


def call(*args: str) -> None:
    """ Call a process and raise an error if it failed. """
    
    try:
        subprocess.check_call(args)
    except (subprocess.CalledProcessError, OSError):
        raise BuildError("Could not call process.")


def check_files() -> None:
    """ Raise an error if expected files are not found. """
    
    global has_checked_files
    
    if not has_checked_files:
        for path in [
            "../../export_presets.cfg",
            "../../license.txt",
            "../../project.godot",
            "../.gdignore",
        ] + [f"{channel}/.itch" for channel in CHANNELS]:
            if not os.path.isfile(path):
                raise BuildError("Run the build script from 'etc/builds'.")
        
        has_checked_files = True


def check_channel(channel: str) -> None:
    """ Raise an error if a channel does not exist. """
    
    check_files()
    
    if channel not in CHANNELS:
        raise BuildError(f"Channel '{channel}' does not exist.")


def check_config() -> None:
    """ Raise an error if a valid config file does not exist. """
    
    global has_checked_config, godot, butler
    
    if not has_checked_config:
        if not os.path.isfile("build.cfg"):
            raise BuildError("Create a 'build.cfg' file.")
        
        try:
            config: configparser.ConfigParser = configparser.ConfigParser()
            config.read("build.cfg")
            godot = config.get("commands", "godot")
            butler = config.get("commands", "butler")
        except configparser.Error:
            raise BuildError("Could not parse 'build.cfg'.")
        
        has_checked_config = True


def check_godot() -> None:
    """ Raise an error if a Godot Engine command does not exist. """
    
    global has_checked_godot
    
    if not has_checked_godot:
        print("Checking Godot Engine...")
        check_config()
        call(godot, "--version")
        has_checked_godot = True


def check_butler() -> None:
    """ Raise an error if a butler command does not exist. """
    
    global has_checked_butler
    
    if not has_checked_butler:
        print("Checking butler...")
        check_config()
        call(butler, "version")
        has_checked_butler = True


def is_entry_file(entry: os.DirEntry[str]) -> bool:
    """ Return whether a directory entry is a file or symbolic link. """
    
    if entry.is_file(follow_symlinks=False) or entry.is_symlink():
        return True
    
    try:
        return bool(os.readlink(entry))
    except OSError:
        return False


def clean_dir(path: str, depth: int = 0) -> None:
    """ Recursively clean a directory. May raise an OS error. """
    
    if depth >= 8:
        raise BuildError(f"Cleaning depth exceeded at '{path}'.")
    
    with os.scandir(path) as dir:
        for entry in dir:
            if entry.name == ".itch" and depth == 0:
                continue
            
            if is_entry_file(entry):
                os.remove(entry)
            elif entry.is_dir(follow_symlinks=False):
                clean_dir(entry.path, depth + 1)
                os.rmdir(entry)
            else:
                raise BuildError(f"Broken directory entry at '{entry.path}'.")


def clean_channel(channel: str) -> None:
    """ Clean a channel. """
    
    check_channel(channel)
    
    try:
        clean_dir(channel)
    except OSError:
        raise BuildError(f"Could not clean channel '{channel}'.")


def export_channel(channel: str) -> None:
    """ Export a channel. """
    
    check_channel(channel)
    check_godot()
    clean_channel(channel)
    call(godot, "--path", "../..", "--headless", "--export-release", channel)
    
    if channel not in PLAIN_CHANNELS:
        try:
            shutil.copy("../../license.txt", channel)
        except shutil.Error:
            raise BuildError(f"Could not copy license to channel '{channel}'.")


def publish_channel(channel: str) -> None:
    """ Publish a channel. """
    
    check_channel(channel)
    check_godot()
    check_butler()
    export_channel(channel)
    call(
            butler, "push", f"--userversion={VERSION}", channel,
            f"{PROJECT}:{channel}")


def for_each_channel(subroutine: Callable[[str], None]) -> None:
    """ Call a subroutine for each channel. """
    
    for channel in CHANNELS:
        subroutine(channel)


def publish_all_channels() -> None:
    """ Publish all channels. """
    
    passcode: str = f"Yes. Version {VERSION}. #{random.randint(111, 999)}"
    print(f"Are you sure you want to publish? Enter '{passcode}' to continue.")
    prompt: str = input("> ")
    
    if prompt == passcode:
        for_each_channel(publish_channel)
    else:
        print("Publishing canceled.")


def raise_usage_error() -> None:
    """ Raise a build command usage error. """
    
    raise BuildError(
            "Usage:"
            "\n * 'build clean'            - Clean all channels."
            "\n * 'build clean <channel>'  - Clean a channel."
            "\n * 'build export'           - Export all channels."
            "\n * 'build export <channel>' - Export a channel."
            "\n * 'build publish'          - Publish all channels.")


def run_command(command: list[str]) -> None:
    """ Run a build command. """
    
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
            clean_channel(command[1])
        elif command[0] == "export":
            export_channel(command[1])
        else:
            raise_usage_error()
    else:
        raise_usage_error()


def change_to_builds_dir() -> None:
    """ Change to the builds directory. """
    
    try:
        path: str = os.path.dirname(os.path.realpath(__file__))
    except NameError:
        if not sys.argv or sys.argv[0] in ("", "-c"):
            raise BuildError("Could not find builds directory from arguments.")
        
        path = os.path.realpath(sys.argv[0])
        
        if os.path.isfile(path):
            path = os.path.dirname(path)
    
    if not os.path.isdir(path):
        raise BuildError("Could not find builds directory.")
    
    try:
        os.chdir(path)
    except OSError:
        raise BuildError("Could not change to builds directory.")


def main() -> None:
    """
    Run a build command from arguments and exit if an error occured.
    """
    
    return_path: str = os.path.realpath(os.getcwd())
    
    if not os.path.isdir(return_path):
        sys.exit("Could not find return directory.")
    
    try:
        change_to_builds_dir()
        run_command(sys.argv[1:])
    except BuildError as build_error:
        sys.exit(build_error.message)
    finally:
        try:
            os.chdir(return_path)
        except OSError:
            sys.exit("Could not change to return directory.")


if __name__ == "__main__":
    main()
