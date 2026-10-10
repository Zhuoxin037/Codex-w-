#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""临时审计脚本: 盘点 sweetdream 实际内容, 与文档声称的数字对比。只读。"""
import os, re, json, collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EQ = os.path.join(ROOT, "sweetdream", "data", "sweetdream", "function", "equipment")

cats = {}
for cat in sorted(os.listdir(EQ)):
    p = os.path.join(EQ, cat)
    if not os.path.isdir(p):
        continue
    items = sorted(d for d in os.listdir(p) if os.path.isdir(os.path.join(p, d)))
    cats[cat] = items

total = 0
for cat, items in cats.items():
    print("%-8s %3d  %s" % (cat, len(items), " ".join(items)))
    total += len(items)
print("\n装备总数(equipment/<类>/<件>):", total)

# 强化材料
for kind in ("upgrade/item", "overlimit/item"):
    p = os.path.join(ROOT, "sweetdream", "data", "sweetdream", "function", *kind.split("/"))
    if os.path.isdir(p):
        f = [x[:-11] for x in os.listdir(p) if x.endswith(".mcfunction")]
        print("%-16s %3d  %s" % (kind, len(f), " ".join(sorted(f))))

# 各目录文件数
cnt = collections.Counter()
FP = os.path.join(ROOT, "sweetdream", "data", "sweetdream", "function")
for dp, _d, fs in os.walk(FP):
    for x in fs:
        if x.endswith(".mcfunction"):
            rel = os.path.relpath(dp, FP).replace("\\", "/").split("/")[0]
            cnt[rel] += 1
print("\nsweetdream function/ 各顶层目录 mcfunction 数:")
for k, v in cnt.most_common():
    print("   %-12s %4d" % (k, v))
print("   合计 %d" % sum(cnt.values()))

# 进度数量
adv = 0
AP = os.path.join(ROOT, "sweetdream", "data", "sweetdream", "advancement")
for dp, _d, fs in os.walk(AP):
    adv += sum(1 for x in fs if x.endswith(".json"))
print("\nadvancement json 数:", adv)

# check.py 规则数
with open(os.path.join(ROOT, ".workbuddy", "check.py"), encoding="utf-8") as fh:
    src = fh.read()
print("\ncheck.py 里形如 [问题描述] 的输出标签数:", len(re.findall(r'^\s*print\(f?"\[', src, re.M)))
print("check.py 文件大小: %d 字节, 行数 %d" % (len(src.encode()), src.count(chr(10)) + 1))

# 文档声称
for doc in ["README.md", "sweetdream/README.md"]:
    p = os.path.join(ROOT, doc)
    if os.path.exists(p):
        t = open(p, encoding="utf-8").read()
        hits = re.findall(r'(\d+)\s*(?:件装备|件|块石头|项|个函数)', t)
        print("\n%s 出现的数量声称(前 20): %s" % (doc, hits[:20]))
