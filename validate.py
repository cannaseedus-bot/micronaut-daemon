"""CCC4 fixed vector-binding validation entry point.

Compatibility wrapper for validator.py; both commands produce the same
read-only binding candidate and grant no execution authority.
"""
from validator import main

if __name__ == "__main__":
    main()
