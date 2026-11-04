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

【本守门只查三条"必错且静默"的模式, 宁可少报也不误报】
  ① `run if/unless`      : run 之后接 if/unless, 必然解析失败。
     (正确写法: 把条件挂到同一条 execute 链上, 或写 `run execute if …`)
  ② `$` 行不含 `$(`      : 宏行没有任何占位符 = 白写 $, 典型是漏替换。
     (坑 156 同族: 这类行会让整个宏函数在调用时报"缺少参数"而作废)
  ③ `data … entity` / `store … entity` 的选择器可能匹配多个:
     NBT 路径(`data get/modify/merge entity`)与 `store result/success entity`
     **只接受唯一实体**, 选择器只要"允许多个"就在**加载期**抛
     `只允许一个实体，但提供的选择器允许多个实体` —— 整个函数作废。
     (2026-11-01 踩过: big_tick 的 `data modify entity @e[tag=zx.ex_model,distance=..3]`
     没有 limit=1 ⇒ 崇高之形整只不追踪/不推人/没伤害, 只有日志一行 Failed to load)
     @s/@p/@r 天然唯一, 不算; @e/@a 必须带 limit=1。

【用法】python .workbuddy/_chk_mcf_syntax.py
  输出末尾一行 `---- 问题 N 处`; 0 = 通过。

【2026-11-01 追加两条 —— 都是"用户实测坏了、而本脚本当时报 0"的真事故】
  ④ `scoreboard players operation` 参数不足 5 段:
     `scoreboard players operation <目标> <目标项> <运算符> <来源> <来源项>`
     漏写最后一个计分项(写成 `/= #sc_five`) ⇒ **加载期**报"未知或不完整的命令",
     整个函数作废。踩坑: sacrifice/cast L47, 表现是右键牺牲毫无反应、零日志。
     check.py 不查行语法, 本脚本之前也不查这条 —— 于是全绿却全废。
  ⑤ 自己新建 `zx:work a` 后投伤害, 却没转出 `num_str`:
     `internal/damage/deal` 的宏参数是 `$(num_str)`; 只写 `a.num` 时宏"缺少传入参数",
     整条 damage 静默失败。踩坑: detach/hit_go, 表现是"额外伤害未生效"、零日志。
     判据收紧到"本文件用 `set value` 新建 a", 避免把 `set from storage`(复制已含
     num_str 的节点) 和先调 payload 的弓类误报。
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

# 需要"唯一实体"的两个位置。选择器 token = 从 @ 开始到空白/行尾（选择器里没有空格）。
UNIQ_ENTITY = re.compile(r"\b(?:data\s+(?:get|modify|merge)|store\s+(?:result|success))"
                         r"\s+entity\s+(@[^ ]*)")

# ④ scoreboard players operation 必须 5 段
OP_LINE = re.compile(r"\bscoreboard\s+players\s+operation\s+(.*)$")
OPS = {"=", "+=", "-=", "*=", "/=", "%=", "<", ">", "><"}

# ⑤ 自建 a 却缺 num_str
A_NEW = re.compile(r"data\s+modify\s+storage\s+zx:work\s+a\s+set\s+value\b")
DMG_CALL = re.compile(r"internal/damage/(?:with_from|one)\b")


def scan(path):
    out = []
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            lines = fh.readlines()
        body = []
        for no, line in enumerate(lines, 1):
            s = line.strip()
            if not s or s.startswith("#"):
                continue
            body.append(s)
            if BAD_RUN.search(s):
                out.append((no, "run 后接 if/unless(必解析失败)",
                            s[:90]))
            if s.startswith("$") and "$(" not in s:
                out.append((no, "宏行不含 $(", s[:90]))
            for sel in UNIQ_ENTITY.findall(s):
                if sel.startswith("@s") or sel.startswith("@p") or sel.startswith("@r"):
                    continue
                if "limit=1" not in sel:
                    out.append((no, "data/store entity 的选择器允许多个实体"
                                    "(加 limit=1, 否则整个函数作废)",
                                s[:90]))
            # ④ scoreboard players operation 必须 5 段
            m = OP_LINE.search(s)
            if m:
                toks = m.group(1).split()
                if len(toks) < 5:
                    out.append((no, "operation 参数不足 5 段(漏了来源计分项 ⇒ "
                                    "加载期整函数作废)",
                                s[:90]))
                elif toks[2] not in OPS:
                    out.append((no, "operation 的运算符不认识(应为 = += -= *= /= %= < > ><)",
                                s[:90]))
        # ⑤ 自己新建 zx:work a 却忘了转 num_str（文件级判断）
        txt = "\n".join(body)
        if (A_NEW.search(txt) and DMG_CALL.search(txt)
                and "lib/num/plain" not in txt and "num_str" not in txt):
            out.append((0, "自建 zx:work a 后投伤害却没转 num_str ⇒ "
                           "deal 宏缺参数、伤害静默消失(在投递前加 "
                           "function sweetdream:lib/num/plain)",
                        path))
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
