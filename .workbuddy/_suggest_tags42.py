# -*- coding: utf-8 -*-
"""_suggest_tags42.py —— 按 _tags_data.py 的口径，从 42 件的规范化 lore 里
自动推导「候选标签」，供人工复核后写回 _tags_data.TAGS。

只做关键词命中（不是最终判据），目的是不漏项；最终以人工过一遍为准。
"""
import importlib.util
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

spec = importlib.util.spec_from_file_location('new42', os.path.join(HERE, '_new42_lore.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

# 词 -> 命中正则（按 _tags_data.py 的口径）
RULES = [
    ('liuhuo',     r'「流火」'),
    ('yehuo',      r'「夜火」'),
    ('shixin',     r'「噬心」'),
    ('yuanhai',    r'「渊海」'),
    ('dream',      r'「白昼梦」'),
    ('lightning',  r'闪电|落雷|雷击|雷电'),
    ('max_hp',     r'最大生命值|生命值上限'),
    ('base_atk',   r'基础攻击力'),
    ('max_mana',   r'最大魔力值|魔力值上限'),
    ('cur_mana',   r'当前魔力值|剩余魔力|消耗的魔力'),
    ('true_dmg',   r'真实伤害'),
    ('flat',       r'固定值|保底'),
    ('debuff',     r'缓慢|虚弱|发光|反胃|燃烧|冰冻|时停|击退|无法'),
    ('heal',       r'恢复[^。]{0,8}生命|回复[^。]{0,8}生命'),
    ('consume',    r'消耗|清除|移除'),
    ('apply',      r'附加'),
    ('buff',       r'迅捷|抗性提升|力量|再生|夜视|抗火|跳跃提升|隐身'),
    ('cd_down',    r'冷却时间 -|冷却时间-|减少 ?\d+ ?秒冷却|立即结束|刷新'),
    ('indep_mul',  r'独立乘区|技能伤害 \+'),
    ('summon',     r'“'),
    ('dash',       r'位移|击退|突进|瞬移|闪回|曳|冲'),
    ('attract',    r'拉向|吸引|牵引'),
    ('field',      r'领域'),
    ('formation',  r'术阵'),
    ('timestop',   r'时停'),
    ('freeze',     r'冰冻'),
    ('slow',       r'缓慢'),
]


def render(segs):
    lore = m.build_lore(segs)
    out = []
    for e in lore:
        t = e.get('text', '')
        if e.get('extra'):
            t += ''.join(s.get('text', '') for s in e['extra'])
        out.append(t)
    return '\n'.join(out)


def main():
    for it in m.ITEMS:
        txt = render(it['segs'])
        hits = [k for k, rx in RULES if re.search(rx, txt)]
        print('%-10s %-6s %-4s | %s' % (it['id'], it['name'], it['kind'], ' '.join(hits)))


if __name__ == '__main__':
    main()
