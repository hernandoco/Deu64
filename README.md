# Deu64

Deu64 is a lightweight Base64 encoder/decoder written in Python.

## Usage

### As a library

```python
from deu64 import encode, decode

encoded = encode("Hola mundo")  # "SG9sYSBtdW5kbw=="
decoded = decode("SG9sYSBtdW5kbw==")  # "Hola mundo"
```

### From the command line

```bash
python deu64.py encode "Hola mundo"
# SG9sYSBtdW5kbw==

python deu64.py decode "SG9sYSBtdW5kbw=="
# Hola mundo
```

## Running tests

```bash
python -m pytest test_deu64.py -v
```
