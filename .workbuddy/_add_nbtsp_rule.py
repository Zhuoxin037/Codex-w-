# -*- coding: utf-8 -*-
"""给 check.py 增加 nbtsp 规则: data 路径与 NBT 过滤器之间多空格 = 整函数加载失败。
(2026-10-07 fit 槽位改版真实踩到: updef."x" {req:""} 的空格让整条命令解析失败)"""
import io

P = ".workbuddy/check.py"
s = io.open(P, encoding="utf-8").read()

# 1) TITLE 增加 nbtsp
old1 = "         'dspace': '参数间出现连续两个空格(会让整个函数加载失败)',"
new1 = ("         'dspace': '参数间出现连续两个空格(会让整个函数加载失败)',\n"
        "         'nbtsp': 'data 的路径与 NBT 过滤器之间多了空格(过滤器必须紧贴路径, 如 "
        "Items[{Slot:0b}] / updef.\"x\"{req:\"\"}; 带空格 = 整条命令解析失败, 整个函数加载失败且不报行号)',")
assert old1 in s, "TITLE 锚点没找到"
s = s.replace(old1, new1)

# 2) R 初始化注册新键
old2 = "R = {k: [] for k in ['fn', 'tag', 'macro', 'sel', 'adv', 'json', 'rp', 'sched', 'dust',"
new2 = "R = {k: [] for k in ['fn', 'tag', 'macro', 'sel', 'adv', 'json', 'rp', 'sched', 'dust', 'nbtsp',"
assert old2 in s, "R 初始化锚点没找到"
s = s.replace(old2, new2)

# 3) 在 dspace 判定后追加 nbtsp 判定
old3 = ("        md = re.search(r'\\S {2,}\\S', nq)\n"
        "        if md:\n"
        "            R['dspace'].append((str(fp), i, s[:100] + '  <- 连续空格: ' + repr(md.group(0))))\n")
new3 = (old3
        + "\n"
        + "        # 21.5) data 的路径参数与 NBT 过滤器之间带了空格: `... updef.\"x\" {req:\"\"}` --\n"
        + "        #   过滤器是路径参数的一部分, 必须紧贴(`updef.\"x\"{req:\"\"}` / `Items[{Slot:0b}]`)。\n"
        + "        #   带空格 = 多出一个参数 = 整条命令解析失败 = **整个函数加载失败**,\n"
        + "        #   日志只有一行 Whilst parsing, 不给行号(2026-10-07 fit 槽位改版真实踩到)。\n"
        + "        #   只对 data 命令判(字符串字面量已挖空), 找 \"路径 空格 {\" 的形态。\n"
        + "        mn = re.search(r' data (?:get|modify|remove|merge) (?:storage|block|entity) "
        "\\S+ ([\\w.\\[\\]\"]+) \\{', nq)\n"
        + "        if mn:\n"
        + "            R['nbtsp'].append((str(fp), i, s[:100] + '  <- NBT 过滤器要紧贴路径: ' + repr(mn.group(0))))\n")
assert old3 in s, "dspace 判定锚点没找到"
s = s.replace(old3, new3, 1)

io.open(P, "w", encoding="utf-8", newline="").write(s)
print("patched ok")
