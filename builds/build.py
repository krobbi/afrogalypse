import sys

def main(args: list[str]) -> int:
    """ Run the build script from arguments and return an exit code. """
    
    print(f"Hello, build.py!\n{len(args)} argument(s):")
    
    for index, arg in enumerate(args):
        print(f" * {index}: '{arg}'")
    
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
