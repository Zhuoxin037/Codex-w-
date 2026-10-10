# -*- coding: utf-8 -*-
"""生成 debug/reg_unroll.mcfunction 与 debug/menu.mcfunction 里的"逐槽解卷"行。

Minecraft 没有循环, 要把一张表逐行渲染只能一个槽一行写死。
这个脚本按 lib/reg/build.mcfunction 里的 cap 生成那些行, 保证槽数和上限一致。
用法: python .workbuddy/gen_reg_unroll.py
"""
import io
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FN = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function')

CAP_B = 56
CAP_A = 8
CAP_MENU = 12
CAP_LAYER = 20


def read(p):
    with io.open(p, encoding='utf-8') as f:
        return f.read()


def unroll_rows(list_name, macro, cap):
    out = []
    for i in range(cap):
        out.append(
            'execute if data storage zx:reg %s[%d] run function %s with storage zx:reg %s[%d]'
            % (list_name, i, macro, list_name, i))
    return out


def main():
    # ---- 校验 build 里的 cap 和这里一致 ----
    build = read(os.path.join(FN, 'lib', 'reg', 'build.mcfunction'))
    m = re.search(r'cap set value \{b:(\d+),a:(\d+),menu:(\d+),layer:(\d+)\}', build)
    assert m, 'build.mcfunction 里找不到 cap 行'
    cb, ca, cm, cl = int(m.group(1)), int(m.group(2)), int(m.group(3)), int(m.group(4))
    assert (cb, ca, cm, cl) == (CAP_B, CAP_A, CAP_MENU, CAP_LAYER), \
        'cap 不一致: build=(%d,%d,%d,%d) 脚本=(%d,%d,%d,%d)' % (cb, ca, cm, cl, CAP_B, CAP_A, CAP_MENU, CAP_LAYER)

    # ---- 校验实际行数没超上限 ----
    nb = len(re.findall(r'storage zx:reg b append value', build))
    na = len(re.findall(r'storage zx:reg a append value', build))
    nm = len(re.findall(r'storage zx:reg menu append value', build))
    nl = len(re.findall(r'storage zx:reg layer append value', build))
    for name, n, cap in (('b', nb, CAP_B), ('a', na, CAP_A), ('menu', nm, CAP_MENU), ('layer', nl, CAP_LAYER)):
        if n > cap:
            raise SystemExit('[错误] %s 表有 %d 行, 超过上限 %d —— 改 cap 并同步这里的常量' % (name, n, cap))
    print('表行数: b=%d/%d  a=%d/%d  menu=%d/%d  layer=%d/%d'
          % (nb, CAP_B, na, CAP_A, nm, CAP_MENU, nl, CAP_LAYER))

    # ---- 写 reg_unroll ----
    head = u'''# ============================================================
# sweetdream:debug/reg_unroll —— 把「通用数值注册表」逐行渲染出来
# ------------------------------------------------------------
# 【这个文件是生成的】改动请看 lib/reg/build.mcfunction, 然后跑
#   python .workbuddy/gen_reg_unroll.py
# 【为什么要写这么长】Minecraft 没有循环 —— 表里第 N 行就得有第 N 条命令
#   去取它。槽数 = build 里登记的 cap; 表比槽长的话多出来的行不会被显示,
#   check.py 第 16 项会提醒你。
# ============================================================

# ---------- b 表: 数值为 0 就不显示 ----------
'''
    body_b = '\n'.join(unroll_rows('b', 'sweetdream:debug/stat_row', CAP_B))
    mid = u'''

# ---------- a 表: 永远显示 ----------
'''
    body_a = '\n'.join(unroll_rows('a', 'sweetdream:debug/stat_row_a', CAP_A))
    with io.open(os.path.join(FN, 'debug', 'reg_unroll.mcfunction'), 'w', encoding='utf-8', newline='\n') as f:
        f.write(head + body_b + mid + body_a + '\n')
    print('写出 debug/reg_unroll.mcfunction  (%d + %d 行)' % (CAP_B, CAP_A))

    # ---- 写观测镜层数段: lib/look/layer_unroll ----
    #   它把 layer 表逐槽交给 lib/look/layer_row 处理(那支负责过滤 + 往
    #   zx:look.xline 追加组件, 接在动作栏冷却后面同一行)。
    lhead = u'''# ============================================================
# sweetdream:lib/look/layer_unroll —— 把「层数机制」表逐行喂给渲染器
# ------------------------------------------------------------
# 【这个文件是生成的】改动请看 lib/reg/build.mcfunction 的 layer 表, 然后跑
#   python .workbuddy/gen_reg_unroll.py
# 【谁调它】equipment/tool/look/render_go(观测镜刷新时, 拼第二行)
# 【为什么要写这么长】Minecraft 没有循环 —— 表里第 N 行就得有第 N 条命令。
#   槽数 = build 里登记的 cap(layer); 表比槽长的话多出来的行不会显示。
# 【执行者】玩家本人
# ============================================================

# ---------- layer 表: 只显示在身 / 在手上的层数机制 ----------
'''
    body_l = '\n'.join(unroll_rows('layer', 'sweetdream:lib/look/layer_row', CAP_LAYER))
    with io.open(os.path.join(FN, 'lib', 'look', 'layer_unroll.mcfunction'), 'w', encoding='utf-8', newline='\n') as f:
        f.write(lhead + body_l + '\n')
    print('写出 lib/look/layer_unroll.mcfunction  (%d 行)' % CAP_LAYER)

    # ---- 写 menu 的解卷行(单独一个片段, 由 menu.mcfunction 引用不现实, 直接生成整支) ----
    menu_head = u'''# ============================================================
# sweetdream:debug/menu —— 可点击的调试菜单
# ------------------------------------------------------------
# 【用法】/trigger zx.dbg_menu
# 【这个文件是生成的】条目表在 lib/reg/build.mcfunction 的 menu 里,
#   改完跑 python .workbuddy/gen_reg_unroll.py
# 【怎么可点击】1.21.5 起是 click_event(以前叫 clickEvent, 老写法在这一版不认):
#     {"click_event":{"action":"run_command","command":"/trigger zx.dbg_stats"}}
#   点击时**以点击者本人的身份**执行 —— 所以列的必须是玩家自己有权跑的
#   /trigger, 不能列需要 OP 的 /function。
# ============================================================

# 先清干净中间层, 免得某一项配错了读到上一项残留的值
data modify storage zx:work mi set value {name:"",obj:"",hint:""}

tellraw @s [{"text":"========== 调试菜单 ==========","color":"gold"}]
tellraw @s [{"text":"点下面的蓝色条目即可; 鼠标停上去有说明。","color":"dark_gray"}]
'''
    body_m = '\n'.join(
        'execute if data storage zx:reg menu[%d] run function sweetdream:debug/menu_item with storage zx:reg menu[%d]'
        % (i, i) for i in range(CAP_MENU))
    menu_tail = u'''

tellraw @s [{"text":"── 没上菜单的其它入口 ──","color":"dark_gray"}]
tellraw @s [{"text":"  用 /function 前缀 + sweetdream:debug/<名字>, 名字列表:","color":"gray"}]
tellraw @s [{"text":"    freeze / fix_noai / deepsea / deepsea_go / damage / true_damage / iframe","color":"gray"}]
tellraw @s [{"text":"    offhand / offhand_go / cold_crow / ember_immolate / leech_spine","color":"gray"}]
tellraw @s [{"text":"    iridescent_mirage / sickle / wind / num_probe","color":"gray"}]
tellraw @s [{"text":"    lore (重刷副手物品的描述, 老装备改规则后用)","color":"gray"}]
'''
# 注意: 这几行是**告诉玩家怎么手打命令**的纯文本, 里面不能出现
# "function sweetdream:debug/..." 这种"看起来像命令"的连写 ——
# check.py 第 1 项(函数引用检查)是靠正则扫全文的, 会把说明文字当成真调用,
# 报一条"引用了不存在的函数 sweetdream:debug/"。所以这里用的是
# "/function 前缀 + sweetdream:debug/<名字>" 这种拆开的写法。
    with io.open(os.path.join(FN, 'debug', 'menu.mcfunction'), 'w', encoding='utf-8', newline='\n') as f:
        f.write(menu_head + body_m + menu_tail)
    print('写出 debug/menu.mcfunction  (%d 行解卷)' % CAP_MENU)


if __name__ == '__main__':
    main()
