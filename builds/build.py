import os
import sys

from typing import Self

class BuildSession:
    """
    A collection of actions and states that persist while the build
    script is running.
    """
    
    def run_command(self: Self, command: list[str]) -> bool:
        """ Run a command and return whether it was successful. """
        
        if len(command) == 1:
            if command[0] == "help":
                return self.print_command_usage()
        
        self.print_command_usage()
        return False
    
    
    def print_command_usage(self: Self) -> bool:
        """
        Print the command's usage and return whether it was successful.
        """
        
        print("Usage:")
        print(" * 'build help' - Display this usage message.")
        return True


def main(args: list[str]) -> int | str:
    """
    Run the build script from arguments and return an exit code or error
    message.
    """
    
    try:
        builds_path: str = os.path.dirname(os.path.realpath(__file__))
    except NameError:
        if len(args) < 1 or args[0] in ("", "-c"):
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
