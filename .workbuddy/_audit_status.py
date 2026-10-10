#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""临时审计脚本: 统计通用状态标签(渊海/流火/夜火/噬心/白昼梦/圣痕/升痕/蛊虫)在装备里的分布。只读。"""
import os, re, collections

EQ = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                  "sweetdream", "data", "sweetdream", "function")

TAGS = [("渊海", r"status\.yuanhai|渊海"),
        ("流火", r"status\.liuhuo|流火"),
        ("夜火", r"status\.yehuo|夜火"),
        ("噬心", r"status\.shixin|噬心"),
        ("白昼梦", r"status\.dream|白昼梦"),
        ("圣痕", r"sh_t\b|圣痕"),
        ("升痕", r"stg_t\b|升痕"),
        ("蛊虫", r"bl_gu|蛊虫")]

APPLY = re.compile(r"mark|apply_mark|tag @s add|tag @e.{0,60}add|施加|附加|贴上|铺")
TAKE = re.compile(r"unmark|mark_take|消耗|移除|清除|摘")

items = {}
for dp, _dd, fs in os.walk(EQ):
    for f in fs:
        if not f.endswith(".mcfunction"):
            continue
        p = os.path.join(dp, f)
        rel = os.path.relpath(p, EQ).replace("\\", "/")
        if not rel.startswith("equipment/"):
            continue
        item = "/".join(rel.split("/")[1:3])
        items.setdefault(item, "")
        items[item] += open(p, encoding="utf-8", errors="replace").read()

print("装备条数(equipment/<类>/<件>):", len(items))
print()
print("%-8s %8s %8s %8s" % ("标签", "涉及件数", "施加件数", "消耗件数"))
print("-" * 42)
for zh, pat in TAGS:
    rx = re.compile(pat)
    hit, ap, tk = set(), set(), set()
    for item, t in items.items():
        if not rx.search(t):
            continue
        hit.add(item)
        # 逐行看: 同一行里既有标签又有"施加/消耗"动词
        for line in t.splitlines():
            if not rx.search(line):
                continue
            if APPLY.search(line):
                ap.add(item)
            if TAKE.search(line):
                tk.add(item)
    print("%-8s %8d %8d %8d" % (zh, len(hit), len(ap), len(tk)))
    if tk:
        print("        消耗者: %s" % ", ".join(sorted(tk)))
