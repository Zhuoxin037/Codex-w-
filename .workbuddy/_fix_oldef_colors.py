# -*- coding: utf-8 -*-
"""
_fix_oldef_colors.py —— 把「超限名」的颜色改成**该装备本名的颜色**
--------------------------------------------------------------------------
【为什么】2026-10-10 用户要求: 超限后保留原来的装备颜色, 不要统一成一个色。
  原实现(overlimit/def/load)里 19 条 oldef 的 name 一律写
  {"text":"超限·X","bold":true,"color":"light_purple"} —— 一屋子装备敲完超限
  全长一个紫色, 拿在手里看不出是哪把。
  现在: 超限名 = 本名 + "超限·" 前缀, **颜色照抄该装备 give 的 item_name.color**。

【颜色从哪来】equipment/**/<id>/give.mcfunction 里那一行 item_name={text:"..",bold:true,color:..}
  ★ 不手抄: 本脚本自己去 give 里读, 这样两边永远一致(check.py 规则 26 也会反查)。

【改的是哪几种行】只改 `data modify storage zx:config oldef."<id>" set value ...`
  那一行里的 **name 组件**, 不碰 label / note / lore。
  qiansan 也照办(它是万念超限后的换手形态, 本名颜色 = 千散 give 的 dark_red)。

【幂等】本脚本就是这套改动的真源: 反复跑第二遍 0 变化。
用法: python .workbuddy/_fix_oldef_colors.py [--check]
"""
import io
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DP = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function')
P = os.path.join(DP, 'overlimit', 'def', 'load.mcfunction')
EQ = os.path.join(DP, 'equipment')

# 兜底表: 万一某件没有 give 文件, 用这里的值(空 = 直接报错, 逼人去看)
FALLBACK = {}

# ★ 注意 `"color":` —— 冒号在**引号之后**。写成 `"color:"`(冒号进引号里) 会静默不匹配,
#   脚本跑完报"0 处改动", 看着像"已经是对的了"。踩过一次, 所以这里用 chr(34) 拼,
#   免得再被引号糊弄。
_Q = chr(34)
NAME_RE = re.compile(r'(name:\{' + _Q + 'text' + _Q + ':' + _Q + '[^' + _Q + ']*' + _Q
                     + ',' + _Q + 'bold' + _Q + ':true,' + _Q + 'color' + _Q + ':'
                     + ')(' + _Q + '?)([a-z_]+)(' + _Q + '?)')


def give_color(uid):
    """从 equipment/**/<uid>/give.mcfunction 里读 item_name 的颜色"""
    for r, ds, fs in os.walk(EQ):
        if os.path.basename(r) == uid and 'give.mcfunction' in fs:
            txt = io.open(os.path.join(r, 'give.mcfunction'), encoding='utf-8').read()
            m = re.search(r'item_name=\{text:"[^"]*",bold:true,color:"?([a-z_]+)"?\}', txt)
            if m:
                return m.group(1), os.path.relpath(os.path.join(r, 'give.mcfunction'), EQ)
    return None, None


def main():
    check = '--check' in sys.argv
    lines = io.open(P, encoding='utf-8').read().split('\n')
    out = []
    changed = 0
    seen = []
    for ln in lines:
        if ln.lstrip().startswith('#') or 'oldef.' not in ln or ' set value ' not in ln:
            out.append(ln)
            continue
        mid = re.search(r'oldef\."([^"]+)"', ln)
        if not mid:
            out.append(ln)
            continue
        uid = mid.group(1)
        col, src = give_color(uid)
        if not col:
            col, src = FALLBACK.get(uid), '(fallback)'
        if not col:
            print('!! oldef."%s" 找不到 give 文件, 也无可用的兜底颜色' % uid)
            out.append(ln)
            continue
        new = NAME_RE.sub(lambda m: m.group(1) + '"%s"' % col, ln, count=1)
        seen.append((uid, col, src, 'changed' if new != ln else 'same'))
        if new != ln:
            changed += 1
            if not check:
                print('[changed] oldef."%-18s"  color -> %-13s   (来自 %s)' % (uid, col, src))
        out.append(new)
    if check:
        for uid, col, src, st in seen:
            print('[%s] oldef."%s" -> %s' % (st, uid, col))
    if not check and changed:
        io.open(P, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
    print('---- 共 %d 条, 本次改动 %d 条%s' % (len(seen), changed, '(check 模式, 未写回)' if check else ''))
    return 0


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.exit(main())
