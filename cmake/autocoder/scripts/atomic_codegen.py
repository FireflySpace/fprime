#!/usr/bin/env python3
import argparse
import filecmp
import os
import shutil
import subprocess
import sys
import tempfile

parser = argparse.ArgumentParser(
    usage="%(prog)s -d <out_dir> -- <codegen cmd> ..."
)
parser.add_argument("-d", required=True, dest="out_dir")

argv = sys.argv[1:]
if "--" not in argv:
    parser.error("expected `-- <codegen cmd>`")
# Passthrough cmd is after `--`; args before
split = argv.index("--")
args = parser.parse_args(argv[:split])
command = argv[split + 1:]

tmp = tempfile.mkdtemp(dir=args.out_dir, prefix=".atomic-codegen-")
# Replace references to out_dir w/ the tmp dir
cmd = [tmp if arg == args.out_dir else arg for arg in command]
try:
    result = subprocess.run(cmd)
    if result.returncode != 0:
        sys.exit(result.returncode)
    produced = [
        os.path.join(root, name)
        for root, _, files in os.walk(tmp)
        for name in files
    ]
    for src in produced:
        dst = os.path.join(args.out_dir, os.path.relpath(src, tmp))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if not os.path.exists(dst) or not filecmp.cmp(src, dst, shallow=False):
            os.replace(src, dst)
finally:
    shutil.rmtree(tmp, ignore_errors=True)
