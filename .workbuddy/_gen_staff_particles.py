# -*- coding: utf-8 -*-
"""
sweetdream 法杖法球粒子 —— 生成器（2026-10-11）
================================================================
【为什么要有它】
    法杖的普攻都走同一颗法球(projectile/ball), 外观只靠一个 style 字符串区分。
    原来只有 "wind" 一种写了拖尾/命中, 其余 11 把**连拖尾都没有**、命中也全
    走同一份 fx_plain_hit —— 12 把法杖打出来一模一样。
    本脚本按"每把法杖的 lore 主题"批量产出各自的拖尾 + 命中, 并改写派发。

    ★ 注意: 和 .workbuddy/_gen_staff_fx.py **不是同一个东西** ——
      那个是 2026-10-08 给调色盘/海棠做 item_display 贴图的。

【产出】
    function/projectile/ball/fx_<style>.mcfunction          每把一把(飞行拖尾)
    function/projectile/ball/fx_<style>_hit.mcfunction      每把一把(命中表现)
    并就地改写:
      · ball/tick  第 ④ 步 —— 12 行 if data {style:"..."} 派发
      · ball/hit   第 ⑤ 步 —— 同上(原来只有 wind / 其余兜底 plain)
      · ball/pop   撞墙也按各自的风格散掉(改成宏函数, 复用拖尾)
      · equipment/staff/<id>/attack.mcfunction —— style 改成各自的 id

【安全网(每次都跑)】
    1. 粒子名必须在**客户端 jar 的 assets/minecraft/particles/*.json** 里
       (jar 是唯一真相; check.py 的 KNOWN_PARTICLES 有假阳性 —— item_slime
        在它白名单里但 jar 里没有, 所以不能用)
    2. 音效名必须在 1.21.5 的 sounds.json 里(.workbuddy/_sounds_ids.txt)
    3. dust / block / item 这类"必须带选项"的粒子必须写成 {...}
    4. 幂等: 重复跑不会重复插入派发行

用法:
    python _gen_staff_particles.py            # 只打印将要做什么(试运行)
    python _gen_staff_particles.py --write    # 真的写
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

WRITE = '--write' in sys.argv

# ------------------------------------------------------------------ 素材真相
def jar_particles():
    z = zipfile.ZipFile(JAR)
    return {n.split('/')[-1][:-5] for n in z.namelist()
            if n.startswith('assets/minecraft/particles/') and n.endswith('.json')}

PARTICLES = jar_particles()
NEED_OPTION = {'dust', 'block', 'item', 'block_marker', 'falling_dust',
               'dust_pillar', 'block_crumble', 'dust_color_transition',
               'sculk_charge', 'entity_effect', 'shriek', 'vibration'}
SOUND_IDS = set()
if os.path.isfile(SOUNDS):
    SOUND_IDS = set(open(SOUNDS, encoding='utf-8').read().split('\n'))

ERR = []
def err(msg):
    ERR.append(msg)

def dust(r, g, b, s):
    return 'dust{color:[%s,%s,%s],scale:%s}' % (r, g, b, s)

def P(name, dx, dy, dz, speed, count):
    """一条 particle 命令。name 传 'end_rod' 或 'dust{...}' 这种(不带 minecraft:)。"""
    base = name.split('{')[0]
    if base in NEED_OPTION and '{' not in name:
        err('粒子 %s 必须带 {...} 选项' % name)
    if base not in PARTICLES:
        err('粒子 minecraft:%s 不在 1.21.5 客户端里' % base)
    return 'particle minecraft:%s ~ ~ ~ %s %s %s %s %d normal' % (name, dx, dy, dz, speed, count)

def SND(name, vol, pitch):
    if SOUND_IDS and name not in SOUND_IDS:
        err('音效 %s 不在 1.21.5 sounds.json 里' % name)
    return 'playsound minecraft:%s player @a ~ ~ ~ %s %s' % (name, vol, pitch)

# ------------------------------------------------------------------ 规格表
#   style = 法杖的 zx[0](与 attack 里写的 style 同名)
#   cn    = 中文名   theme = 一句话主题(写进文件头, 以后改风格时知道当初为什么这么画)
SPECS = [
    # ── 启示录: 灾示降临。金色符文 + 蜡屑(书页感), 不抢"终末天启"的白光
    dict(style='apocalypse', cn='启示录', theme='灾示 · 金符文与书页蜡屑',
         trail=[P(dust(1.0, 0.82, 0.35, 1.2), 0.12, 0.12, 0.12, 0, 8),
                P('enchant', 0.25, 0.25, 0.25, 0.02, 2),
                P('wax_on', 0.18, 0.18, 0.18, 0.01, 3)],
         hit=[P(dust(1.0, 0.78, 0.3, 1.6), 0.55, 0.5, 0.55, 0.05, 26),
              P('enchant', 0.6, 0.6, 0.6, 0.2, 16),
              P('wax_off', 0.5, 0.5, 0.5, 0.02, 14),
              SND('entity.evoker.cast_spell', 0.75, 1.25)]),

    # ── 海棠: 渊海漩涡。水
    dict(style='begonia', cn='海棠', theme='渊海 · 水与漩涡',
         trail=[P('bubble', 0.12, 0.12, 0.12, 0.01, 6),
                P('nautilus', 0.14, 0.14, 0.14, 0.03, 3)],
         hit=[P('splash', 0.5, 0.45, 0.5, 0.05, 24),
              P('bubble', 0.45, 0.4, 0.45, 0.02, 18),
              P('dolphin', 0.5, 0.3, 0.5, 0.03, 5),
              SND('entity.fishing_bobber.splash', 0.7, 1.1)]),

    # ── 共鸣: 共鸣水晶。清脆的青色晶光
    dict(style='chime', cn='共鸣', theme='共鸣水晶 · 清脆晶光',
         trail=[P(dust(0.35, 0.95, 1.0, 1.0), 0.12, 0.12, 0.12, 0, 6),
                P('end_rod', 0.15, 0.15, 0.15, 0.01, 5)],
         hit=[P('end_rod', 0.45, 0.45, 0.45, 0.06, 22),
              P(dust(0.35, 0.95, 1.0, 1.5), 0.5, 0.5, 0.5, 0.04, 16),
              P('enchant', 0.5, 0.5, 0.5, 0.3, 10),
              SND('block.amethyst_block.chime', 0.6, 1.7)]),

    # ── 惑梦: 时停。紫 + 逆传送门(时间倒流的涡)
    dict(style='delusion', cn='惑梦', theme='时停 · 紫与逆流的涡',
         trail=[P(dust(0.75, 0.4, 0.9, 1.3), 0.12, 0.12, 0.12, 0, 8),
                P('reverse_portal', 0.18, 0.18, 0.18, 0.02, 3)],
         hit=[P('reverse_portal', 0.6, 0.6, 0.6, 0.05, 20),
              P(dust(0.75, 0.4, 0.9, 1.5), 0.6, 0.55, 0.6, 0.04, 24),
              SND('entity.illusioner.cast_spell', 0.6, 1.35)]),

    # ── 堕梦: 白昼梦 = 梦熄灭。灰烬与白烟
    dict(style='fallen_dream', cn='堕梦', theme='白昼梦 · 熄灭的灰烬',
         trail=[P('ash', 0.13, 0.13, 0.13, 0.01, 6),
                P(dust(0.62, 0.6, 0.65, 1.2), 0.12, 0.12, 0.12, 0, 5),
                P('white_smoke', 0.2, 0.2, 0.2, 0.01, 2)],
         hit=[P('ash', 0.55, 0.5, 0.55, 0.03, 24),
              P('white_ash', 0.5, 0.45, 0.5, 0.02, 12),
              P(dust(0.62, 0.6, 0.65, 1.4), 0.5, 0.5, 0.5, 0.03, 12),
              SND('block.fire.extinguish', 0.55, 0.85)]),

    # ── 终末天启: 圣光 / 光柱。白热的笼罩光(与启示录的"金"分家)
    dict(style='final_revelation', cn='终末天启', theme='圣光 · 白热的光柱',
         trail=[P(dust(1.0, 0.96, 0.78, 1.4), 0.12, 0.12, 0.12, 0, 7),
                P('glow', 0.15, 0.15, 0.15, 0.01, 5)],
         hit=[P('flash', 0.6, 0.5, 0.6, 0.0, 3),
              P('end_rod', 0.6, 0.6, 0.6, 0.1, 30),
              P('glow', 0.5, 0.5, 0.5, 0.03, 18),
              SND('block.beacon.power_select', 0.9, 1.6)]),

    # ── 蛊毒: 噬心。病绿 + 孢子(虫蛊散播)
    dict(style='gu_poison', cn='蛊毒', theme='噬心 · 病绿与虫蛊孢子',
         trail=[P(dust(0.5, 0.95, 0.3, 1.2), 0.12, 0.12, 0.12, 0, 8),
                P('spore_blossom_air', 0.2, 0.2, 0.2, 0.01, 5),
                P('falling_spore_blossom', 0.2, 0.25, 0.2, 0.01, 2)],
         hit=[P('spore_blossom_air', 0.55, 0.5, 0.55, 0.03, 22),
              P(dust(0.5, 0.95, 0.3, 1.5), 0.5, 0.5, 0.5, 0.04, 20),
              SND('entity.slime.squish', 0.6, 0.9)]),

    # ── 调色盘: 红黄蓝三色同时撒 —— 名字本身
    dict(style='palette', cn='调色盘', theme='三色 · 红黄蓝同时撒出',
         trail=[P(dust(1.0, 0.25, 0.3, 1.0), 0.12, 0.12, 0.12, 0, 3),
                P(dust(1.0, 0.85, 0.2, 1.0), 0.12, 0.12, 0.12, 0, 3),
                P(dust(0.3, 0.55, 1.0, 1.0), 0.12, 0.12, 0.12, 0, 3)],
         hit=[P(dust(1.0, 0.25, 0.3, 1.6), 0.55, 0.5, 0.55, 0.05, 10),
              P(dust(1.0, 0.85, 0.2, 1.6), 0.55, 0.5, 0.55, 0.05, 10),
              P(dust(0.3, 0.55, 1.0, 1.6), 0.55, 0.5, 0.55, 0.05, 10),
              P('firework', 0.5, 0.4, 0.5, 0.06, 8),
              SND('entity.firework_rocket.twinkle', 0.7, 1.5)]),

    # ── 偏振光: 一道细而锐的射线。电火花 + 极细的冷白
    dict(style='polarized_light', cn='偏振光', theme='射线 · 细而锐的冷白',
         trail=[P(dust(0.82, 0.95, 1.0, 0.7), 0.1, 0.1, 0.1, 0, 6),
                P('electric_spark', 0.12, 0.12, 0.12, 0.02, 4)],
         hit=[P('electric_spark', 0.45, 0.45, 0.45, 0.05, 20),
              P(dust(0.82, 0.95, 1.0, 1.0), 0.5, 0.5, 0.5, 0.04, 14),
              P('crit', 0.4, 0.4, 0.4, 0.05, 8),
              SND('entity.guardian.attack', 0.6, 1.7)]),

    # ── 风帆: 被鼓起的帆。大团柔云(和风行的"锐利直线风"分家)
    dict(style='sail', cn='风帆', theme='鼓帆 · 大团柔和的云',
         trail=[P(dust(0.95, 0.97, 1.0, 1.8), 0.14, 0.14, 0.14, 0, 5),
                P('cloud', 0.18, 0.15, 0.18, 0.01, 2)],
         hit=[P('cloud', 0.6, 0.5, 0.6, 0.03, 14),
              P('white_smoke', 0.5, 0.45, 0.5, 0.02, 10),
              P(dust(0.95, 0.97, 1.0, 2.0), 0.6, 0.5, 0.6, 0.02, 10),
              SND('entity.wind_charge.wind_burst', 0.5, 0.7)]),

    # ── 暮光: 黄昏 = 紫与橙交界。双色是它的身份证
    # ── 暮光: 黄昏。紫与橙的双色
    #    ★ 命中音不在这里(2026-10-11 用户要求): 普攻命中本身**不出声**,
    #      只有 20% 触发「噬心」那一下才响 —— 音效已搬到
    #      equipment/staff/twilight/tw_proc.mcfunction 第 ③ 步。
    #      (想要改音量/音高: 改 tw_proc 里那一行, 不是这里)
    dict(style='twilight', cn='暮光', theme='黄昏 · 紫与橙的双色',
         note='【命中音在哪】本文件**故意不播音效**。暮光普攻命中本身是静音的,\n'
              '   只有 20% 触发「噬心」时才出声 —— 那一下在\n'
              '   sweetdream:equipment/staff/twilight/tw_proc.mcfunction 第 ③ 步。',
         trail=[P(dust(0.62, 0.26, 0.78, 1.3), 0.12, 0.12, 0.12, 0, 6),
                P(dust(1.0, 0.55, 0.2, 1.1), 0.16, 0.16, 0.16, 0, 4)],
         hit=[P(dust(0.62, 0.26, 0.78, 1.6), 0.55, 0.5, 0.55, 0.05, 18),
              P(dust(1.0, 0.55, 0.2, 1.4), 0.55, 0.5, 0.55, 0.05, 14),
              P('smoke', 0.5, 0.45, 0.5, 0.02, 8)]),

    # ── 风行: 疾风(原来就是它, 原样保留)
    dict(style='wind_ontheground', cn='风行', theme='疾风 · 青白锐利',
         trail=[P(dust(0.72, 1.0, 0.86, 1.1), 0.12, 0.12, 0.12, 0, 8),
                P('small_gust', 0.12, 0.12, 0.12, 0.01, 2)],
         hit=[P('gust', 0.6, 0.5, 0.6, 0.05, 12),
              P('small_gust', 0.9, 0.4, 0.9, 0.08, 22),
              P('crit', 0.4, 0.4, 0.4, 0.05, 8),
              SND('entity.wind_charge.wind_burst', 0.85, 1.15)]),
]

# 兜底: 没写 style(或写了个不认识的)的新法杖, 至少别是"完全隐形"
FALLBACK = dict(style='plain', cn='（兜底）', theme='没指定 style 时的朴素白点',
                trail=[P(dust(0.95, 0.95, 1.0, 1.0), 0.12, 0.12, 0.12, 0, 4)],
                hit=[P('poof', 0.3, 0.3, 0.3, 0.02, 8),
                     P('crit', 0.3, 0.3, 0.3, 0.05, 6),
                     SND('entity.player.attack.strong', 0.6, 1.4)])

ALL = SPECS + [FALLBACK]

# ------------------------------------------------------------------ 文件头
def header(sp, kind):
    who = {'trail': 'ball/tick 第 ④ 步(法球每刻的拖尾) + ball/pop(撞墙时散一下)',
           'hit': 'ball/hit 第 ⑤ 步(执行者/位置 = 命中点)'}[kind]
    tail = '的命中表现' if kind == 'hit' else '的法球拖尾'
    # 可选: sp['note'] 会原样写进文件头(用于交代"某个表现不在这里, 搬到哪去了")
    note = ''
    if sp.get('note'):
        note = ''.join('# %s\n' % ln for ln in sp['note'].split('\n'))
    return (
        '# ============================================================\n'
        '# sweetdream:projectile/ball/fx_%s%s —— 《%s》%s\n'
        '# ------------------------------------------------------------\n'
        '# 【谁调用它】%s\n'
        '# 【主题】%s\n'
        '# 【想换颜色】改 dust 的 color: [红, 绿, 蓝], 每个分量 0.0 ~ 1.0。\n'
        '# 【注意】dust 的参数必须写成 SNBT(dust{color:[...],scale:...}),\n'
        '#   不能把数字直接跟在名字后面 —— 写错不会在加载时报错, 而是运行时报错,\n'
        '#   并且会把后面所有命令一起截断。\n'
        '%s'
        '# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】改规格改生成器, 别手改这里。\n'
        '# ============================================================\n\n'
        % (sp['style'], '_hit' if kind == 'hit' else '', sp['cn'], tail, who,
           sp['theme'], note))

# ------------------------------------------------------------------ 写 fx 文件
def emit():
    made = []
    for sp in ALL:
        for kind, lines in (('trail', sp['trail']), ('hit', sp['hit'])):
            fn = 'fx_%s%s.mcfunction' % (sp['style'], '_hit' if kind == 'hit' else '')
            p = os.path.join(BALL, fn)
            body = header(sp, kind) + '\n'.join(lines) + '\n'
            old = open(p, encoding='utf-8').read() if os.path.isfile(p) else None
            if old != body:
                made.append(('改写' if old else '新增') + ' ' + fn)
                if WRITE:
                    open(p, 'w', encoding='utf-8', newline='\n').write(body)
    return made

# ------------------------------------------------------------------ 派发块
def dispatch_trail():
    out = ['# ④ 拖尾外观(按 style 分工 —— 一把法杖一份, 由 _gen_staff_particles.py 维护)']
    for sp in SPECS:
        out.append('execute if data entity @s data{style:"%s"} '
                   'run function sweetdream:projectile/ball/fx_%s'
                   % (sp['style'], sp['style']))
    return out

def dispatch_hit():
    out = ['# ⑤ 命中表现(按 style 分工 —— 一把法杖一份)']
    for sp in SPECS:
        out.append('execute if data entity @s data{style:"%s"} '
                   'run function sweetdream:projectile/ball/fx_%s_hit'
                   % (sp['style'], sp['style']))
    # ★ 兜底行必须带 `execute` 前缀: 一串 unless 后面直接跟 run 不是合法命令
    guard = ' '.join('unless data entity @s data{style:"%s"}' % sp['style'] for sp in SPECS)
    out.append('# 兜底: 没写 style / 写了个不认识的 —— 至少别什么都不出')
    out.append('#   (一行排掉全部 12 个已知 style; 以后加新法杖记得在这里补一条 unless)')
    out.append('execute ' + guard + ' run function sweetdream:projectile/ball/fx_plain_hit')
    return out

def patch_dispatch(path, start_marker, end_marker, new_lines, tag):
    if not os.path.isfile(path):
        err('找不到 %s' % path)
        return '缺文件'
    lines = open(path, encoding='utf-8').read().split('\n')
    try:
        i = next(k for k, l in enumerate(lines) if start_marker in l)
        j = next(k for k, l in enumerate(lines) if k > i and end_marker in l)
    except StopIteration:
        err('%s: 找不到派发块 marker(%s / %s)' % (tag, start_marker, end_marker))
        return '找不到位置'
    block = lines[i:j]
    if block == new_lines:
        return '已最新(%d 行)' % len(block)
    if WRITE:
        open(path, 'w', encoding='utf-8', newline='\n').write(
            '\n'.join(lines[:i] + new_lines + lines[j:]))
    return '改写 %d 行 -> %d 行' % (len(block), len(new_lines))

# ------------------------------------------------------------------ pop / attack
def patch_pop():
    p = os.path.join(BALL, 'pop.mcfunction')
    body = (
        '# ============================================================\n'
        '# sweetdream:projectile/ball/pop —— 撞墙 / 飞满 30 格\n'
        '# ------------------------------------------------------------\n'
        '# 【和 hit 的区别】这一份**不造成伤害**: 只是球没了, 按自己的风格散一下。\n'
        '#   (撞到方块时, 判定顺序是"先看 1 格里有没有生物再看方块", 所以\n'
        '#    生物站在墙前面的情况照样会被 hit 打到。)\n'
        '# 【执行者】法球自己   【宏参数】$(style)\n'
        '# 【为什么是宏】这里要按法杖的风格散掉, 而 style 只有宏能读到。\n'
        '#   调用方必须带 with: `function ...pop with entity @s data`(见 ball/tick)。\n'
        '# 【本文件由 .workbuddy/_gen_staff_particles.py 生成】\n'
        '# ============================================================\n\n'
        '$function sweetdream:projectile/ball/fx_$(style)\n'
        'kill @s\n')
    old = open(p, encoding='utf-8').read() if os.path.isfile(p) else None
    if old == body:
        return 'pop 已最新'
    if WRITE:
        open(p, 'w', encoding='utf-8', newline='\n').write(body)
    return 'pop 改写(改成宏函数, 复用各自的拖尾)'

def patch_tick_pop_calls():
    p = os.path.join(BALL, 'tick.mcfunction')
    txt = open(p, encoding='utf-8').read()
    old = 'function sweetdream:projectile/ball/pop'
    new = 'function sweetdream:projectile/ball/pop with entity @s data'
    if new in txt:
        return 'tick 里 pop 调用已带 with'
    n = txt.count(old)
    if not n:
        err('tick.mcfunction 里找不到 pop 调用')
        return '找不到 pop 调用'
    if WRITE:
        open(p, 'w', encoding='utf-8', newline='\n').write(txt.replace(old, new))
    return 'tick 里 %d 处 pop 调用补上 with entity @s data' % n

def patch_attacks():
    changed = []
    for sp in SPECS:
        p = os.path.join(STAFF, sp['style'], 'attack.mcfunction')
        if not os.path.isfile(p):
            err('法杖 %s 没有 attack.mcfunction' % sp['style'])
            continue
        txt = open(p, encoding='utf-8').read()
        m = re.search(r'data modify storage zx:work ball set value \{([^}]*)\}', txt)
        if not m:
            err('%s/attack: 找不到 `ball set value {...}` 那一行' % sp['style'])
            continue
        want = 'style:"%s"' % sp['style']
        if want in m.group(1):
            continue
        if 'style:' not in m.group(1):
            err('%s/attack: 装球那行没有 style 字段' % sp['style'])
            continue
        new = re.sub(r'style:"[a-z_]*"', want, m.group(1))
        changed.append('%-18s style -> %s' % (sp['style'], want))
        if WRITE:
            open(p, 'w', encoding='utf-8', newline='\n').write(
                txt[:m.start(1)] + new + txt[m.end(1):])
    return changed

# ------------------------------------------------------------------ 主流程
if __name__ == '__main__':
    print('=== 素材核对 ===')
    print('1.21.5 粒子 %d 个 / 音效事件 %d 条' % (len(PARTICLES), len(SOUND_IDS)))

    print('\n=== 产出 fx 文件 ===')
    made = emit()
    for m in made:
        print('  ' + m)
    if not made:
        print('  (全部已最新)')

    print('\n=== 派发 ===')
    print('  tick ④: ' + patch_dispatch(os.path.join(BALL, 'tick.mcfunction'),
                                        '# ④ 拖尾外观', '# ⑤ 射程耗尽',
                                        dispatch_trail(), 'tick'))
    print('  hit  ⑤: ' + patch_dispatch(os.path.join(BALL, 'hit.mcfunction'),
                                        '# ⑤ 命中表现', '# ⑥ 可选',
                                        dispatch_hit(), 'hit'))
    print('  ' + patch_pop())
    print('  ' + patch_tick_pop_calls())

    print('\n=== 法杖 style ===')
    ch = patch_attacks()
    for c in ch:
        print('  ' + c)
    if not ch:
        print('  (全部已是自己的 id)')

    print('\n=== 自检 ===')
    if ERR:
        for e in ERR:
            print('  ✗ ' + e)
        print('\n有 %d 个问题' % len(ERR))
        sys.exit(1)
    print('  粒子名 / 选项 / 音效名 全部核对通过 ✓')
    print('  模式: %s' % ('已写入' if WRITE else '试运行(加 --write 才会真的写)'))
