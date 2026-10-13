# -*- coding: utf-8 -*-
"""
法杖法球粒子 —— 守卫（配合 .workbuddy/_gen_staff_particles.py）

盯四条漂移:
  1. 每把法杖的 attack 里 style 必须 = 它自己的 zx[0]
  2. fx_<style> 与 fx_<style>_hit 两份文件必须都在
  3. ball/tick ④ 与 ball/hit ⑤ 的派发块必须覆盖全部 style(漏一把 = 那把没拖尾)
  4. ball 目录下不能有"没人派的"孤儿 fx 文件(改名/删法杖时容易落下)
外加: 所有 particle 名必须在 1.21.5 客户端里、所有 playsound 名必须在 sounds.json 里。

用法: python .workbuddy/_chk_staff_fx.py     (有问题就 exit 1)
"""
import os
import re
import sys
import zipfile

ROOT = r'D:\数据包'
DP = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function')
BALL = os.path.join(DP, 'projectile', 'ball')
STAFF = os.path.join(DP, 'equipment', 'staff')
JAR = r'D:\PCL 正式版 2.10.0\.minecraft\versions\1.21.5-Fabric 0.16.10\1.21.5-Fabric 0.16.10.jar'
SOUNDS = os.path.join(ROOT, '.workbuddy', '_sounds_ids.txt')

ERR = []
def err(m):
    ERR.append(m)

# ---- 素材真相(与生成器同一份来源, 保证两边口径一致)
z = zipfile.ZipFile(JAR)
PARTICLES = {n.split('/')[-1][:-5] for n in z.namelist()
             if n.startswith('assets/minecraft/particles/') and n.endswith('.json')}
NEED_OPTION = {'dust', 'block', 'item', 'block_marker', 'falling_dust', 'dust_pillar',
               'block_crumble', 'dust_color_transition', 'sculk_charge', 'entity_effect',
               'shriek', 'vibration'}
SOUND_IDS = set(open(SOUNDS, encoding='utf-8').read().split('\n')) if os.path.isfile(SOUNDS) else set()

# ---- ① 法杖清单(有 attack.mcfunction 的才算)
staffs = [d for d in sorted(os.listdir(STAFF))
          if os.path.isfile(os.path.join(STAFF, d, 'attack.mcfunction'))]

# ---- ② style == 自身 id
used = set()
for s in staffs:
    txt = open(os.path.join(STAFF, s, 'attack.mcfunction'), encoding='utf-8').read()
    m = re.search(r'data modify storage zx:work ball set value \{([^}]*)\}', txt)
    if not m:
        err('[%s] attack 里找不到 `ball set value {...}` 那一行' % s)
        continue
    ms = re.search(r'style:"([a-z_]*)"', m.group(1))
    if not ms:
        err('[%s] 装球那行没有 style 字段' % s)
        continue
    if ms.group(1) != s:
        err('[%s] style 写成 "%s" —— 必须是自己的 id' % (s, ms.group(1)))
    used.add(ms.group(1))

# ---- ③ fx 文件成对
for s in used:
    for fn in ('fx_%s.mcfunction' % s, 'fx_%s_hit.mcfunction' % s):
        if not os.path.isfile(os.path.join(BALL, fn)):
            err('缺文件 %s' % fn)

# ---- ④ 派发覆盖
tick = open(os.path.join(BALL, 'tick.mcfunction'), encoding='utf-8').read()
hit = open(os.path.join(BALL, 'hit.mcfunction'), encoding='utf-8').read()
for s in sorted(used):
    if 'data{style:"%s"}' % s not in tick:
        err('ball/tick ④ 里没有 style:"%s" 的派发 —— 这把法杖飞起来是隐形的' % s)
    if 'data{style:"%s"}' % s not in hit:
        err('ball/hit ⑤ 里没有 style:"%s" 的派发 —— 这把法杖命中走兜底白烟' % s)

# ---- ⑤ 孤儿 fx(没人派的)
for fn in sorted(os.listdir(BALL)):
    if not fn.startswith('fx_') or not fn.endswith('.mcfunction'):
        continue
    stem = fn[:-len('.mcfunction')]
    if stem in ('fx_plain', 'fx_plain_hit'):
        continue                       # 兜底两份是特例, 不算孤儿
    style = stem[3:-4] if stem.endswith('_hit') else stem[3:]
    if style not in used:
        err('孤儿文件 %s —— 没有任何法杖在用 style:"%s"(改名后忘了删?)' % (fn, style))

# ---- ⑥ 粒子名 / 音效名
for fn in sorted(os.listdir(BALL)):
    if not fn.endswith('.mcfunction'):
        continue
    p = os.path.join(BALL, fn)
    for i, line in enumerate(open(p, encoding='utf-8'), 1):
        if line.lstrip().startswith('#'):
            continue
        for m in re.finditer(r'\bparticle\s+minecraft:([a-z_0-9]+)(\{)?', line):
            pid, has = m.group(1), bool(m.group(2))
            if pid in NEED_OPTION and not has:
                err('[%s L%d] %s 必须带 {...} 选项' % (fn, i, pid))
            elif pid not in PARTICLES:
                err('[%s L%d] 1.21.5 里没有粒子 minecraft:%s' % (fn, i, pid))
        for m in re.finditer(r'\bplaysound\s+minecraft:([a-z_0-9.]+)', line):
            if SOUND_IDS and m.group(1) not in SOUND_IDS:
                err('[%s L%d] sounds.json 里没有音效 %s' % (fn, i, m.group(1)))

# ---- 报告
print('法杖 %d 把 / style %d 个 / fx 文件 %d 份'
      % (len(staffs), len(used), len([f for f in os.listdir(BALL) if f.startswith('fx_')])))
if ERR:
    for e in ERR:
        print('  ✗ ' + e)
    print('\n合计 %d 个问题' % len(ERR))
    sys.exit(1)
print('法杖粒子守卫: ✓')
