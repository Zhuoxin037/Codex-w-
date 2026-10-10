# -*- coding: utf-8 -*-
"""
_chk_lore.py —— 离线校验 overlimit/def/load 里的 lore 字段
--------------------------------------------------------------------------
为什么需要它: 那三条定义是**一行 NBT**(data modify ... set value {...})。
  · 里面少一个逗号 / 多一个引号 -> 整条命令解析失败 -> 定义表少一条,
    物品敲上超限之后描述变成空(而且不会报得很明显)。
  · 玩家看到的是 "整串 JSON 源码" 还是正常 tooltip, 取决于
    "文本组件当 set value 实参时不带引号" 这条规矩有没有守住。
所以这里把它当成 NBT 解析一遍, 再逐条检查文本条目。
用法: python .workbuddy/_chk_lore.py
"""
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FN = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function',
                  'overlimit', 'def', 'load.mcfunction')

# SNBT -> JSON: 给裸 key 加引号(只对 "{" / "," 后面紧跟的标识符动手)
KEY_RE = re.compile(r'([{,]\s*)([A-Za-z_][A-Za-z0-9_]*)\s*:')


def snbt_to_json(s):
    s = KEY_RE.sub(r'\1"\2":', s)
    return json.loads(s)


def main():
    with io.open(FN, encoding='utf-8') as f:
        lines = f.read().split('\n')

    bad = 0
    n_def = 0
    for ln, line in enumerate(lines, 1):
        m = re.search(r'set value (\{.*\})\s*$', line)
        if not m:
            continue
        n_def += 1
        wid = re.search(r'oldef\."([^"]+)"', line)
        wid = wid.group(1) if wid else '?'
        raw = m.group(1)
        try:
            obj = snbt_to_json(raw)
        except Exception as e:
            print('[解析失败] 第%d行 %s: %s' % (ln, wid, e))
            bad += 1
            continue

        lore = obj.get('lore')
        if not lore:
            print('[缺 lore] %s —— 敲上超限后这个物品会变成"没有描述"' % wid)
            bad += 1
            continue

        for i, comp in enumerate(lore):
            if not isinstance(comp, dict):
                print('[条目不是组件] %s lore[%d]' % (wid, i))
                bad += 1
                continue
            if 'text' not in comp:
                print('[条目没有 text] %s lore[%d]: %r' % (wid, i, comp))
                bad += 1
                continue
            if not isinstance(comp['text'], str):
                print('[text 不是字符串] %s lore[%d]' % (wid, i))
                bad += 1
            # 全角引号/反斜杠: 宏渲染那条线上会炸(这里顺手看一眼)
            for key in ('text',):
                if '\\' in comp[key]:
                    print('[反斜杠] %s lore[%d]' % (wid, i))
                    bad += 1
            # 行宽(中文按 2 格、其它按 1 格算, 参考 give 里的硬切宽度)
            t = comp['text']
            w = sum(2 if ord(c) > 0x2000 else 1 for c in t)
            if w > 41:
                print('[行偏宽 %d] %s lore[%d]: %s' % (w, wid, i, t))

        # 乘区与 lore 数值的一致性: 只做提示, 不判错
        print('  · %-40s lore %2d 条  dmg=%s mana=%s cd=%s'
              % (wid, len(lore), obj.get('dmg'), obj.get('mana'), obj.get('cd')))

    print('--------------------------------------------------')
    print('定义 %d 条, 问题 %d 条' % (n_def, bad))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
