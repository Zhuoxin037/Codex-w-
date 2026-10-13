# -*- coding: utf-8 -*-
"""_probe_p3.py —— 反向探针: 逐条破坏 N07/N09/N10/N11 的守门形态, 证明 check.py 会报警。

约定(项目惯例): 每条破坏 -> 跑 check.py -> 断言目标桶非 0 -> 还原 -> 最后确认 0。
"新锁必须反向证明会报警" —— 只看"合计 0"不算数。
★ 改文件一律"按行读、按行改、按行写"(坑 99: 跨行 replace 会错位)。
"""
import io
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PY = sys.executable
CHK = os.path.join(ROOT, '.workbuddy', 'check.py')

_SD = 'sweetdream/data/sweetdream/function'
_MC = 'manacore-1.0.0/data/manacore/function'

REL = {
    'render': _SD + '/equipment/tool/look/render_go.mcfunction',
    'cache': _SD + '/equipment/tool/look/cache.mcfunction',
    'cache_go': _SD + '/equipment/tool/look/cache_go.mcfunction',
    'toggle': _SD + '/equipment/tool/look/toggle.mcfunction',
    'hook': _SD + '/equipment/staff/begonia/hook_calc.mcfunction',
    'empfind': _SD + '/equipment/staff/begonia/emp_find.mcfunction',
    'calc': _MC + '/internal/damage/calc.mcfunction',
    'mulpct': _MC + '/internal/damage/mul_pct.mcfunction',
    'tick': _MC + '/internal/session/tick_self.mcfunction',
    'noop': 'manacore-1.0.0/data/manacore/function/event/noop.mcfunction',
}

ORIG_EMP_LINE = ('$execute if entity @e[tag=zx.bg_vtx,tag=zx.bg_emp,nbt={data:{zx:{bg:{'
                 'ol:1b,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},distance=..6,limit=1] '
                 'run function sweetdream:equipment/staff/begonia/emp_put')


def rd(key):
    with open(os.path.join(ROOT, REL[key]), encoding='utf-8') as f:
        return f.read().split('\n')


def wr(key, lines):
    with open(os.path.join(ROOT, REL[key]), 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(lines))


def run_check():
    p = subprocess.run([PY, CHK], capture_output=True, text=True,
                       encoding='utf-8', errors='replace', cwd=ROOT)
    out = p.stdout
    res = {}
    for m in re.finditer(r'\[(.+?)\] (\d+) 条', out):
        res[m.group(1)[:30]] = int(m.group(2))
    tot = re.search(r'合计问题: (\d+)', out)
    res['__total__'] = int(tot.group(1)) if tot else -1
    res['__rc__'] = p.returncode
    return res, out


def _sub(key, old, new, count=1):
    """按行把**第一处**含 old 的行整行替换掉(不做跨行替换)。"""
    ls = rd(key)
    n = 0
    for i, l in enumerate(ls):
        if old in l and n < count:
            ls[i] = l.replace(old, new)
            n += 1
    if n == 0:
        raise RuntimeError('找不到含 %r 的行' % old)
    wr(key, ls)


def _drop_line(key, needle):
    ls = rd(key)
    for i, l in enumerate(ls):
        if needle in l:
            del ls[i]
            wr(key, ls)
            return
    raise RuntimeError('找不到含 %r 的行' % needle)


# ---------------- N07 ----------------
def m_render_eq():
    _sub('render', 'cache."$(uuid)".eq', 'cache.eq')


def m_render_skill():
    _sub('render', 'cache."$(uuid)".skill', 'cache.skill')


def m_cache_no_call():
    _drop_line('cache', 'look/cache_go with storage zx:work a')


def m_cachego_global():
    _sub('cache_go', 'cache."$(uuid)".eq', 'cache.eq')


def m_toggle_no_refresh():
    _drop_line('toggle', 'run function sweetdream:equipment/tool/look/cache')


# ---------------- N09 ----------------
def m_hook_macro_back():
    _sub('hook', 'execute at @s run function sweetdream:equipment/staff/begonia/emp_find',
         ORIG_EMP_LINE)


def m_hook_no_at():
    _sub('hook', 'execute at @s run function sweetdream:equipment/staff/begonia/emp_find',
         'execute run function sweetdream:equipment/staff/begonia/emp_find')


def m_empfind_empty():
    _drop_line('empfind', 'run function sweetdream:equipment/staff/begonia/emp_put')


def m_tagmacro_proof():
    ls = rd('noop')
    ls.append('$data modify storage manacore:work probe set value "$(probe)"')
    wr('noop', ls)


# ---------------- N10 ----------------
def m_calc_raw_mul():
    ls = rd('calc')
    out, i = [], 0
    while i < len(ls):
        if ls[i].strip() == 'function manacore:internal/damage/mul_pct {src:"#base_m",mul:"#mul_m"}':
            out.append('scoreboard players operation #dmg manacore.math = #base_m manacore.math')
            out.append('scoreboard players operation #dmg manacore.math *= #mul_m manacore.math')
            out.append('scoreboard players operation #dmg manacore.math /= #100 manacore.meta')
            i += 2      # 跳掉 mul_pct 调用 + 紧随的 += #mul_out
            continue
        out.append(ls[i])
        i += 1
    if len(out) == len(ls):
        raise RuntimeError('没找到 base_m 的 mul_pct 调用')
    wr('calc', out)


def m_mulpct_no_sub():
    _sub('mulpct', '#lo manacore.math -= #r manacore.math',
         '#lo manacore.math = #r manacore.math')


def m_mulpct_no_add():
    _drop_line('mulpct', '#mul_out manacore.math += #lo manacore.math')


# ---------------- N11 ----------------
def m_tick_double_join():
    ls = rd('tick')
    out, done = [], False
    for l in ls:
        if l.strip() == 'scoreboard players set #need manacore.meta 0' and not done:
            out.append('execute unless score @s manacore.gen >= #gen manacore.meta '
                       'run function manacore:core/player/join')
            out.append('execute unless data storage manacore:work id{ok:1b} '
                       'run function manacore:core/player/join')
            done = True
            continue
        if done and ('#need manacore.meta' in l):
            continue
        out.append(l)
    if not done:
        raise RuntimeError('没找到 #need 初始化行')
    wr('tick', out)


CASES = [
    ('01 render 读回全局 eq', m_render_eq, 'regress'),
    ('02 render 读回全局 skill', m_render_skill, 'regress'),
    ('03 cache 不再转交 cache_go', m_cache_no_call, 'regress'),
    ('04 cache_go 写回全局格', m_cachego_global, 'regress'),
    ('05 toggle 不立即刷缓存', m_toggle_no_refresh, 'regress'),
    ('06 hook_calc 写回宏行', m_hook_macro_back, 'tagmacro'),
    ('07 hook_calc 去掉 at @s', m_hook_no_at, 'regress'),
    ('08 emp_find 宏行被删', m_empfind_empty, 'regress'),
    ('09 标签函数里塞宏行', m_tagmacro_proof, 'tagmacro'),
    ('10 calc 退回裸乘', m_calc_raw_mul, 'regress'),
    ('11 mul_pct 余数不用减法', m_mulpct_no_sub, 'regress'),
    ('12 mul_pct 丢掉后半项', m_mulpct_no_add, 'regress'),
    ('13 tick_self 退回双 join', m_tick_double_join, 'regress'),
]

KEY = {
    'regress': '已修缺陷的',
    'tagmacro': '被函数标签(tags/function',
}


def main():
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8',
                                  errors='replace')
    snaps = {k: rd(k) for k in REL}
    base, _ = run_check()
    print('基线: 合计 %d' % base['__total__'])
    if base['__total__'] != 0:
        print('★ 基线不是 0, 先修好再跑探针')
        return
    ok = True
    for desc, fn, bucket in CASES:
        for k in REL:
            wr(k, snaps[k])
        fn()
        res, out = run_check()
        key = KEY[bucket]
        cnt = None
        for l in out.split('\n'):
            if l.startswith('[') and key in l:
                cnt = int(re.search(r'\] (\d+) 条', l).group(1))
                break
        hit = cnt or 0
        if hit <= 0:
            ok = False
        print('%-30s bucket=%-8s 命中=%2s  total=%-2s  %s'
              % (desc, bucket, hit, res['__total__'],
                 'OK' if hit > 0 else '!! 没报警'))
    for k in REL:
        wr(k, snaps[k])
    final, _ = run_check()
    print('还原后: 合计 %d' % final['__total__'])
    print('\n结论: %s' % ('全部探针命中且已还原(0)' if ok and final['__total__'] == 0
                          else '★ 有问题, 人工复核'))


if __name__ == '__main__':
    main()
