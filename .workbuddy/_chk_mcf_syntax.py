#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
_chk_mcf_syntax.py —— 抓"整函数作废"级别的语法错 (2026-10-21 新增)

【为什么要有这个守门】
  2026-10-21 我改了 projectile/ball/tick_target, 写成:
      execute unless score @s zx.ball_dist matches 3000 run unless block ~ ~ ~ ...
  `run` 后面必须跟一条**完整命令**, 而 `unless` 不是命令(只能做 execute 的子参数)。
  结果: 整个 tick_target 加载失败 -> 法球不推进、不画拖尾 -> 用户看到"法杖特效全没了"。
  而 check.py 当时报 0 问题 —— 它不做逐行命令语法校验。

【本守门只查两条"必错且静默"的模式, 宁可少报也不误报】
  ① `run if/unless`      : run 之后接 if/unless, 必然解析失败。
     (正确写法: 把条件挂到同一条 execute 链上, 或写 `run execute if …`)
  ② `$` 行不含 `$(`      : 宏行没有任何占位符 = 白写 $, 典型是漏替换。
     (坑 156 同族: 这类行会让整个宏函数在调用时报"缺少参数"而作废)

【用法】python .workbuddy/_chk_mcf_syntax.py
  输出末尾一行 `---- 问题 N 处`; 0 = 通过。
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TARGETS = [
    os.path.join(ROOT, "sweetdream", "data"),
    os.path.join(ROOT, "manacore-1.0.0", "data"),
]

BAD_RUN = re.compile(r"\brun\s+(if|unless)\s+")


def scan(path):
    out = []
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for no, line in enumerate(fh, 1):
                s = line.strip()
                if not s or s.startswith("#"):
                    continue
                if BAD_RUN.search(s):
                    out.append((no, "run 后接 if/unless(必解析失败)",
                                s[:90]))
                if s.startswith("$") and "$(" not in s:
                    out.append((no, "宏行不含 $(", s[:90]))
    except Exception as exc:                      # 读不了就报, 别静默
        out.append((0, "读取失败: %s" % exc, path))
    return out


def main():
    total = 0
    files = 0
    for base in TARGETS:
        for dirpath, _dirnames, filenames in os.walk(base):
            for name in filenames:
                if not name.endswith(".mcfunction"):
                    continue
                files += 1
                p = os.path.join(dirpath, name)
                hits = scan(p)
                if hits:
                    rel = os.path.relpath(p, ROOT)
                    for no, why, text in hits:
                        print("[错] %s:%d  %s\n       %s" % (rel, no, why, text))
                    total += len(hits)
    print("---- 扫描 %d 个 .mcfunction" % files)
    print("---- 问题 %d 处" % total)
    return 0


if __name__ == "__main__":
    sys.exit(main())
