# -*- coding: utf-8 -*-
"""
生成「万念 <-> 千散」的换手函数。

【为什么要生成而不是手写】
    换手要 `item replace ... with iron_sword[<一长串组件>]`, 这串组件必须和
    give.mcfunction 里那把**逐字节一致** —— 少一个 unbreakable、少一段
    custom_data, 换出来就是一把"看起来对、实际废了"的剑(进度认不出它,
    于是下一次右键什么都不发生, 而且一个字都不报)。
    手写两份必然漂移, 所以让它们和 give 出自同一个 build()。

【改数值/描述请改 _gen_batch5.py】本脚本只是把那边的产物换个动词包一层。
"""
import io
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _gen_batch5 import ITEMS, BASE  # noqa: E402

BY_ID = {it['id']: it for it in ITEMS}

# 方向: (从哪把, 换成哪把, 生成到哪个目录, 文件名)
PAIRS = [
    ('myriad', 'qiansan', 'sword/myriad', 'put_qian'),
    ('qiansan', 'myriad', 'sword/qiansan', 'put_my'),
]


def item_of(eid):
    """把 build() 产出的 'give @s iron_sword[...]' 剥成 'iron_sword[...]'"""
    g = None
    from _gen_batch5 import build
    g = build(BY_ID[eid])
    return g.split(' ', 2)[2]


def txt(src, dst, d, fn, item):
    a = BY_ID[src]['name']
    b = BY_ID[dst]['name']
    return '\n'.join([
        '# ============================================================',
        '# sweetdream:equipment/%s/%s —— 把手里的「%s」换成「%s」' % (d, fn, a, b),
        '# ------------------------------------------------------------',
        '# 【这个文件是生成的】改数值/描述请改 .workbuddy/_gen_batch5.py,',
        '#   然后重跑 `python .workbuddy/_gen_swap.py`(组件串必须和 give 一致,',
        '#   见本脚本头注释)。',
        '#',
        '# 【执行者】玩家本人(@s)   【谁调用它】equipment/<...>/swap(延迟几 tick 之后)',
        '# 【主手 / 副手】和通用回手线同一套判据: 先看主手, 主手不是再看副手。',
        '#   item replace 是覆盖式的 —— 写错槽位就等于把玩家那件装备吃掉, 所以',
        '#   判据必须写全, 而且"两把都不是"时下面两条都不成立(安静地什么都不做)。',
        '# ============================================================',
        '',
        '# ① 主手是%s -> 换主手' % a,
        'execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["%s"]}] run item replace entity @s weapon.mainhand with %s' % (src, item),
        'execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["%s"]}] at @s run playsound minecraft:item.armor.equip_iron player @a ~ ~ ~ 0.6 1.8' % dst,
        '',
        '# ② 主手不是、副手是%s -> 换副手' % a,
        'execute unless items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["%s"]}] if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["%s"]}] run item replace entity @s weapon.offhand with %s' % (src, src, item),
        'execute unless items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["%s"]}] if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["%s"]}] at @s run playsound minecraft:item.armor.equip_iron player @a ~ ~ ~ 0.6 1.8' % (src, dst),
        '',
        '# 【声音为什么跟在 replace 后面、判的是"换完之后"的新物品】放到上层 swap 里',
        '#   无条件响的话, 万一这两条都没匹配上(玩家这 3 tick 里把剑丢了), 就会',
        '#   "没换手却响一声" —— 比不响更误导。判新物品则天然只在换成了时才响。',
        '',
    ])


def main():
    for src, dst, d, fn in PAIRS:
        p = os.path.join(BASE, d, fn + '.mcfunction')
        io.open(p, 'w', encoding='utf-8', newline='\n').write(txt(src, dst, d, fn, item_of(dst)))
        print('%-40s %s -> %s' % ('equipment/%s/%s' % (d, fn), BY_ID[src]['name'], BY_ID[dst]['name']))
    print('---- 共 %d 个换手函数' % len(PAIRS))


if __name__ == '__main__':
    main()
