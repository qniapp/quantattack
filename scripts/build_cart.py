#!/usr/bin/env python3
"""Build one quantattack cartridge with shrinko8.

  build_cart.py CART CONFIG OUTPUT [--src DIR] [--main FILE]

1. Preprocess every src/ file: keep `--#if SYMBOL` / `--#ifn SYMBOL` ... `--#endif` blocks
   only when SYMBOL is (or, for #ifn, is not) one of the build's symbols, and write
   `x = x + e` as `x += e` where that cannot change the result (see compound_assign).
2. Bundle `require("path")` modules like picotool did: each module becomes
   `package._c["path"]=function() ... end`, loaded once by a small require().
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
REQUIRE = re.compile(r'\brequire\("([\w/]+)"\)')
LONG_OPEN = re.compile(r"\[=*\[")
LONG_CLOSE = re.compile(r"\]=*\]")
CONTINUED = re.compile(r"\s*([-+*/%^<>=~&|.,:)\]}(\[{\"']|(and|or)\b)")
COMPOUND = re.compile(r"^(\s*)([A-Za-z_][\w.]*) = \2 ([-+*/]) (.+?)\s*$")
REQUIRE_FUNCTION = """function require(p)
local l=package.loaded
if (l[p]==nil) l[p]=package._c[p]()
if (l[p]==nil) l[p]=true
return l[p]
end
"""
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


def compound_assign_lines(lines):
    """Apply compound_assign to each line that is a whole statement outside long strings."""
    out, long_open = [], False
    for i, line in enumerate(lines):
        # Inside a long string or comment ([[ ... ]], [=[ ... ]=], --[[ ... ]]): leave it.
        starts_long = bool(LONG_OPEN.search(line))
        if long_open or starts_long:
            out.append(line)
            long_open = (long_open or starts_long) and not LONG_CLOSE.search(line.split("[", 1)[-1])
            continue
        # A statement whose expression goes on below (blank and comment lines skipped) is not whole.
        after = next((n for n in lines[i + 1:] if n.strip() and not n.lstrip().startswith("--")), "")
        out.append(line if CONTINUED.match(after) else compound_assign(line))
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
    flat = re.sub(r'"[^"]*"|\'[^\']*\'', "s", rest)
    flat = re.sub(r"\b\d+\.\d+|\b0x[\da-f.]+", "n", flat)
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
    """Return the main file's code with every required module prepended, as picotool built it."""
    modules = {}  # require path -> code, in discovery order

    def visit(lines):
        for line in lines:
            if line.lstrip().startswith("--"):
                continue
            for name in REQUIRE.findall(line):
                if name not in modules:
                    modules[name] = None
                    code = preprocess(os.path.join(src, name + ".lua"), symbols)
                    modules[name] = code
                    visit(code)

    main_code = preprocess(os.path.join(src, main), symbols)
    visit(main_code)
    if not modules:
        return "".join(main_code)
    parts = ["package={loaded={},_c={}}\n"]
    for name, code in modules.items():
        parts.append(f'package._c["{name}"]=function()\n')
        parts.extend(code)
        parts.append("\nend\n")
    parts.append(REQUIRE_FUNCTION)
    parts.extend(main_code)
    return "".join(parts)


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
