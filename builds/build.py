import os
import sys

from collections.abc import Callable
from typing import Self

class Status:
    """
    A valid or invalid status with dependency statuses that can be
    resolved lazily.
    """
    
    _resolver: Callable[[], bool]
    """ The status' resolver. """
    
    _dependencies: tuple[Self]
    """ The status' dependencies. """
    
    _is_resolved: bool = False
    """ Whether the status has been resolved. """
    
    _is_valid: bool = False
    """ Whether the status has been resolved as valid. """
    
    def __init__(
            self: Self,
            resolver: Callable[[], bool], *dependencies: Self) -> None:
        """ Initialize the status' resolver and dependencies. """
        
        self._resolver = resolver
        self._dependencies = dependencies
    
    
    def is_valid(self: Self) -> bool:
        """
        Return whether the status is valid, resolving it if necessary.
        """
        
        if self._is_resolved:
            return self._is_valid
        
        for dependency in self._dependencies:
            if not dependency.is_valid():
                self._is_resolved = True
                return False
        
        self._is_valid = self._resolver()
        self._is_resolved = True
        return self._is_valid


class ConfigFile:
    """ A configuration file that can be loaded from disk. """
    
    _data: dict[str, str]
    """ The config file's raw data. """
    
    def __init__(self: Self) -> None:
        """ Initialize the config file's raw data. """
        
        self._data = {}
    
    
    def get(self: Self, key: str) -> str:
        """ Return a configuration string from its key. """
        
        return self._data.get(key, "")
    
    
    def get_list(self: Self, key: str) -> list[str]:
        """ Return a configuration list from its key. """
        
        elements: list[str] = []
        
        for element in self.get(key).split(","):
            element: str = element.strip()
            
            if element:
                elements.append(element)
        
        return elements
    
    
    def load(self: Self, path: str, *required_keys: str) -> bool:
        """
        Load the config file from a path and a set of required keys and
        return whether it was successful.
        """
        
        is_valid: bool = True
        
        try:
            with open(path) as file:
                for line in file:
                    line: str = line.strip()
                    
                    if not line or line.startswith(";"):
                        continue
                    
                    pair: list[str] = line.split("=", 1)
                    key: str = pair[0].strip()
                    value: str = pair[1].strip() if len(pair) == 2 else ""
                    
                    if not key and not value:
                        is_valid = err(
                                f"A line in '{path}' has no key or value.")
                    elif not key:
                        is_valid = err(
                                f"A value '{value}' in {path} has no key.")
                    elif not value:
                        is_valid = err(
                                f"Key '{key}' in '{path}' has no value.")
                    elif key in self._data:
                        is_valid = err(
                                f"Key '{key}' is already defined in {path}.")
                    elif key not in required_keys:
                        is_valid = err(
                                f"Key '{key}' is not allowed in '{path}'.")
                    else:
                        self._data[key] = value
        except OSError:
            return err(f"Could not read '{path}'.")
        
        for key in required_keys:
            if key not in self._data:
                is_valid = err(
                        f"Required key '{key}' is not defined in '{path}'.")
        
        return is_valid


class BuildSession:
    """
    A collection of actions and states that persist while the build
    script is running.
    """
    
    _config: ConfigFile
    """ The build session's config file. """
    
    _config_status: Status
    """ The status of the build session's config file. """
    
    _channels_status: Status
    """ The status of the build session's channels. """
    
    def __init__(self: Self) -> None:
        """ Initialize the build session's config file and statuses. """
        
        self._config = ConfigFile()
        self._config_status = Status(self._resolve_config)
        self._channels_status = Status(
                self._resolve_channels, self._config_status)
    
    
    def get_command_usage(self: Self) -> str:
        """ Return the command's usage string. """
        
        return (
                "Usage:"
                "\n * 'build help'            - Display this help message."
                "\n * 'build list'            - Display a list of channels."
                "\n * 'build clean'           - Clean all channels."
                "\n * 'build clean <channel>' - Clean a channel.")
    
    
    def run_command(self: Self, command: list[str]) -> bool:
        """ Run a command and return whether it was successful. """
        
        if len(command) == 1:
            if command[0] == "help":
                print(self.get_command_usage())
                return True
            elif command[0] == "list":
                return self.print_all_channels()
            elif command[0] == "clean":
                return self.clean_all_channels()
        elif len(command) == 2:
            if command[0] == "clean":
                return self.clean_channel(command[1])
        
        return err(self.get_command_usage())
    
    
    def print_all_channels(self: Self) -> bool:
        """ Print all channels and return whether it was successful. """
        
        def print_channel(channel: str) -> bool:
            """
            Print a channel and return whether it was successful.
            """
            
            print(channel)
            return True
        
        return self._each_channel(print_channel)
    
    
    def clean_all_channels(self: Self) -> bool:
        """ Clean all channels and return whether it was successful. """
        
        return self._each_channel(self.clean_channel)
    
    
    def clean_channel(self: Self, channel: str) -> bool:
        """ Clean a channel and return whether it was successful. """
        
        if not self._has_channel(channel):
            return False
        
        return self._clean_dir(channel)
    
    
    def _get_channels(self: Self) -> list[str]:
        """ Return the build session's channels. """
        
        return self._config.get_list("channels")
    
    
    def _has_channel(self: Self, channel: str) -> bool:
        """
        Return whether the build session has a channel and log an error
        message if it doesn't.
        """
        
        if not self._channels_status.is_valid():
            return False
        
        if channel in self._get_channels():
            return True
        else:
            return err(
                    f"Channel '{channel}' does not exist. (See 'build list'.)")
    
    
    def _each_channel(self: Self, action: Callable[[str], bool]) -> bool:
        """
        Call an action for each channel and return whether it was
        successful.
        """
        
        if not self._channels_status.is_valid():
            return False
        
        is_valid: bool = True
        
        for channel in self._get_channels():
            if not action(channel):
                is_valid = False
        
        return is_valid
    
    
    def _remove_file(self: Self, path: str) -> bool:
        """
        Return whether a file was removed and log an error message it it
        wasn't.
        """
        
        try:
            os.remove(path)
        except OSError:
            return err(f"Could not remove file {path}.")
        
        return True
    
    
    def _remove_dir(self: Self, path: str) -> bool:
        """
        Return whether an empty directory was removed and log an error
        message if it wasn't.
        """
        
        try:
            os.rmdir(path)
        except OSError:
            return err(f"Could not remove directory '{path}'.")
        
        return True
    
    
    def _clean_dir(self: Self, path: str, depth: int = 0) -> bool:
        """
        Recursively clean a directory and return whether it was
        successful.
        """
        
        if depth >= 8:
            return err(f"Cleaning depth exceeded at path '{path}'.")
        
        is_valid: bool = True
        
        try:
            with os.scandir(path) as dir:
                for entry in dir:
                    if entry.name == ".itch" and depth == 0:
                        continue
                    
                    if entry.is_file(follow_symlinks=False):
                        if not self._remove_file(entry.path):
                            is_valid = False
                    elif entry.is_dir(follow_symlinks=False):
                        if not (
                                self._clean_dir(entry.path, depth + 1)
                                and self._remove_dir(entry.path)):
                            is_valid = False
                    else:
                        is_valid = err(
                                f"Path '{entry.path}' is not a file or "
                                "directory.")
        except OSError:
            return err(f"Could not scan path '{path}'.")
        
        return is_valid
    
    
    def _resolve_config(self: Self) -> bool:
        """ Resolve and return the build session's config status. """
        
        return self._config.load("build.cfg", "channels")
    
    
    def _resolve_channels(self: Self) -> bool:
        """ Resolve and return the build session's channels status. """
        
        channels: list[str] = self._get_channels()
        
        if not channels:
            return err("Channel list is empty.")
        
        is_valid: bool = True
        seen_channels: list[str] = []
        
        for channel in channels:
            if channel not in seen_channels:
                seen_channels.append(channel)
                
                if not os.path.isfile(os.path.join(channel, ".itch")):
                    is_valid = err(f"Channel '{channel}' does not exist.")
            else:
                is_valid = err(f"Channel '{channel}' is already defined.")
        
        return is_valid


def err(message: str) -> bool:
    """ Log an error message and return `False`. """
    
    print(message, file=sys.stderr)
    return False


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
    
    is_valid: bool = BuildSession().run_command(args[1:])
    
    try:
        os.chdir(return_path)
    except OSError:
        return err("Could not change to return path.")
    
    return is_valid


if __name__ == "__main__":
    sys.exit(0 if main(sys.argv) else 1)
