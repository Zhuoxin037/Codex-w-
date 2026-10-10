# -*- coding: utf-8 -*-
"""check 规则 dmgord / panelrow 的反向探针。

做法: 每次只改坏一处 -> 跑 check.py -> 抓那一条规则的"问题条数" -> 还原。
要求: 改坏时 >=1 条, 还原后 == 0 条。否则规则是"假绿"。

★ 教训(2026-10-06): 第一版探针忘了在每条后还原, 于是 B 的报数里混进了 A 的错,
  数字对不上还以为规则坏了 —— 所以这里每条都走 restore()。
"""
import io, re, shutil, subprocess, sys, os

ROOT = r'D:\数据包'
PY = r'C:\Users\qq303\.workbuddy\binaries\python\versions\3.13.12\python.exe'
CHECK = os.path.join(ROOT, '.workbuddy', 'check.py')
DC = os.path.join(ROOT, 'sweetdream', 'data', 'manacore', 'tags', 'function', 'event',
                  'damage_calc.json')
RES = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function', 'equipment',
                   'armor', 'resonance', 'scan_mul.mcfunction')
SER = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function', 'equipment',
                   'tool', 'seraph_wing', 'hook_calc.mcfunction')

FILES = (DC, RES, SER)
BAK = {p: io.open(p, encoding='utf-8').read() for p in FILES}


def restore():
    for p, t in BAK.items():
        io.open(p, 'w', encoding='utf-8', newline='\n').write(t)


def count(title_key):
    out = subprocess.run([PY, CHECK], cwd=ROOT, capture_output=True, text=True,
                         encoding='utf-8', errors='ignore').stdout
    m = re.search(r'\[%s[^\]]*\]\s*(\d+)\s*条' % re.escape(title_key), out)
    return int(m.group(1)) if m else -1


def probe(name, mut, title_key):
    restore()
    mut()
    n = count(title_key)
    restore()
    n0 = count(title_key)
    ok = (n >= 1 and n0 == 0)
    print('%-46s 改坏=%d 还原=%d  %s' % (name, n, n0, 'OK' if ok else '** 失败 **'))
    return ok


def edit(path, old, new):
    t = io.open(path, encoding='utf-8').read()
    assert old in t, '找不到要替换的内容: %s' % old[:40]
    io.open(path, 'w', encoding='utf-8', newline='\n').write(t.replace(old, new, 1))


# ---- dmgord 探针 ----
def a():
    """把 lib/dmg_add_apply 挪到最前面(加算 hook 就排到它后面了)"""
    t = io.open(DC, encoding='utf-8').read()
    t = t.replace('    "sweetdream:lib/dmg_add_apply",\n', '')
    t = t.replace('    "sweetdream:lib/dmg_ch",\n',
                  '    "sweetdream:lib/dmg_ch",\n    "sweetdream:lib/dmg_add_apply",\n')
    io.open(DC, 'w', encoding='utf-8', newline='\n').write(t)


def b():
    """删掉清池那一条"""
    edit(DC, '    "sweetdream:lib/dmg_add_clear",\n', '')


def c():
    """把炽天使(加算)谎报成独立乘区 -> 排在 apply 前面就违规"""
    edit(SER, '# @calc: add', '# @calc: indep')


def d():
    """把一个 hook 从事件里摘掉(完整性)"""
    edit(DC, '    "sweetdream:equipment/armor/styx_walk/hook_calc",\n', '')


# ---- panelrow 探针(加算型走 put.ch 那条路) ----
def e():
    """声明 smul_mm,smul_atk,smul_oth 但只往 atk 扔 -> 集合不一致"""
    edit(RES, 'data modify storage zx:work put.ch set value "mm"',
         'data modify storage zx:work put.ch set value "atk"')
    edit(RES, 'data modify storage zx:work put.ch set value "oth"',
         'data modify storage zx:work put.ch set value "atk"')


print('== dmgord ==')
r = [probe('A apply 挪到最前(加算排在它后面)', a, 'damage_calc 事件的顺序'),
     probe('B 删掉 dmg_add_clear(不清池)', b, 'damage_calc 事件的顺序'),
     probe('C 加算 hook 谎报成 indep', c, 'damage_calc 事件的顺序'),
     probe('D 把 hook 从事件里摘掉', d, 'damage_calc 事件的顺序')]
print('== panelrow ==')
r.append(probe('E 只往 atk 扔却声明三条通道', e, 'scan_mul 头部'))
restore()
print('---- 全部通过' if all(r) else '---- 有失败项')
sys.exit(0 if all(r) else 1)
