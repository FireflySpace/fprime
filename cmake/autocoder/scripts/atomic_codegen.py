#!/usr/bin/env python3
import filecmp
import os
import shutil
import subprocess
import sys
import tempfile

out_dir = sys.argv[1]
cmd = list(sys.argv[sys.argv.index("--") + 1:])
tmp = tempfile.mkdtemp(dir=out_dir, prefix=".atomic-codegen-")
try:
    cmd[cmd.index("-d") + 1] = tmp
    result = subprocess.run(cmd)
    if result.returncode != 0:
        sys.exit(result.returncode)
    produced = [
        os.path.join(root, name)
        for root, _, files in os.walk(tmp)
        for name in files
    ]
    for src in produced:
        dst = os.path.join(out_dir, os.path.relpath(src, tmp))
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        if not os.path.exists(dst) or not filecmp.cmp(src, dst, shallow=False):
            os.replace(src, dst)
finally:
    shutil.rmtree(tmp, ignore_errors=True)
