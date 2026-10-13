# -*- coding: utf-8 -*-
"""离线校验 give 命令的 SNBT 括号/引号平衡(游戏外能抓的最后一关)。

为什么需要: give 里一个没转义的引号 / 少一个方括号, 在**加载时**就会让整个
函数作废(日志 "Failed to load function"), 而文件本身看不出任何异常。
"""
import io, os, re, sys, json

BASE = r'D:\数据包\sweetdream\data\sweetdream\function\equipment'
NEW = [('sword', 'myriad'), ('sword', 'qiansan'), ('axe', 'agony'),
       ('staff', 'polarized_light'), ('staff', 'delusion'), ('staff', 'fallen_dream'),
       ('staff', 'apocalypse'), ('bow', 'sculk_echo'), ('bow', 'bone_erode'),
       ('bow', 'lucid_dream'), ('bow', 'rainbow'), ('armor', 'withered_garden'),
       ('armor', 'lightless_sea'), ('armor', 'furnace_core'), ('armor', 'resonance'),
       ('axe', 'anion'), ('staff', 'final_revelation'),
       # 新批次(2026-10-11《新的装备-超限等.md》, 只做 give)
       ('axe', 'sacred_relic'), ('axe', 'anchor'), ('axe', 'scorch_bone'),
       ('sword', 'tidemark'), ('sword', 'grayscale'), ('sword', 'crescent'),
       ('bow', 'dragon_tongue'), ('bow', 'cloudtrail'), ('bow', 'burst_dawn'),
       ('staff', 'triad'), ('staff', 'five_curses')]


def scan(s):
    """边扫边记: 括号深度 + 是否在字符串里 + 转义"""
    depth = {'[': 0, '{': 0}
    stack, inq, esc = [], False, False
    for c in s:
        if inq:
            if esc:
                esc = False
            elif c == '\\':
                esc = True
            elif c == '"':
                inq = False
            continue
        if c == '"':
            inq = True
        elif c in '[{':
            stack.append(c)
            depth[c] += 1
        elif c in ']}':
            if not stack:
                return '多出一个 %s' % c
            o = stack.pop()
            if (o, c) not in (('[', ']'), ('{', '}')):
                return '%s 配不上 %s' % (o, c)
            depth[o] -= 1
    if inq:
        return '字符串没收尾(引号落单)'
    if stack:
        return '少了收尾的 %s' % ''.join(stack)
    return None


bad = 0
for cat, cid in NEW:
    p = os.path.join(BASE, cat, cid, 'give.mcfunction')
    t = io.open(p, encoding='utf-8').read()
    lines = [l for l in t.split('\n') if l.startswith('give ')]
    if len(lines) != 1:
        print('[×] %-18s give 行有 %d 条(应为 1)' % (cid, len(lines)))
        bad += 1
        continue
    g = lines[0]
    err = scan(g)
    # 组件块必须存在
    miss = [k for k in ('item_name=', 'lore=[', 'unbreakable={}', 'custom_data={zx:[')
            if k not in g]
    # lore 必须能被 JSON 解析(方括号里那一段)
    m = re.search(r'lore=(\[.*?\]),unbreakable', g)
    lore_ok = False
    if m:
        try:
            json.loads(m.group(1))
            lore_ok = True
        except Exception as ex:
            err = err or ('lore 不是合法 JSON: %s' % ex)
    # ★ 附魔存在性(2026-10-05 加) ★
    #   give 里写了 enchantments={"sweetdream:<id>":1}, 但 data/sweetdream/enchantment/<id>.json
    #   不存在 -> 加载时报 "Failed to get element sweetdream:<id> missed input", 整个 give 作废。
    #   (另一个常见原因是"附魔是注册表内容, 改完没退世界重进" —— 那种情况文件是在的,
    #    这里查不出来, 属于运行期问题。)
    for me in re.finditer(r'enchantments=\{"([a-z_0-9]+):([a-z_0-9]+)"', g):
        ns, eid = me.group(1), me.group(2)
        ep = os.path.join(os.path.dirname(os.path.dirname(BASE)), 'enchantment', eid + '.json')
        if ns == 'sweetdream' and not os.path.exists(ep):
            err = err or ('引用了不存在的附魔 sweetdream:%s(缺 enchantment/%s.json)' % (eid, eid))
    if err or miss:
        print('[×] %-18s %s%s' % (cid, err or '', (' 缺: ' + ','.join(miss)) if miss else ''))
        bad += 1
    else:
        print('[ok] %-18s lore %d 段' % (cid, len(json.loads(m.group(1))) if lore_ok else 0))
print('---- 问题 %d 件' % bad)
sys.exit(1 if bad else 0)
