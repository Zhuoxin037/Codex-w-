# -*- coding: utf-8 -*-
"""反向探针：把新加的规则逐条改坏，确认 check.py 真能报出来，然后还原。

规则不会"因为写错正则而永远绿"——这就是本项目的老规矩：新规则必须做反向探针。
用法： python .workbuddy/_probe_newrules.py
"""
import io
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(r'D:\数据包')
PY = r'C:\Users\qq303\.workbuddy\binaries\python\envs\default\Scripts\python.exe'
CHK = ROOT / '.workbuddy' / 'check.py'
FN = ROOT / 'sweetdream' / 'data' / 'sweetdream' / 'function'
RP = ROOT / 'sweetdream_rp'

# (名字, 规则标题关键字, 文件, 原文, 改成)
PROBES = [
    ('ctrlmul: freeze 不再走真源', '控制时长倍率没走单一真源',
     FN / 'lib/freeze.mcfunction',
     'function sweetdream:lib/ctrl_mul/pct with storage zx:work cm', ''),
    ('ctrlmul: timestop 又写死 #20', '控制时长倍率没走单一真源',
     FN / 'lib/timestop.mcfunction',
     'execute unless score #ts_x zx.meta matches 0 run scoreboard players operation #ts_end zx.meta += #ts_x zx.meta',
     'scoreboard players operation #ts_x zx.meta *= #20 zx.meta\nexecute unless score #ts_x zx.meta matches 0 run scoreboard players operation #ts_end zx.meta += #ts_x zx.meta'),
    ('ctrlmul: stats 面板没读', '控制时长倍率没走单一真源',
     FN / 'debug/stats.mcfunction',
     'function sweetdream:lib/ctrl_mul/pct with storage zx:work cm', ''),
    ('dimflag: 少一个淡出位', '图标"剩余≤3秒变淡"',
     FN / 'tag/icon_refresh.mcfunction',
     'execute if entity @s[tag=zx.status.liuhuo] if score @s zx.tt.liuhuo matches ..3 run scoreboard players add #tag_mask zx.meta 64',
     ''),
    ('dimflag: 两处阈值不一致', '图标"剩余≤3秒变淡"',
     FN / 'tag/icon_render.mcfunction',
     'execute if entity @s[tag=zx.status.dream] if score @s zx.tt.dream matches ..3 run data modify',
     'execute if entity @s[tag=zx.status.dream] if score @s zx.tt.dream matches ..4 run data modify'),
    ('dimflag: lang 缺淡色键', '图标"剩余≤3秒变淡"',
     RP / 'assets/sweetdream/lang/zh_cn.json',
     '  "sweetdream.icon.dim.yehuo": "\ue007",\n', ''),
    ('enemysrc: api/damage 缺兜底', '敌方技能来源标记',
     FN / 'api/damage.mcfunction',
     'execute unless data storage zx:work a{src:"enemy"} run data modify storage zx:work a.src set value "ally"', ''),
    ('enemysrc: 夜火两条分支不互斥', '敌方技能来源标记',
     FN / 'internal/damage/one.mcfunction',
     'unless data storage zx:work a{src:"enemy"}', ''),
]


def run_check():
    out = subprocess.run([PY, str(CHK)], capture_output=True, text=True, encoding='utf-8',
                         errors='replace').stdout
    return out


def rule_count(out, key):
    m = re.search(re.escape(key) + r'[^\]]*\]\s*(\d+)\s*条', out)
    return int(m.group(1)) if m else -1


def main():
    ok = True
    for name, title, path, old, new in PROBES:
        src = io.open(path, encoding='utf-8', newline='').read()
        if old not in src:
            print('[?] %-34s 探针锚点没找到, 跳过 (%s)' % (name, path.name)); ok = False; continue
        bak = io.open(path, encoding='utf-8', newline='').read()
        io.open(path, 'w', encoding='utf-8', newline='').write(src.replace(old, new, 1))
        try:
            n = rule_count(run_check(), title)
        finally:
            io.open(path, 'w', encoding='utf-8', newline='').write(bak)
        good = n >= 1
        ok = ok and good
        print('[%s] %-34s -> 该规则 %d 条 %s' % ('ok' if good else '××', name, n,
                                                 '' if good else '(没报出来!)'))
    # 还原后再全量跑一次, 必须 0
    out = run_check()
    m = re.search(r'合计问题:\s*(\d+)', out)
    total = int(m.group(1)) if m else -1
    print('\n还原后全量: 合计问题 %d %s' % (total, '' if total == 0 else '(应为 0!)'))
    sys.exit(0 if ok and total == 0 else 1)


if __name__ == '__main__':
    main()
