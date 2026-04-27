import pytest
from deu64 import decode, encode


def test_encode_basic():
    assert encode("hello") == "aGVsbG8="


def test_encode_empty():
    assert encode("") == ""


def test_decode_basic():
    assert decode("aGVsbG8=") == "hello"


def test_decode_empty():
    assert decode("") == ""


def test_roundtrip():
    for text in ["Deu64", "¡Hola mundo!", "abc123", "foo bar baz"]:
        assert decode(encode(text)) == text


def test_encode_unicode():
    encoded = encode("héllo")
    assert decode(encoded) == "héllo"


def test_decode_invalid_base64():
    import binascii
    with pytest.raises(binascii.Error):
        decode("not-valid-base64!!!")


def test_decode_non_utf8():
    import base64 as _b64
    # Bytes that are not valid UTF-8
    raw = _b64.b64encode(b"\xff\xfe").decode()
    with pytest.raises(UnicodeDecodeError):
        decode(raw)
