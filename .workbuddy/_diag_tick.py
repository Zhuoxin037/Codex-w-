# -*- coding: utf-8 -*-
"""静态统计每刻（tick）调用链的命令量与实体扫描点。

从 data/minecraft/tags/function/tick.json 的入口出发，递归展开
   function <ns>:<path>
   function #<ns>:<tag>
统计：
  - 每个入口的唯一函数数 / 有效命令数（不含注释与空行）
  - 全链去重后的总有效命令数（= 单刻最坏情况下的命令条数下界）
  - 所有 `@e` / `@a` 选择器里的类型与 distance 范围（找全维度扫描）
"""
import os, re, json, collections, sys

ROOT = r"D:\数据包"
PACKS = [("sweetdream", os.path.join(ROOT, "sweetdream", "data")),
         ("manacore-1.0.0", os.path.join(ROOT, "manacore-1.0.0", "data"))]

FUNC = {}
TAGS = {}
for pname, d in PACKS:
    for base, dirs, files in os.walk(d):
        parts = os.path.relpath(base, d).replace("\\", "/").split("/")
        # 只处理 data/<ns>/function/... 与 data/<ns>/tags/function/...
        if len(parts) >= 2 and parts[1] == "function":
            namespace = parts[0]
            sub = "/".join(parts[2:])
            for fn in files:
                if not fn.endswith(".mcfunction"):
                    continue
                key = namespace + ":" + (sub + "/" + fn if sub else fn)[:-len(".mcfunction")]
                with open(os.path.join(base, fn), "r", encoding="utf-8", errors="replace") as fh:
                    FUNC[key] = fh.read().splitlines()
        elif len(parts) >= 3 and parts[1] == "tags" and parts[2] == "function":
            namespace = parts[0]
            sub = "/".join(parts[3:])
            for fn in files:
                if not fn.endswith(".json"):
                    continue
                key = namespace + ":" + (sub + "/" + fn if sub else fn)[:-len(".json")]
                try:
                    with open(os.path.join(base, fn), "r", encoding="utf-8") as fh:
                        TAGS.setdefault(key, []).extend(json.load(fh).get("values", []))
                except Exception:
                    pass

CMD_RE = re.compile(r"^\s*function\s+(#?)([a-z0-9_.\-]+:[a-z0-9_./\-]+)\s*$")
SEL_RE = re.compile(r"@[eanp]\[([^\]]*)\]|@[eanprs]\b")

def lines_of(key):
    return FUNC.get(key, [])

def resolve_tag(name, depth=0):
    out = []
    for v in TAGS.get(name, []):
        if isinstance(v, dict):
            v = v.get("id", "")
        if not isinstance(v, str):
            continue
        if v.startswith("#"):
            if depth < 6:
                out.extend(resolve_tag(v[1:], depth + 1))
        else:
            out.append(v)
    return out

def expand(roots, label):
    seen = set()
    stack = list(roots)
    total_cmds = 0
    empty_sel = 0
    sel_stats = collections.Counter()
    while stack:
        k = stack.pop()
        if k in seen:
            continue
        seen.add(k)
        for ln in lines_of(k):
            s = ln.strip()
            if not s or s.startswith("#"):
                continue
            total_cmds += 1
            m = CMD_RE.match(ln)
            if m:
                sub = m.group(2)
                if m.group(1):
                    for x in resolve_tag(sub):
                        if ":" not in x:
                            x = "minecraft:" + x
                        stack.append(x)
                else:
                    stack.append(sub)
                continue
            for sm in SEL_RE.finditer(s):
                body = sm.group(1) or ""
                sel_stats[sm.group(0)[:2]] += 1
                if "@e" in sm.group(0) and "type=" not in body and "tag=" not in body:
                    empty_sel += 1
    print("=== %s ===" % label)
    print("  唯一函数: %d   有效命令: %d（单刻下界）" % (len(seen), total_cmds))
    print("  裸 @e（无 type/tag 限定）: %d" % empty_sel)
    print("  选择器分布: %s" % dict(sel_stats.most_common(8)))
    return seen

def main():
    entries = []
    for v in TAGS.get("minecraft:tick", []):
        if isinstance(v, dict):
            v = v.get("id", "")
        if not isinstance(v, str):
            continue
        if v.startswith("#"):
            entries.extend(resolve_tag(v[1:]))
        else:
            entries.append(v)
    print("tick 入口共 %d 个" % len(entries))
    seen = expand(entries, "全部 tick 入口合计（去重）")
    print()
    print("=== 每个入口单独 ===")
    for e in entries:
        expand([e], e)

main()
