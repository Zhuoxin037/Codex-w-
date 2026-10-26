# -*- coding: utf-8 -*-
"""只改法球"每刻/发射"两处的临时标记：tag -> scoreboard。

为什么不一并改 zx.ball_hit：
  hit 和 10 把法杖的 ball_hit 回调都用 `{target:"@e[tag=zx.ball_hit]"}` 这种
  **字符串里的选择器**传递目标。check.py 规则明确：`set value` 的字符串里写花括号
  会让 NBT 读取器配平错位、**整个函数不加载**（9 条命中）。所以 ball_hit 保留 tag
  —— 它只在命中那一瞬间脏两次，不是每刻。

只动两个文件：
  projectile/ball/tick_target.mcfunction   (zx.ball_touch，每刻一次)
  projectile/ball/fire.mcfunction          (zx.bt，每次发射一次)
"""
import re, sys

FILES = [
    r"D:\数据包\sweetdream\data\sweetdream\function\projectile\ball\tick_target.mcfunction",
    r"D:\数据包\sweetdream\data\sweetdream\function\projectile\ball\fire.mcfunction",
]

ADD_RE = re.compile(r'tag (\S*@[ea]\[[^\]]*\]) add (zx\.(?:ball_touch|bt))(?![\w.])')
REM_RE = re.compile(r'tag (\S*@[ea]\[[^\]]*\]) remove (zx\.(?:ball_touch|bt))(?![\w.])')
SEL_RE = re.compile(r'(?<![!])tag=(zx\.(?:ball_touch|bt))(?![\w.])')

APPLY = "--apply" in sys.argv
total = 0
for path in FILES:
    with open(path, "r", encoding="utf-8") as fh:
        lines = fh.read().split("\n")
    out = []
    n = 0
    for ln in lines:
        if ln.lstrip().startswith("#"):
            out.append(ln)
            continue
        new = ln
        new = ADD_RE.sub(lambda m: "scoreboard players set %s %s 1" % (m.group(1), m.group(2)), new)
        new = REM_RE.sub(lambda m: "scoreboard players reset %s %s" % (m.group(1), m.group(2)), new)
        new = SEL_RE.sub(lambda m: "scores={%s=1}" % m.group(1), new)
        if new != ln:
            n += 1
            print("  - %s" % ln.strip())
            print("  + %s" % new.strip())
        out.append(new)
    if n and APPLY:
        with open(path, "w", encoding="utf-8", newline="\n") as fh:
            fh.write("\n".join(out))
    print("== %s : %d 行" % (path.split("\\")[-1], n))
    total += n
print("%s 合计 %d 行" % ("[APPLY]" if APPLY else "[DRY-RUN]", total))
