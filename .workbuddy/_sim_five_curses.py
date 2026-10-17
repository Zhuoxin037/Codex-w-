# -*- coding: utf-8 -*-
"""
_ sim_five_curses.py —— 「五世恶咒 · 世咒推进」离线状态机模拟器

为什么写它: curse_step 的行为是"连续命中下的状态迁移", 静态扫命令只能看形态, 看不出
"第 6 刀到底走不走终世"。这个脚本**直接解释 curse_step.mcfunction 的命令行**(只支持它用到的
那几种语法; 遇到没覆盖的语法直接报错, 免得"假装通过"), 把连续命中的 st/tag/终世调用数打出来。

覆盖命令语法(不在这张表里的一律 raise, 保证不漏读):
  tag @s remove X
  execute if score @s O matches R run tag @s add X
  execute if score @s O matches R run scoreboard players set @s O V
  scoreboard players add @s O N / set @s O N
  scoreboard players set #P zx.meta V
  execute if entity @s[tag=X] run function …/final
  execute if score @s O matches R run function …/armor_cut
  execute if score @s O matches R run effect give @s …
  execute if score @s O matches R if entity @s[tag=X] run scoreboard players set @s O V
  execute if score @s O matches R run tag @s remove X
  execute unless entity @s[tag=X] at @s run particle …
  execute if data storage … run execute store result score … (uuid 抄写, 忽略)
  execute at @s run particle … (忽略)

★ "没分数 ≠ 0": 未 set 过的计分项按 None 处理, 所有 matches 判据对 None 恒假 —— 这正是
  游戏里的行为(RULES 坑 44), 模拟器必须照做, 否则会掩盖"首次命中前 st 不存在"这类问题。
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FN = ROOT / 'sweetdream/data/sweetdream/function/equipment/staff/five_curses/curse_step.mcfunction'


def in_range(val, spec):
    """Minecraft 的 `matches` 区间: N / N.. / ..N / N..M。val=None(没分数) 一律 False。"""
    if val is None:
        return False
    spec = spec.strip()
    if '..' in spec:
        lo, _, hi = spec.partition('..')
        if lo and val < int(lo):
            return False
        if hi and val > int(hi):
            return False
        return True
    return val == int(spec)


class Target:
    def __init__(self):
        self.s = {}          # objective -> int (absent = 缺失)
        self.tags = set()
        self.final_calls = 0
        self.final_pct_at_call = []   # 每次调 final 时 #fcv_pct 的值
        self.armor_cut_calls = 0
        self.effects = []

    def get(self, obj):
        return self.s.get(obj)

    def st(self):
        return self.get('zx.fcv_st')


def run_final(t, pct):
    """curse_step 走到的 final 分支: 结算 + clear(按 clear.mcfunction)。"""
    t.final_calls += 1
    t.final_pct_at_call.append(pct)
    # clear(): st/rec/t 归 0, 摘 fcv_3 / fcv_5 / fcv_4, t4 归 0
    t.s['zx.fcv_st'] = 0
    t.s['zx.fcv_rec'] = 0
    t.s['zx.fcv_t'] = 0
    t.s['zx.fcv_t4'] = 0
    t.tags -= {'zx.fcv_3', 'zx.fcv_5', 'zx.fcv_4'}


def run_armor_cut(t):
    t.armor_cut_calls += 1
    t.tags.add('zx.fcv_4')
    t.s['zx.fcv_t4'] = 5


RE_RM_TAG = re.compile(r'^tag @s remove (\S+)$')
RE_IF_TAG = re.compile(r'^execute if score @s (\S+) matches (\S+) run tag @s add (\S+)$')
RE_IF_SET = re.compile(r'^execute if score @s (\S+) matches (\S+) run scoreboard players set @s (\S+) (-?\d+)$')
RE_IF_SET2 = re.compile(r'^execute if score @s (\S+) matches (\S+) if entity @s\[tag=(\S+)\] '
                        r'run scoreboard players set @s (\S+) (-?\d+)$')
RE_ADD = re.compile(r'^scoreboard players add @s (\S+) (-?\d+)$')
RE_SET = re.compile(r'^scoreboard players set @s (\S+) (-?\d+)$')
RE_META = re.compile(r'^scoreboard players set #(\S+) zx\.meta (-?\d+)$')
RE_CALL_FINAL = re.compile(r'^execute if entity @s\[tag=(\S+)\] run function '
                           r'sweetdream:equipment/staff/five_curses/final$')
RE_CALL_CUT = re.compile(r'^execute if score @s (\S+) matches (\S+) run function '
                         r'sweetdream:equipment/staff/five_curses/armor_cut$')
RE_EFFECT = re.compile(r'^execute if score @s (\S+) matches (\S+) run effect give @s (\S+) (\d+) (\d+) (\w+)$')
IGNORE = [
    re.compile(r'^execute if data storage .* run execute store result score .*$'),   # uuid 抄写
    re.compile(r'^execute at @s run particle .*$'),
    re.compile(r'^execute unless entity @s\[tag=\S+\] at @s run particle .*$'),
]


def step(t, meta):
    """按 curse_step.mcfunction 执行一遍(对一个目标)。"""
    lines = FN.read_text(encoding='utf-8').split('\n')
    for raw in lines:
        l = raw.strip()
        if not l or l.startswith('#'):
            continue
        m = RE_RM_TAG.match(l)
        if m:
            t.tags.discard(m.group(1)); continue
        m = RE_IF_SET2.match(l)
        if m:
            o, rng, tg, o2, v = m.groups()
            if in_range(t.get(o), rng) and tg in t.tags:
                t.s[o2] = int(v)
            continue
        m = RE_IF_TAG.match(l)
        if m:
            o, rng, tg = m.groups()
            if in_range(t.get(o), rng):
                t.tags.add(tg)
            continue
        m = RE_IF_SET.match(l)
        if m:
            o, rng, o2, v = m.groups()
            if in_range(t.get(o), rng):
                t.s[o2] = int(v)
            continue
        m = RE_CALL_FINAL.match(l)
        if m:
            tg = m.group(1)
            if tg in t.tags:
                run_final(t, meta.get('#fcv_pct'))
            continue
        m = RE_CALL_CUT.match(l)
        if m:
            o, rng = m.groups()
            if in_range(t.get(o), rng):
                run_armor_cut(t)
            continue
        m = RE_EFFECT.match(l)
        if m:
            o, rng, eff, dur, amp, hide = m.groups()
            if in_range(t.get(o), rng):
                t.effects.append((eff, int(dur), int(amp)))
            continue
        m = RE_ADD.match(l)
        if m:
            o, n = m.groups()
            t.s[o] = (t.get(o) or 0) + int(n)
            continue
        m = RE_SET.match(l)
        if m:
            o, v = m.groups()
            t.s[o] = int(v); continue
        m = RE_META.match(l)
        if m:
            meta['#' + m.group(1)] = int(m.group(2)); continue
        if any(p.match(l) for p in IGNORE):
            continue
        raise AssertionError('模拟器没覆盖到这条命令, 请补语法再跑: %s' % l)


def hit(t, meta, label):
    step(t, meta)
    print('  %-6s st=%-4s fcv_t=%-5s fcv_rec=%-4s tags=%-42s 终世调用=%d%s'
          % (label, t.st(), t.get('zx.fcv_t'), t.get('zx.fcv_rec'),
             ','.join(sorted(x.replace('zx.fcv_', '') for x in t.tags if x.startswith('zx.fcv'))) or '-',
             t.final_calls,
             ('  <pct=%s>' % t.final_pct_at_call[-1]) if t.final_pct_at_call and label.endswith('终世!') else ''))


def main():
    print('curse_step 离线模拟: %s' % FN.relative_to(ROOT))
    t = Target()
    meta = {'#fcv_pct': 30}
    print('\n[场景 A] 连续普攻命中(每一刀都从"落咒"走到 curse_step)')
    for i in range(1, 8):
        before5 = (t.st() or 0) >= 5
        hit(t, meta, '第%d刀' % i if not before5 else '第%d刀终世!' % i)
    print('\n  断言:')
    ok = True
    ok &= (t.final_calls == 1)
    print('    · 7 刀总共只结算 1 次终世: %s (实得 %d)' % (t.final_calls == 1, t.final_calls))
    ok &= (t.final_pct_at_call == [30])
    print('    · 普攻触发的终世比例 = 30%%: %s (实得 %s)' % (t.final_pct_at_call == [30], t.final_pct_at_call))
    # 第 6 刀结算后应从第一世重新开始, 第 7 刀 = 第一世(虚弱Ⅲ)
    ok &= (t.effects[-1] == ('minecraft:weakness', 3, 2))
    print('    · 终世清干净后, 第 7 刀重新从第一世(虚弱Ⅲ)起: %s' % (t.effects[-1] == ('minecraft:weakness', 3, 2)))

    print('\n[场景 B] 第四世后直接调 skill 的 80% 结算(模拟 skill ⑦), 再普攻一刀')
    t2 = Target()
    meta2 = {'#fcv_pct': 30}
    for i in range(1, 6):
        step(t2, meta2)
    # ★ skill 的真实顺序是: scoreboard players set #fcv_pct zx.meta 80 → 紧接着对第五世者调 final
    meta2['#fcv_pct'] = 80
    run_final(t2, meta2['#fcv_pct'])          # skill ⑦ 对第五世的 final(80%)
    print('  skill 结算后: st=%s 终世调用=%d pct=%s' % (t2.st(), t2.final_calls, t2.final_pct_at_call))
    ok &= (t2.final_pct_at_call == [80])
    print('    · skill 触发的终世比例 = 80%%: %s' % (t2.final_pct_at_call == [80]))
    # ★ 关键: 紧随其后的一刀若命中, 必须按 30% 而不是残留的 80%
    step(t2, meta2)
    print('  随后普攻一刀: st=%s (应=1, 说明从第一世重来); #fcv_pct 已回落 30: %s'
          % (t2.st(), meta2.get('#fcv_pct') == 30))
    ok &= (t2.final_calls == 1 and t2.st() == 1 and meta2.get('#fcv_pct') == 30)
    print('    · (skill 的 80% 是它自己调 final 时用的; curse_step 里重置 30 只影响"普攻收尾"那一刀)')

    print('\n[场景 C] 未 set 过 zx.fcv_st 的新目标, 第一刀')
    t3 = Target()
    meta3 = {'#fcv_pct': 30}
    step(t3, meta3)
    ok &= (t3.st() == 1 and t3.final_calls == 0)
    print('  st=%s (应=1) / 终世调用=%d (应=0) —— 确认"没分数≠0"不会误触发终世' % (t3.st(), t3.final_calls))

    print('\n' + ('==== 全部断言通过 ====' if ok else '!!!! 有断言失败 !!!!'))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
