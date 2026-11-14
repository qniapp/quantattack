#!/usr/bin/env python3
"""Build one quantattack cartridge with shrinko8.

  build_cart.py CART CONFIG OUTPUT [--src DIR] [--main FILE]

1. Preprocess every src/ file: keep `--#if SYMBOL` / `--#ifn SYMBOL` ... `--#endif` blocks
   only when SYMBOL is (or, for #ifn, is not) one of the build's symbols, and write
   `x = x + e` as `x += e` where that cannot change the result (see compound_assign).
2. Inline `require("path")` modules: each module's code goes into a `do ... end` block where it
   is first required, so the cart needs no require() or package table. `local x = require("path")`
   becomes `local x` and a block that ends with `x = <the module's return value>`.
3. Minify with `shrinko8 --minify-safe-only` and add the cart data, label and title.

Symbols: the cart name, `sash` for endless and rush, and `tostring,dump` in debug builds.
"""

import argparse
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIRECTIVE = re.compile(r"\s*--#(if|ifn|endif)\b\s*(\w*)")
REQUIRE = re.compile(r'^(\s*)(?:local (\w+) = )?require\("([\w/]+)"\)\s*$')
CONTINUED = re.compile(r"\s*([-+*/%^<>=~&|.,:)\]}(\[{\"']|(and|or)\b)")
COMPOUND = re.compile(r"^(\s*)([A-Za-z_][\w.]*) = \2 ([-+*/]) (.+?)\s*$")
# Matches the PICO-8 version pico-boots wrote, so PICO-8 runs the carts with the same compatibility settings.
CART_VERSION = "27"


def symbols_for(cart, config):
    symbols = [cart]
    if config == "debug":
        symbols = ["tostring", "dump"] + symbols
    if cart in ("endless", "rush"):
        symbols.append("sash")
    return symbols


def preprocess(path, symbols):
    """Return the lines of `path` with inactive --#if/--#ifn blocks removed."""
    out, stack = [], []  # stack holds whether each open block is active
    with open(path, encoding="utf-8") as f:
        for line in f:
            m = DIRECTIVE.match(line)
            if not m:
                if all(stack):
                    out.append(line)
            elif m.group(1) == "endif":
                if not stack:
                    sys.exit(f"{path}: --#endif without --#if")
                stack.pop()
            else:
                stack.append((m.group(2) in symbols) != (m.group(1) == "ifn"))
    if stack:
        sys.exit(f"{path}: file ends inside --#if")
    return compound_assign_lines(out)


def code_lines(lines):
    """Return, per line, its Lua code with comments removed, or None when any of it lies in a
    long string or long comment ([[ ]], [=[ ]=], --[[ ]]) or in a quoted string that goes on to
    another line (a backslash at the end of a line): a small lexical scan of the whole text."""
    text, codes, i = "".join(lines), [], 0
    code, plain, close = [], True, None  # close: the delimiter that ends the open long bracket
    while i < len(text):
        ch = text[i]
        if close:
            plain, end = False, text.find(close, i)
            end = len(text) if end < 0 else end + len(close)
            for _ in range(text.count("\n", i, end)):
                codes.append(None)
            i, close = end, None
            continue
        if ch == "\n":
            codes.append("".join(code) if plain else None)
            code, plain, i = [], True, i + 1
            continue
        long = re.match(r"(--)?\[(=*)\[", text[i:])
        if long:
            close, plain = "]" + long.group(2) + "]", False
            i += long.end()
            continue
        if text.startswith("--", i):
            i = text.find("\n", i)
            i = len(text) if i < 0 else i
            continue
        if ch in "\"'":
            end = i + 1
            while end < len(text) and text[end] not in (ch, "\n"):
                end += 2 if text[end] == "\\" else 1
            string = text[i:end + 1] if end < len(text) and text[end] == ch else text[i:end]
            # Every line an escaped newline crosses gets None, and so does the line it ends on.
            for _ in range(string.count("\n")):
                codes.append(None)
                code = []
            plain = plain and "\n" not in string
            code.append(string)
            i += len(string)
            continue
        code.append(ch)
        i += 1
    if code or not text.endswith("\n"):
        codes.append("".join(code) if plain else None)
    return codes


def compound_assign_lines(lines):
    """Apply compound_assign to each line that is a whole statement of plain code."""
    codes = code_lines(lines)
    out = []
    for i, line in enumerate(lines):
        # The next line that has code; a long string or comment there counts as code too.
        after = next((c if c is not None else "[[" for c in codes[i + 1:] if c is None or c.strip()), "")
        if codes[i] is None or codes[i] != line.rstrip("\n") or CONTINUED.match(after):
            out.append(line)
        else:
            out.append(compound_assign(line))
    return out


def compound_assign(line):
    """Return `line` with `x = x + e` written as PICO-8's `x += e` (one token less, same cycles).

    src/ stays standard Lua for the unit tests, so this happens at build time. `x op= e` means
    `x = x op (e)`, so it rewrites only when `e` is one complete expression on this line whose
    operators outside brackets all bind tighter than `op`: `*`, `/`, `\\`, `%`, `^` for `+` and
    `-`; `^` for `*` and `/`.
    """
    m = COMPOUND.match(line)
    if not m:
        return line
    indent, name, op, rest = m.groups()
    if '"' in rest or "'" in rest:
        return line  # a string could hide an operator (escaped quotes): leave it
    flat = re.sub(r"\b\d+\.\d+|\b0x[\da-f.]+", "n", rest)
    while True:
        inner = re.sub(r"\([^()]*\)|\[[^\[\]]*\]|\{[^{}]*\}", "v", flat)
        if inner == flat:
            break
        flat = inner
    looser = r"[-+<>=~&|,(\[{]|\.\.|\b(or|and|not|function)\b"
    if op in "*/":
        looser += r"|[*/%\\]"
    if re.search(looser, flat):
        return line
    return f"{indent}{name} {op}= {rest}\n"


def bundle(src, main, symbols):
    """Return the main file's code with each module inlined in a do block at its first require."""
    seen = set()

    def expand(lines):
        out = []
        for line in lines:
            m = REQUIRE.match(line)
            if not m:
                out.append(line)
                continue
            indent, var, name = m.groups()
            if name in seen:
                if var:
                    sys.exit(f"{name}: required twice with a value")
                continue
            seen.add(name)
            code = expand(preprocess(os.path.join(src, name + ".lua"), symbols))
            if var:
                last = max(i for i, l in enumerate(code) if l.strip())
                value = code[last].strip()
                if not value.startswith("return "):
                    sys.exit(f"{name}: must end with return")
                code[last] = f"{var} = {value[7:]}\n"
                out.append(f"{indent}local {var}\n")
            out.append("do\n")
            out.extend(code)
            out.append("\nend\n")
        return out

    return "".join(expand(preprocess(os.path.join(src, main), symbols)))


def main():
    parser = argparse.ArgumentParser(description="Build one quantattack cartridge with shrinko8.")
    parser.add_argument("cart")
    parser.add_argument("config", choices=["debug", "release", "harness"])
    parser.add_argument("output")
    parser.add_argument("--src", default=os.path.join(ROOT, "src"))
    parser.add_argument("--main", help="main file inside --src (default: main_CART.lua)")
    args = parser.parse_args()

    version = open(os.path.join(ROOT, "data", "version.txt")).read().strip()
    symbols = symbols_for(args.cart, args.config)
    code = bundle(args.src, args.main or f"main_{args.cart}.lua", symbols)
    data = os.path.join(ROOT, "data", f"builtin_data_{args.cart}.p8")
    label = os.path.join(ROOT, "data", "metadata.p8")

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    with tempfile.NamedTemporaryFile("w", suffix=".lua", encoding="utf-8", delete=False) as f:
        f.write(code)
        bundled = f.name
    try:
        subprocess.run(
            [os.environ.get("SHRINKO8", "shrinko8"), bundled, args.output,
             "--minify-safe-only", "--output-version", CART_VERSION,
             "--merge", data, "gfx,gff,map,sfx,music",
             "--merge", label, "label",
             "--title", f"quantattack v{version} ({args.cart})", "--title", "by yasuhito"],
            check=True)
    finally:
        os.unlink(bundled)


if __name__ == "__main__":
    main()
