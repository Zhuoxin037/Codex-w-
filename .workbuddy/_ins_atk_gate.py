# -*- coding: utf-8 -*-
"""
给全包"平A触发"的武器/护甲被动入口插入「满蓄力闸」。
口径(用户 2026-10-10 定): 平A 没蓄满力 -> 这一发不触发这些被动。

插入位置: 每个入口第一行 `advancement revoke ...` 之后
  (lib/rearm 契约: revoke 必须是奖励函数第一非注释行, 不能被顶掉)。

幂等: 文件里已含 `sweetdream:lib/atk_charge` 就跳过。
排除: sweetdream:upgrade/api/on_hit —— 它是"蓄力采样点 + 升级石系统", 不挂闸(见报告)。
"""
import io
import json
import os
import sys

ROOT = r"D:\数据包\sweetdream\data"
ADV = os.path.join(ROOT, "sweetdream", "advancement")
FN = os.path.join(ROOT, "sweetdream", "function")

GATE = [
    "# ---- 满蓄力闸(2026-10-10, 全包统一口径) ----\n",
    "#   平A 没**蓄满力**这一发就不触发本被动。判定与出参见 lib/atk_charge 头部\n",
    "#   (每刻只算一次 + 玩家级 `@s zx.atk_ok`)。\n",
    "#   ★ 必须排在 revoke 之后: lib/rearm 契约要求 revoke 是奖励函数第一非注释行。\n",
    "function sweetdream:lib/atk_charge\n",
    "execute unless score @s zx.atk_ok matches 1 run return 0\n",
]

EXCLUDE = {"sweetdream:upgrade/api/on_hit"}

advs = []
for dirpath, _dirs, files in os.walk(ADV):
    for f in files:
        if not f.endswith(".json"):
            continue
        p = os.path.join(dirpath, f)
        with io.open(p, encoding="utf-8") as fh:
            raw = fh.read()
        if "player_hurt_entity" not in raw:
            continue
        try:
            advs.append((p, json.loads(raw)))
        except Exception as e:  # noqa
            print("!! 解析失败", p, e)
            sys.exit(1)

changed = []
skipped = []
problems = []

for adv_path, d in sorted(advs):
    rew = (d.get("rewards") or {})
    fns = rew.get("function")
    if isinstance(fns, str):
        fns = [fns]
    if not fns:
        problems.append("进度没有 function 奖励: %s" % adv_path)
        continue
    for fnid in fns:
        if fnid in EXCLUDE:
            skipped.append((fnid, "排除(蓄力采样点/升级石系统)"))
            continue
        rel = fnid.split(":", 1)[1] + ".mcfunction"
        fp = os.path.join(FN, *rel.split("/"))
        if not os.path.exists(fp):
            problems.append("函数文件不存在: %s <- %s" % (fnid, adv_path))
            continue
        with io.open(fp, encoding="utf-8", newline="") as fh:
            text = fh.read()
        if "sweetdream:lib/atk_charge" in text:
            skipped.append((fnid, "已有闸(幂等跳过)"))
            continue
        lines = text.splitlines(keepends=True)
        idx = None
        for i, ln in enumerate(lines):
            s = ln.strip()
            if not s or s.startswith("#"):
                continue
            if s.startswith("advancement revoke"):
                idx = i
            break  # 只看第一非注释行
        if idx is None:
            problems.append("第一非注释行不是 advancement revoke: %s" % fp)
            continue
        lines[idx + 1:idx + 1] = GATE
        with io.open(fp, "w", encoding="utf-8", newline="") as fh:
            fh.write("".join(lines))
        changed.append(fnid)

print("=== 插闸完成 ===")
print("改动 %d 个入口:" % len(changed))
for c in changed:
    print("   +", c)
print("跳过 %d 个:" % len(skipped))
for c, why in skipped:
    print("   -", c, "->", why)
if problems:
    print("!! 问题 %d 条:" % len(problems))
    for p in problems:
        print("   ", p)
    sys.exit(1)
print("(无问题)")
