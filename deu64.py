"""
Deu64 — Base64 encoder / decoder
Usage (CLI):
    python deu64.py encode <text>
    python deu64.py decode <base64string>
"""

import base64
import sys


def encode(text: str) -> str:
    """Encode *text* to a Base64 string.

    Raises:
        UnicodeEncodeError: if *text* contains characters that cannot be
            encoded as UTF-8 (should not occur for well-formed Python strings).
    """
    return base64.b64encode(text.encode()).decode()


def decode(b64: str) -> str:
    """Decode a Base64 string back to plain text.

    Raises:
        binascii.Error: if *b64* is not valid Base64-encoded data.
        UnicodeDecodeError: if the decoded bytes are not valid UTF-8.
    """
    return base64.b64decode(b64.encode()).decode()


def main() -> None:
    if len(sys.argv) != 3 or sys.argv[1] not in ("encode", "decode"):
        print("Usage: python deu64.py encode|decode <value>")
        sys.exit(1)
    command, value = sys.argv[1], sys.argv[2]
    if command == "encode":
        print(encode(value))
    else:
        print(decode(value))


if __name__ == "__main__":
    main()
