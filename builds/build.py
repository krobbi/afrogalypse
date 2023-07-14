import os
import sys

from collections.abc import Callable
from typing import Self

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
                        print(f"A line in '{path}' has no key or value.")
                        is_valid = False
                    elif not key:
                        print(f"A value '{value}' in '{path}' has no key.")
                        is_valid = False
                    elif not value:
                        print(f"Key '{key}' in '{path}' has no value.")
                        is_valid = False
                    elif key in self._data:
                        print(f"Key '{key}' is already defined in '{path}'.")
                        is_valid = False
                    elif key not in required_keys:
                        print(f"Key '{key}' is not allowed in '{path}'.")
                        is_valid = False
                    else:
                        self._data[key] = value
        except OSError:
            print(f"Could not read '{path}'.")
            return False
        
        for key in required_keys:
            if key not in self._data:
                print(f"Required key '{key}' is not defined in '{path}'.")
                is_valid = False
        
        return is_valid


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
    
    
    def run_command(self: Self, command: list[str]) -> bool:
        """ Run a command and return whether it was successful. """
        
        if len(command) == 1:
            if command[0] == "help":
                return self.print_command_usage()
            elif command[0] == "list":
                return self.print_all_channels()
        
        self.print_command_usage()
        return False
    
    
    def print_command_usage(self: Self) -> bool:
        """
        Print the command's usage and return whether it was successful.
        """
        
        print("Usage:")
        print(" * 'build help' - Display this usage message.")
        print(" * 'build list' - Display a list of channels.")
        return True
    
    
    def print_all_channels(self: Self) -> bool:
        """ Print all channels and return whether it was successful. """
        
        if not self._channels_status.is_valid():
            return False
        
        for channel in self._get_channels():
            print(channel)
        
        return True
    
    
    def _get_channels(self: Self) -> list[str]:
        """ Return the build session's channels. """
        
        return self._config.get_list("channels")
    
    
    def _resolve_config(self: Self) -> bool:
        """ Resolve and return the build session's config status. """
        
        return self._config.load("build.cfg", "channels")
    
    
    def _resolve_channels(self: Self) -> bool:
        """ Resolve and return the build session's channels status. """
        
        channels: list[str] = self._get_channels()
        
        if not channels:
            print("Channel list is empty.")
            return False
        
        is_valid: bool = True
        seen_channels: list[str] = []
        
        for channel in channels:
            if channel in seen_channels:
                print(f"Channel '{channel}' is already defined.")
                is_valid = False
                continue
            
            seen_channels.append(channel)
            
            if not os.path.isfile(os.path.join(channel, ".itch")):
                print(f"Channel '{channel}' does not exist.")
                is_valid = False
        
        return is_valid


def main(args: list[str]) -> int | str:
    """
    Run the build script from arguments and return an exit code or error
    message.
    """
    
    try:
        builds_path: str = os.path.dirname(os.path.realpath(__file__))
    except NameError:
        if not args or args[0] in ("", "-c"):
            return "Could not find builds path from arguments."
        
        builds_path = os.path.realpath(args[0])
        
        if os.path.isfile(builds_path):
            builds_path = os.path.dirname(builds_path)
    
    if not os.path.isdir(builds_path):
        return "Could not find builds path."
    
    return_path: str = os.path.realpath(os.getcwd())
    
    if not os.path.isdir(return_path):
        return "Could not find return path."
    
    try:
        os.chdir(builds_path)
    except OSError:
        return "Could not change to builds path."
    
    exit_code: int = 0 if BuildSession().run_command(args[1:]) else 1
    
    try:
        os.chdir(return_path)
    except OSError:
        return "Could not change to return path."
    
    return exit_code


if __name__ == "__main__":
    sys.exit(main(sys.argv))
