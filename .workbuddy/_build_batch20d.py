# -*- coding: utf-8 -*-
"""批 20-C：把 9 件装备接入派发/注册表（幂等，可重复跑）"""
import io, json, os, sys
sys.stdout.reconfigure(encoding='utf-8')

FN = r'D:/数据包/fallendream/data/fallendream/function'
AD = r'D:/数据包/fallendream/data/fallendream/advancement'
MK = '批 20（2026-10-27）'


def read(p):
    with io.open(p, encoding='utf-8') as f:
        return f.read()


def write(p, s):
    with io.open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write(s)


def insert_before(path, marker, block):
    t = read(path)
    if block.strip().splitlines()[0] in t:
        print('skip (exists)', os.path.basename(path))
        return
    assert marker in t, 'marker missing in ' + path
    t = t.replace(marker, block + '\n' + marker, 1)
    write(path, t)
    print('inserted', os.path.basename(path))


def append(path, block):
    t = read(path)
    if block.strip().splitlines()[0] in t:
        print('skip (exists)', os.path.basename(path))
        return
    if not t.endswith('\n'):
        t += '\n'
    write(path, t + '\n' + block)


# ============================================================
# ① core/load：计分项注册
# ============================================================
OBJS = [
    ('ov_lt', '胜利誓约 被动同刻去重'),
    ('ov_ft', '胜利誓约 领域剩余秒(marker)'),
    ('ov_hp', '溢流 生命上限账本'),
    ('pv_lim', '枢 术阵位上限差值账本'),
    ('br_a', '承 护甲档'), ('br_t', '承 韧性档'), ('br_spd', '承 移速档'),
    ('br_full', '承 阵容边沿'), ('br_zc', '承 阵成到期刻'), ('br_cd', '承 阵成 12 秒冷却'),
    ('br_fm', '承 术阵基线(返还用)'),
    ('ec_a', '空营 护甲档'), ('ec_t', '空营 韧性档'),
    ('lw_spd', '独行 移速账本'), ('lw_arm', '独行 临敌护甲账本'), ('lw_on', '独行 ≤2 增伤'),
    ('lw_lc', '独行 临敌到期刻'), ('lw_cd', '独行 临敌 16 秒冷却'), ('lw_last', '独行 上秒敌对数量'),
    ('it_hp', '蓄意 生命上限账本'), ('it_sum', '蓄意 累计消耗魔力(毫点)'), ('it_cd', '蓄意 12 秒冷却'),
    ('as_cd', '踏空 10 秒冷却'),
    ('thp', '临时生命值(点)'), ('thp_end', '临时生命到期刻'),
    ('fm_u', '术阵位占用'), ('fm_c', '术阵位上限'),
]
lines = ['# ===== ' + MK + '：胜利誓约 + 8 件终端盔甲 + 临时生命/术阵位框架 =====',
         '#   ★ 全部打在**玩家**身上（玩家分数不参与区块存盘, 不需要三维度兜底清零）。',
         '#   ★ 术阵位读数 zx.fm_u / zx.fm_c 由 lib/fm/read 每秒从前置包 formation/count 取。',
         '#   ★ 临时生命 zx.thp 的唯一写入口是 lib/thp（吸收药水 + max_absorption 上限）。']
for name, desc in OBJS:
    lines.append('#   zx.%s = %s' % (name, desc))
for name, desc in OBJS:
    lines.append('execute unless data storage zx:config obj_%s run scoreboard objectives add zx.%s dummy' % (name, name))
    lines.append('execute unless data storage zx:config obj_%s run data modify storage zx:config obj_%s set value 1b' % (name, name))
append(os.path.join(FN, 'core/load.mcfunction'), '\n'.join(lines) + '\n')

# ============================================================
# ② lib/second：每秒派发
# ============================================================
SEC = '''# ===== ''' + MK + '''：术阵位读数 + 新装备每秒结算 =====
#   ★ lib/fm/read **必须排在所有用到术阵位数的装备之前**（承/屏息都读它）。
execute as @a run function fallendream:lib/fm/read
execute as @a run function fallendream:equipment/armor/pivot/second
execute as @a run function fallendream:equipment/armor/bearing/second
execute as @a run function fallendream:equipment/armor/empty_camp/second
execute as @a run function fallendream:equipment/armor/lone_walk/second
execute as @a run function fallendream:equipment/armor/overflow/second
execute as @a run function fallendream:equipment/armor/intent/second
execute as @a run function fallendream:equipment/armor/breath_hold/second

#   临时生命：只维护"身上真挂着"的人（lib/thp/tick 内部会读一次 AbsorptionAmount）
execute as @a[scores={zx.thp=1..}] run function fallendream:lib/thp/tick

#   胜利誓约的领域（三维度各扫一遍：marker 只在被加载的区块里）
execute in minecraft:overworld as @e[type=marker,tag=zx.ov_field,distance=0..] at @s run function fallendream:equipment/sword/oath_victory/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.ov_field,distance=0..] at @s run function fallendream:equipment/sword/oath_victory/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.ov_field,distance=0..] at @s run function fallendream:equipment/sword/oath_victory/field_tick
'''
append(os.path.join(FN, 'lib/second.mcfunction'), SEC)

# ============================================================
# ③ core/tick：蓄意每刻
# ============================================================
TICK = '''# ===== ''' + MK + '''：蓄意「每使用 50 魔力 → 2 点临时生命」（每刻最多兑现一次）=====
#   ★ 每刻而不是每秒：文案写"单次技能可重复触发"，200 魔力的技能要一次兑现 4 次。
execute as @a run function fallendream:equipment/armor/intent/tick
'''
append(os.path.join(FN, 'core/tick.mcfunction'), TICK)

# ============================================================
# ④ armor_mana/passive：魔力上限（必须插在 ④ 差值计算之前）
# ============================================================
AM = '''# ---- 批 20(2026-10-27)· 枢/承/空营/独行/溢流/蓄意/踏空/屏息 ----
#   枢(头盔) +120 / 承(腿) +140 / 空营(胸) +140 / 独行(靴) +120
#   溢流(腿) +80 / 蓄意(胸) +150 / 踏空(靴) +50 / 屏息(头盔) +60
#   ★ 数字逐字取自用户 2026-10-27 的文案。套装（枢+承 / 空营+独行）**不给**魔力上限。
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run scoreboard players add #want zx.meta 120
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["bearing"]}] run scoreboard players add #want zx.meta 140
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"]}] run scoreboard players add #want zx.meta 140
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lone_walk"]}] run scoreboard players add #want zx.meta 120
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"]}] run scoreboard players add #want zx.meta 80
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run scoreboard players add #want zx.meta 150
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["air_step"]}] run scoreboard players add #want zx.meta 50
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["breath_hold"]}] run scoreboard players add #want zx.meta 60
'''
insert_before(os.path.join(FN, 'equipment/armor/armor_mana/passive.mcfunction'),
              '# ---- ④ 差值 = 该有的 - 账本已加的; 不为 0 就补/退 ----', AM)

# ============================================================
# ⑤ damage_calc.json：承（独立）/ 独行（加算 + 独立）
# ============================================================
p = os.path.join(AD, '../../manacore/tags/function/event/damage_calc.json')
p = os.path.normpath(p)
d = json.loads(read(p))
v = d['values']
if 'fallendream:equipment/armor/bearing/hook_calc' not in v:
    # 独立乘区类：排在 glimmer/hook_calc（同为最终伤害乘区）旁边
    i = v.index('fallendream:equipment/armor/glimmer/hook_calc')
    v.insert(i, 'fallendream:equipment/armor/bearing/hook_calc')
    v.insert(i + 1, 'fallendream:equipment/armor/lone_walk/hook_calc')
if 'fallendream:equipment/armor/lone_walk/hook_add' not in v:
    # 加算类：必须排在 lib/dmg_add_apply **之前**
    j = v.index('fallendream:lib/dmg_add_apply')
    v.insert(j, 'fallendream:equipment/armor/lone_walk/hook_add')
write(p, json.dumps(d, ensure_ascii=False, indent=2) + '\n')
print('damage_calc ok', len(v))

# ============================================================
# ⑥ cooldown_start.json：承 的冷却 −10%
# ============================================================
p = os.path.normpath(os.path.join(AD, '../../manacore/tags/function/event/cooldown_start.json'))
d = json.loads(read(p))
if 'fallendream:equipment/armor/bearing/on_cast' not in d['values']:
    d['values'].append('fallendream:equipment/armor/bearing/on_cast')
write(p, json.dumps(d, ensure_ascii=False, indent=2) + '\n')
print('cooldown_start ok')

# ============================================================
# ⑦ lib/mana/pay：蓄意账本
# ============================================================
PAY = '''execute if score #pm_v zx.meta matches 1.. run scoreboard players operation @s zx.it_sum += #pm_v zx.meta
'''
insert_before(os.path.join(FN, 'lib/mana/pay.mcfunction'),
              '# 折潮只在这笔成功的正数扣费内结算一次；不留给每刻循环批量兑现。',
              '# 蓄意（批 20）用**自己的**账本：与剖面的 zx.pm_sum 各自累加、各自扣减，\n#   共用一份会互相饿死（见本文件头"为什么是三份"）。\n' + PAY)

# ============================================================
# ⑧ lib/heal：溢流 hook（文件末尾）
# ============================================================
HEAL = '''
# ===== ''' + MK + '''：溢流「过量治疗 → 50% 转临时生命」=====
#   必须排在 ⑩ 出参之后：#heal_pt / #heal_got 都还在（见 overflow/hook_heal 文件头）。
function fallendream:equipment/armor/overflow/hook_heal
'''
append(os.path.join(FN, 'lib/heal.mcfunction'), HEAL)

# ============================================================
# ⑨ lib/thp/clear：清空回调（蓄意）
# ============================================================
CLR = '''
# ===== ''' + MK + '''：临时生命清空的回调（蓄意：抗性提升Ⅱ + 迅捷Ⅲ）=====
#   ★ 执行者仍是玩家；没穿「蓄意」时 on_empty 第一行就会返回。
function fallendream:equipment/armor/intent/on_empty
'''
append(os.path.join(FN, 'lib/thp/clear.mcfunction'), CLR)

# ============================================================
# ⑩ lib/reg/build：names 登记（观测镜 / debug worn 显示中文名）
# ============================================================
NAMES = '''# ---- 批 20 · 胜利誓约 + 8 件终端盔甲(2026-10-27) ----
data modify storage zx:reg names.oath_victory set value "胜利誓约"
data modify storage zx:reg names.pivot set value "枢"
data modify storage zx:reg names.bearing set value "承"
data modify storage zx:reg names.empty_camp set value "空营"
data modify storage zx:reg names.lone_walk set value "独行"
data modify storage zx:reg names.overflow set value "溢流"
data modify storage zx:reg names.intent set value "蓄意"
data modify storage zx:reg names.air_step set value "踏空"
data modify storage zx:reg names.breath_hold set value "屏息"
'''
insert_before(os.path.join(FN, 'lib/reg/build.mcfunction'),
              '# ============================================================\n# tg: 每个 /trigger 调试入口',
              NAMES)

print('done')
