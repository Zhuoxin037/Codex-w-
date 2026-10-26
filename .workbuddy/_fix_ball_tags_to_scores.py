# -*- coding: utf-8 -*-
"""把法球临时标记从 tag 换成 scoreboard，消除"每刻给实体写 NBT"。

背景：JFR 显示 53.4% 的服务端时间在 EntityStorage.save -> NbtIo.writeCompressed
（含 ServerPlayer.save）。原因是法球发射/命中去给生物 add/remove 临时标签，
每次都会 Entity.setChanged() -> chunk 脏 -> 连玩家一起重新序列化压缩。

替换：
  tag @e[...] add zx.X      ->  scoreboard players set  @e[...] zx.X 1
  tag @e[...] remove zx.X   ->  scoreboard players reset @e[...] zx.X
  @e[tag=zx.X,...]          ->  @e[scores={zx.X=1},...]
"""
import os, re, sys, io

ROOT = r"D:\数据包\sweetdream\data"
TARGETS = ["zx.ball_touch", "zx.ball_hit", "zx.bt"]

ADD_RE = re.compile(r'tag (\S*@[ea]\[[^\]]*\]) add (zx\.(?:ball_touch|ball_hit|bt))(?![\w.])')
REM_RE = re.compile(r'tag (\S*@[ea]\[[^\]]*\]) remove (zx\.(?:ball_touch|ball_hit|bt))(?![\w.])')
SEL_RE = re.compile(r'(?<![!])tag=(zx\.(?:ball_touch|ball_hit|bt))(?![\w.])')

APPLY = "--apply" in sys.argv

changed_files = 0
change_lines = 0
report = []

for base, dirs, files in os.walk(ROOT):
    for fn in files:
        if not fn.endswith(".mcfunction"):
            continue
        path = os.path.join(base, fn)
        with open(path, "r", encoding="utf-8") as fh:
            lines = fh.read().split("\n")
        out = []
        touched = 0
        for ln in lines:
            if ln.lstrip().startswith("#"):
                out.append(ln)
                continue
            new = ln
            new = ADD_RE.sub(lambda m: "scoreboard players set %s %s 1" % (m.group(1), m.group(2)), new)
            new = REM_RE.sub(lambda m: "scoreboard players reset %s %s" % (m.group(1), m.group(2)), new)
            new = SEL_RE.sub(lambda m: "scores={%s=1}" % m.group(1), new)
            if new != ln:
                touched += 1
                report.append((os.path.relpath(path, ROOT), ln.strip(), new.strip()))
            out.append(new)
        if touched:
            if APPLY:
                with open(path, "w", encoding="utf-8", newline="\n") as fh:
                    fh.write("\n".join(out))
            changed_files += 1
            change_lines += touched

print("%s 改动文件 %d 个 / 行 %d 条" % ("[APPLY]" if APPLY else "[DRY-RUN]", changed_files, change_lines))
for p, old, new in report:
    print("--- %s" % p)
    print("  - %s" % old)
    print("  + %s" % new)
