#!/usr/bin/env python3
"""Build one quantattack cartridge with shrinko8.

  build_cart.py CART CONFIG OUTPUT [--src DIR] [--main FILE]

1. Preprocess every src/ file: keep `--#if SYMBOL` / `--#ifn SYMBOL` ... `--#endif` blocks
   only when SYMBOL is (or, for #ifn, is not) one of the build's symbols.
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
    return out


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
