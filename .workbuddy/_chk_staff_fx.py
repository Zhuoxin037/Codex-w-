# -*- coding: utf-8 -*-
"""
法杖法球粒子 —— 守卫（配合 .workbuddy/_gen_staff_particles.py）

盯四条漂移:
  1. 每把法杖的 attack 里 style 必须 = 它自己的 zx[0]
     (★ 多形态法杖另有"附加 style", 由 attack 运行时改写球的 style 选形态 ——
       它们必须写成 `<id>_<后缀>`(先例 triad_fire / triad_gun), 见 attack 里的
       `ball.style set value "..."` 行)
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
        # ★ 2026-10-20 批二: 有的法杖在设计稿里**根本没有 ✦ 普攻 段**(纯技能法杖),
        #   它们的 attack.mcfunction 只写 `return 0` 接住普通右键 —— 这是正确实现,
        #   不是漏写。判据 = 去掉注释后全文只剩一条 return(不生成球 = 不起拖尾)。
        body = [l.strip() for l in txt.split('\n')
                if l.strip() and not l.strip().startswith('#')]
        if body and all(l.startswith('return') for l in body):
            continue
        err('[%s] attack 里找不到 `ball set value {...}` 那一行' % s)
        continue
    ms = re.search(r'style:"([a-z_]*)"', m.group(1))
    if not ms:
        err('[%s] 装球那行没有 style 字段' % s)
        continue
    if ms.group(1) != s:
        err('[%s] style 写成 "%s" —— 必须是自己的 id' % (s, ms.group(1)))
    used.add(ms.group(1))
    # ★ 多形态法杖: attack 会按形态**运行时**改写球的 style(先例 triad 的 triad_fire /
    #   triad_gun)。这些附加 style 必须**以本把法杖的 id 开头**, 否则就是归属写错了。
    for me in re.finditer(r'ball\.style set value "([a-z_0-9]*)"', txt):
        extra = me.group(1)
        if not extra.startswith(s + '_'):
            err('[%s] ball.style set value "%s" —— 附加 style 必须以 "%s_" 开头'
                % (s, extra, s))
        used.add(extra)

# ---- ③ fx 文件成对
for s in used:
    for fn in ('fx_%s.mcfunction' % s, 'fx_%s_hit.mcfunction' % s):
        if not os.path.isfile(os.path.join(BALL, fn)):
            err('缺文件 %s' % fn)

# ---- ④ 派发覆盖
# ★ 2026-10-20: 法球 tick 已拆成 tick(wrapper) + tick_target(真实现)。
#   ④ 拖尾派发块在 tick_target 里 —— 继续读 tick 会对每把法杖都误报"隐形"。
tick = open(os.path.join(BALL, 'tick_target.mcfunction'), encoding='utf-8').read()
hit = open(os.path.join(BALL, 'hit.mcfunction'), encoding='utf-8').read()

# ★★ 2026-10-20 第二次改派发形态: 从"每个 style 一行 `if data …{style:"x"}`"
#    改成**单条宏分派**。原因见 _gen_staff_particles.dispatch_trail 的注释
#    (每刻 24 次实体 NBT 序列化)。所以这里也要认两种形态:
#      · 宏形态  —— 只要那一行在, 所有 style 都被覆盖(函数名由 $(style) 拼);
#      · 字面量形态(旧版/回退) —— 仍然逐个 style 找。
#    ★ 宏形态下"fx_<style> 文件是否存在"由 ③ 保证, 不会漏。
MACRO_TRAIL = re.search(r'\$function\s+sweetdream:projectile/ball/fx_\$\(style\)\s*$',
                        tick, re.M) is not None
MACRO_HIT = re.search(r'\$function\s+sweetdream:projectile/ball/fx_\$\(style\)_hit\s*$',
                      hit, re.M) is not None
if not MACRO_TRAIL and not MACRO_HIT:
    pass
for s in sorted(used):
    if not MACRO_TRAIL and 'data{style:"%s"}' % s not in tick:
        err('ball/tick ④ 里没有 style:"%s" 的派发 —— 这把法杖飞起来是隐形的' % s)
    if not MACRO_HIT and 'data{style:"%s"}' % s not in hit:
        err('ball/hit ⑤ 里没有 style:"%s" 的派发 —— 这把法杖命中走兜底白烟' % s)

# ---- ④.5 宏分派的**前提**必须成立: fire 要给 style 兜底
#   宏 `fx_$(style)` 取不到参数时那一行会直接失败(不报语法错, 只是没表现)。
fire = open(os.path.join(BALL, 'fire.mcfunction'), encoding='utf-8').read()
if MACRO_TRAIL or MACRO_HIT:
    if 'unless data storage zx:work ball.style' not in fire:
        err('fire 里没有 style 兜底 —— 宏分派取不到参数时该发法球会完全没有表现')

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
