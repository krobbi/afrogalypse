import os
import sys

from collections.abc import Callable

CHANNELS: tuple[str, str, str, str] = ("web", "win", "linux", "mac")
""" The build script's channels. """

def err(message: str) -> bool:
    """ Log an error message and return `False`. """
    
    print(message, file=sys.stderr)
    return False


def check_channel(channel: str) -> bool:
    """
    Return whether a channel exists and return an error if it does not.
    """
    
    return True if channel in CHANNELS else err(
            f"Channel '{channel}' does not exist.")


def is_entry_file(entry: os.DirEntry[str]) -> bool:
    """ Return whether a directory entry is a file or symbolic link. """
    
    if entry.is_file(follow_symlinks=False) or entry.is_symlink():
        return True
    
    try:
        return bool(os.readlink(entry.path))
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
    elif len(command) == 2:
        if command[0] == "clean":
            return clean_channel(command[1])
    
    return err(
            "Usage:"
            "\n * 'build clean'           - Clean all channels."
            "\n * 'build clean <channel>' - Clean a channel.")


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
