# -*- coding: utf-8 -*-
"""
装备接线体检 —— 找出「写了但永远不会跑」的东西。

check.py 管**语法层**(写法的坑), 本脚本管**接线层**(寿命):
  · 孤岛函数: 定义了, 但从任何入口都走不到 => 效果压根不生效(静默)。
  · 进度指到不存在的奖励函数 => 触发了但什么都没发生。

【入口的定义】能从这里被发起调用就算合法
  1) tags/function/*.json 登记的项 —— 事件契约(manacore 会整组发起)
  2) advancement 的 rewards.function
  3) minecraft:tick / minecraft:load
  4) equipment/<类>/<件>/give · debug/* —— 玩家手动 /function
  5) **enchantment/*.json 的 run_function** —— 附魔 effects 事件(弩系全靠它, 2026-10-07 补)
  6) **回调字符串**: 把路径写进 NBT/storage 再由宏 $(x) 动态调用 ——
     例如普攻法球 `Hit:"sweetdream:…/ball_hit"` -> `function $(hit)`。
     这种路径先在边上着，**软可达**(见 sorrow 分级)。

【分级】
  · 硬孤岛: 全仓所有文本里都搜不到这个 `ns:path` 一处像样的调用告白 => 几乎一定是死代码。
  · 软可达: 只出现在 data 字符串/宏里(静态解析不出来) => 存在, 但听话率由业务保证。

用法:
  python .workbuddy/_audit_equip.py            # 全量
  python .workbuddy/_audit_equip.py --new      # 只看 git 未入库的新增目录
"""
import os
import re
import io
import sys
import json
import collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(ROOT, "sweetdream", "data")

fn_call = re.compile(r'function\s+(?:#)?([a-z0-9_]+):([a-z0-9_./]+)')
schedule = re.compile(r'schedule\s+(?:function\s+)?([a-z0-9_]+):([a-z0-9_./]+)')


def read(p):
    try:
        return io.open(p, encoding="utf-8", errors="replace").read()
    except Exception:
        return ""


def all_functions():
    out = {}
    for ns in os.listdir(DATA):
        base = os.path.join(DATA, ns, "function")
        if not os.path.isdir(base):
            continue
        for r, _d, fs in os.walk(base):
            for f in fs:
                if not f.endswith(".mcfunction"):
                    continue
                rel = os.path.relpath(os.path.join(r, f), base).replace("\\", "/")[:-11]
                out["%s:%s" % (ns, rel)] = os.path.join(r, f)
    return out


def all_tags():
    out = {}
    for ns in os.listdir(DATA):
        td = os.path.join(DATA, ns, "tags", "function")
        if not os.path.isdir(td):
            continue
        for r, _d, fs in os.walk(td):
            for f in fs:
                if not f.endswith(".json"):
                    continue
                rel = os.path.relpath(os.path.join(r, f), td).replace("\\", "/")[:-5]
                try:
                    j = json.load(io.open(os.path.join(r, f), encoding="utf-8"))
                except Exception as e:
                    print("!! tag JSON 坏: %s (%s)" % (f, e))
                    continue
                out["#%s:%s" % (ns, rel)] = j.get("values", [])
    return out


def all_enchantments():
    """附魔 effects 里 run_function 的目标"""
    out = []
    for ns in os.listdir(DATA):
        ed = os.path.join(DATA, ns, "enchantment")
        if not os.path.isdir(ed):
            continue
        for r, _d, fs in os.walk(ed):
            for f in fs:
                if not f.endswith(".json"):
                    continue
                txt = read(os.path.join(r, f))
                for m in re.finditer(r'"function"\s*:\s*"([a-z0-9_]+:[a-z0-9_./]+)"', txt):
                    out.append(m.group(1))
    return out


def all_advancements():
    out = {}
    for ns in os.listdir(DATA):
        ad = os.path.join(DATA, ns, "advancement")
        if not os.path.isdir(ad):
            continue
        for r, _d, fs in os.walk(ad):
            for f in fs:
                if not f.endswith(".json"):
                    continue
                rel = os.path.relpath(os.path.join(r, f), ad).replace("\\", "/")[:-5]
                try:
                    j = json.load(io.open(os.path.join(r, f), encoding="utf-8"))
                except Exception as e:
                    print("!! advancement JSON 坏: %s (%s)" % (f, e))
                    continue
                out["%s:%s" % (ns, rel)] = {"rewards": (j.get("rewards") or {}).get("function"),
                                            "file": os.path.join(r, f)}
    return out


def main():
    only_new = "--new" in sys.argv
    funcs = all_functions()
    tags = all_tags()
    advs = all_advancements()
    ench = all_enchantments()

    # tag 展开(含一层子 tag)
    tag_members = {tid: vals for tid, vals in tags.items()}
    for _ in range(3):
        for tid, vals in list(tag_members.items()):
            ex = []
            for v in vals:
                if v.startswith("#"):
                    ex += tag_members.get(v, [])
                else:
                    ex.append(v)
            tag_members[tid] = ex

    # 静态调用边
    edges = collections.defaultdict(set)
    for fid, path in funcs.items():
        for ln in read(path).split("\n"):
            ln = ln.strip()
            if not ln or ln.startswith("#"):
                continue
            for m in fn_call.finditer(ln):
                edges[fid].add(m.group(1) + ":" + m.group(2))
            m = schedule.search(ln)
            if m:
                edges[fid].add(m.group(1) + ":" + m.group(2))

    # 入口
    roots = set()
    for _tid, vals in tag_members.items():
        for v in vals:
            if not v.startswith("#"):
                roots.add(v)
    bad_adv = []
    for aid, info in advs.items():
        rf = info["rewards"]
        if not rf:
            continue
        if rf in funcs:
            roots.add(rf)
        else:
            bad_adv.append((aid, rf, info["file"]))
    roots.update(f for f in ench if f in funcs)
    for fid in funcs:
        if fid.endswith("/give") or fid.startswith("sweetdream:debug/"):
            roots.add(fid)

    # BFS
    seen = set()
    stack = [r for r in roots if r in funcs]
    while stack:
        cur = stack.pop()
        if cur in seen:
            continue
        seen.add(cur)
        for nx in edges.get(cur, ()):
            if nx in funcs and nx not in seen:
                stack.append(nx)

    # 全仓文本(含 json / mcmeta)出现过的 ns:path 字符串 -> 软可达
    mention = collections.defaultdict(list)
    for base in (os.path.join(DATA), os.path.join(ROOT, "sweetdream_rp_完整版")):
        for r, _d, fs in os.walk(base):
            for f in fs:
                if not f.endswith((".mcfunction", ".json", ".mcmeta", ".txt", ".md")):
                    continue
                p = os.path.join(r, f)
                txt = read(p)
                for fid in funcs:
                    if fid in txt:
                        mention[fid].append(os.path.relpath(p, ROOT).replace("\\", "/"))

    orphans = sorted(set(funcs) - seen)
    hard = [o for o in orphans if not mention.get(o)]
    soft = [o for o in orphans if mention.get(o)]

    print("=" * 70)
    print("装备接线体检")
    print("=" * 70)
    print("函数 %d · 入口 %d · 可达 %d · 孤岛 %d (硬 %d / 软 %d)"
          % (len(funcs), len(roots), len(seen), len(orphans), len(hard), len(soft)))
    print()

    if bad_adv:
        print("[A] advancement 奖励函数不存在 (%d) —— 触发了什么都不会发生:" % len(bad_adv))
        for aid, rf, _f in bad_adv:
            print("    %s -> %s" % (aid, rf))
        print()

    newdirs = None
    if only_new:
        try:
            import subprocess
            out = subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT)
            newdirs = set()
            for ln in out.decode("utf-8", "replace").split("\n"):
                if ln.startswith("?? ") and "/function/equipment/" in ln:
                    p = ln[3:].strip().replace("\\", "/")
                    i = p.index("/function/equipment/") + len("/function/equipment/")
                    parts = p[i:].split("/")
                    if len(parts) >= 2:
                        newdirs.add("/".join(parts[:2]))
        except Exception as e:
            print("(git 不可用: %s)" % e)

    def report(title, ids):
        grp = collections.defaultdict(list)
        for o in ids:
            ns, path = o.split(":", 1)
            parts = path.split("/")
            grp["/".join(parts[:3])].append(o)
        print(title)
        n = 0
        for key in sorted(grp):
            if newdirs is not None:
                rel = "/".join(key.split("/")[1:3])
                if rel not in newdirs:
                    continue
            print("  %s" % key)
            for o in sorted(grp[key]):
                print("      %s" % o.split(":", 1)[1])
                n += 1
        if not n:
            print("  (无)")
        print()

    report("[B] 硬孤岛 —— 全仓搜不到一处调用/提及, 基本确定是死代码:", hard)
    if not only_new:
        report("[C] 软可达 —— 只出现在字符串里(回调/宏), 业务保证:", soft)
    return 0


if __name__ == "__main__":
    sys.exit(main())
