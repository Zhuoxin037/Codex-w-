# -*- coding: utf-8 -*-
"""批 20-B2：空营 / 独行 / 溢流 / 蓄意 / 踏空 / 屏息 的机制文件 + 进度"""
import os, json
ROOT = r'D:/数据包/sweetdream/data/sweetdream'
FN = os.path.join(ROOT, 'function')
AD = os.path.join(ROOT, 'advancement')

F = {}

# ============================================================
# 空营
# ============================================================
F['equipment/armor/empty_camp/second.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/empty_camp/second —— 「空营」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】魔力 +140（armor_mana 登记）。自身 8 格内每有 1 个敌对生物，护甲值 +1、
#   护甲韧性 +0.5（最多 6 层）。8 格内没有敌对生物时，每秒恢复 3 点魔力值。
# 【★ 敌对 = type=!#sweetdream:no_damage 且不是玩家 ★】包内 `no_damage` 排除 marker /
#   法球 / 领域；再排除玩家 —— "敌对生物"不含队友（多人同场时否则会互相顶层数）。
#   ★ 与"全部生物"类技能（神裁/踏空）**相反**：那些按包内口径包含玩家。
# 【★ 数数量 ★】`as @e[...] run scoreboard players add` —— 每只加 1，这是 mcfunctions
#   里唯一可靠的计数写法（没有 count 命令）。
# 【★ 换档先摘后挂 ★】同 id modifier 重复 add 会失败；档位没变就一条都不发。
# ============================================================

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"]}] run function sweetdream:equipment/armor/empty_camp/off
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"]}] run return 0

# ① 数 8 格内敌对，夹到 6
scoreboard players set #ec_n zx.meta 0
execute as @e[type=!#sweetdream:no_damage,type=!minecraft:player,distance=..8] run scoreboard players add #ec_n zx.meta 1
scoreboard players set #ec_6 zx.meta 6
execute if score #ec_n zx.meta > #ec_6 zx.meta run scoreboard players set #ec_n zx.meta 6

# ② 换档（护甲 = n / 韧性 = 0.5n）
execute unless score #ec_n zx.meta = @s zx.ec_a run function sweetdream:equipment/armor/empty_camp/attr_arm
execute unless score #ec_n zx.meta = @s zx.ec_t run function sweetdream:equipment/armor/empty_camp/attr_tou

# ③ 有敌对就不回魔
execute if score #ec_n zx.meta matches 1.. run return 0

# ④ 每秒回 3 魔力
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:3.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add
'''

F['equipment/armor/empty_camp/attr_arm.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/empty_camp/attr_arm —— 换护甲档（#ec_n = 层数 0..6）
# ------------------------------------------------------------
# 【★ 字面量禁区 ★】modifier 数值只能是字面量 ⇒ 1..6 六条分支各写一条。
# ============================================================

execute if score @s zx.ec_a matches 1.. run attribute @s minecraft:armor modifier remove sweetdream:ec_arm
scoreboard players set @s zx.ec_a 0
execute if score #ec_n zx.meta matches 1 run attribute @s minecraft:armor modifier add sweetdream:ec_arm 1 add_value
execute if score #ec_n zx.meta matches 2 run attribute @s minecraft:armor modifier add sweetdream:ec_arm 2 add_value
execute if score #ec_n zx.meta matches 3 run attribute @s minecraft:armor modifier add sweetdream:ec_arm 3 add_value
execute if score #ec_n zx.meta matches 4 run attribute @s minecraft:armor modifier add sweetdream:ec_arm 4 add_value
execute if score #ec_n zx.meta matches 5 run attribute @s minecraft:armor modifier add sweetdream:ec_arm 5 add_value
execute if score #ec_n zx.meta matches 6 run attribute @s minecraft:armor modifier add sweetdream:ec_arm 6 add_value
scoreboard players operation @s zx.ec_a = #ec_n zx.meta
'''

F['equipment/armor/empty_camp/attr_tou.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/empty_camp/attr_tou —— 换韧性档（0.5 / 1.0 / … / 3.0）
# ------------------------------------------------------------
# 【★ 字面量禁区 ★】六条分支各写一条；0 层不挂。
# ============================================================

execute if score @s zx.ec_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove sweetdream:ec_tou
scoreboard players set @s zx.ec_t 0
execute if score #ec_n zx.meta matches 1 run attribute @s minecraft:armor_toughness modifier add sweetdream:ec_tou 0.5 add_value
execute if score #ec_n zx.meta matches 2 run attribute @s minecraft:armor_toughness modifier add sweetdream:ec_tou 1.0 add_value
execute if score #ec_n zx.meta matches 3 run attribute @s minecraft:armor_toughness modifier add sweetdream:ec_tou 1.5 add_value
execute if score #ec_n zx.meta matches 4 run attribute @s minecraft:armor_toughness modifier add sweetdream:ec_tou 2.0 add_value
execute if score #ec_n zx.meta matches 5 run attribute @s minecraft:armor_toughness modifier add sweetdream:ec_tou 2.5 add_value
execute if score #ec_n zx.meta matches 6 run attribute @s minecraft:armor_toughness modifier add sweetdream:ec_tou 3.0 add_value
scoreboard players operation @s zx.ec_t = #ec_n zx.meta
'''

F['equipment/armor/empty_camp/off.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/empty_camp/off —— 摘下「空营」：撤属性
# ============================================================

execute if score @s zx.ec_a matches 1.. run attribute @s minecraft:armor modifier remove sweetdream:ec_arm
execute if score @s zx.ec_t matches 1.. run attribute @s minecraft:armor_toughness modifier remove sweetdream:ec_tou
scoreboard players set @s zx.ec_a 0
scoreboard players set @s zx.ec_t 0
'''

# ============================================================
# 独行
# ============================================================
F['equipment/armor/lone_walk/second.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/lone_walk/second —— 「独行」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】魔力 +120（armor_mana 登记）/ 移速 +8%；8 格内敌对 ≤2 → 技能伤害 +8%；
#   套装（+空营）：8 格内敌对数量**变化**时 → 4 秒「临敌」（护甲 +4 / 技能伤害 +10% 独立），
#   每 16 秒最多一次。
# 【★ 移速只挂一次 ★】穿上的第一秒挂 0.08，之后靠账本 zx.lw_spd 跳过。
# 【★ 「临敌」是"变化"触发 ★】zx.lw_last 记上秒数量；第一次跑只记基线不触发。
# ============================================================

execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["lone_walk"]}] run function sweetdream:equipment/armor/lone_walk/off
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["lone_walk"]}] run return 0

# ① 移速 +8%（只挂一次）
execute unless score @s zx.lw_spd matches 1 run attribute @s minecraft:movement_speed modifier add sweetdream:lw_spd 0.08 add_multiplied_total
execute unless score @s zx.lw_spd matches 1 run scoreboard players set @s zx.lw_spd 1

# ② 数 8 格内敌对
scoreboard players set #lw_n zx.meta 0
execute as @e[type=!#sweetdream:no_damage,type=!minecraft:player,distance=..8] run scoreboard players add #lw_n zx.meta 1

# ③ ≤2 → 技能伤害 +8%（hook_calc 读 zx.lw_on）
scoreboard players set @s zx.lw_on 0
execute if score #lw_n zx.meta matches ..2 run scoreboard players set @s zx.lw_on 1

# ④ 套装「临敌」：数量变化 → 4 秒，16 秒冷却
function sweetdream:equipment/armor/lone_walk/set_lc

# ⑤ 临敌期间的护甲 +4（挂/摘）
execute if score @s zx.lw_lc > #now manacore.meta unless score @s zx.lw_arm matches 1 run attribute @s minecraft:armor modifier add sweetdream:lw_arm 4 add_value
execute if score @s zx.lw_lc > #now manacore.meta unless score @s zx.lw_arm matches 1 run scoreboard players set @s zx.lw_arm 1
execute if score @s zx.lw_lc <= #now manacore.meta if score @s zx.lw_arm matches 1 run attribute @s minecraft:armor modifier remove sweetdream:lw_arm
execute if score @s zx.lw_lc <= #now manacore.meta if score @s zx.lw_arm matches 1 run scoreboard players set @s zx.lw_arm 0
'''

F['equipment/armor/lone_walk/set_lc.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/lone_walk/set_lc —— 套装「临敌」的触发（每秒）
# ------------------------------------------------------------
# 【执行者】玩家（已确认穿着「独行」）
# 【★ 套装还要求胸甲是「空营」★】没穿就只更新基线，不触发。
# 【★ 数量变化 = zx.lw_last ≠ #lw_n ★】lw_last 没分数（第一次跑）时只记基线。
# ============================================================

# 没穿空营 ⇒ 只同步基线
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"]}] run scoreboard players operation @s zx.lw_last = #lw_n zx.meta
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["empty_camp"]}] run return 0

# 首次跑：只记基线
execute unless score @s zx.lw_last matches 0.. run scoreboard players operation @s zx.lw_last = #lw_n zx.meta
execute unless score @s zx.lw_last matches 0.. run return 0

# 数量没变 ⇒ 收工
execute if score @s zx.lw_last = #lw_n zx.meta run return 0
scoreboard players operation @s zx.lw_last = #lw_n zx.meta

# 16 秒冷却
execute if score @s zx.lw_cd > #now manacore.meta run return 0

# 触发 4 秒「临敌」
scoreboard players operation @s zx.lw_lc = #now manacore.meta
scoreboard players add @s zx.lw_lc 80
scoreboard players operation @s zx.lw_cd = #now manacore.meta
scoreboard players add @s zx.lw_cd 320

tellraw @s [{"text":"「临敌」","color":"gold"},{"text":"  护甲值 +4、技能伤害 +10%","color":"gray"}]
particle minecraft:crit ~ ~1 ~ 0.6 0.4 0.6 0.05 12 normal
'''

F['equipment/armor/lone_walk/off.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/lone_walk/off —— 摘下「独行」：撤移速 / 护甲 / 状态
# ============================================================

execute if score @s zx.lw_spd matches 1 run attribute @s minecraft:movement_speed modifier remove sweetdream:lw_spd
execute if score @s zx.lw_arm matches 1 run attribute @s minecraft:armor modifier remove sweetdream:lw_arm
scoreboard players set @s zx.lw_spd 0
scoreboard players set @s zx.lw_arm 0
scoreboard players set @s zx.lw_on 0
scoreboard players set @s zx.lw_lc 0
'''

F['equipment/armor/lone_walk/hook_add.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/lone_walk/hook_add —— 「独行」被动 +8%（加算池）
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc，排在 lib/dmg_add_apply **之前**
#   （加算池必须先填好，apply 才有东西可并）。
# 【执行者】施法者（玩家）
# 【★ 为什么不写在 hook_calc 里 ★】hook_calc 挂在 dmg_add_apply **之后**（独立乘区），
#   那时候加算池已经并进伤害了，再往里写不会有任何效果（静默失效）。
#   ★ 真实事故 2026-10-27: 曾经把 ① ② 都塞进 hook_calc（声明 `# @calc: add + indep`），
#     check.py 判"加算 hook 排在 apply 之后 = 永远不算"，两份增伤各自静默一半。
# 【★ 三次 dmg_add_put ★】它是宏（ch 一次只能一个通道），三条通道都 +8 = 整体 +8%，
#   属**非独立**（文案没写"独立乘区"）。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.lw_on matches 1 run return 0

scoreboard players set #lw_8 zx.meta 8
data modify storage zx:work put set value {ch:"mm",pct:0}
execute store result storage zx:work put.pct int 1 run scoreboard players get #lw_8 zx.meta
function sweetdream:lib/dmg_add_put with storage zx:work put

data modify storage zx:work put.ch set value "atk"
function sweetdream:lib/dmg_add_put with storage zx:work put

data modify storage zx:work put.ch set value "oth"
function sweetdream:lib/dmg_add_put with storage zx:work put
'''

F['equipment/armor/lone_walk/hook_calc.mcfunction'] = r'''# @calc: indep — 套装「临敌」期间技能伤害 +10%（独立乘区）
# ============================================================
# sweetdream:equipment/armor/lone_walk/hook_calc —— 「临敌」的 10% 独立乘区
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/damage_calc（排在 lib/dmg_add_apply **之后**）
# 【执行者】施法者（玩家）
# 【★ 为什么只做独立乘区 ★】本件的另一段增伤（被动 +8%）**没有**"独立乘区"字样，
#   属加算 ⇒ 在 lone_walk/hook_add（apply 之前）里做。两件事必须分开挂在两个文件，
#   合并成一个文件必然有一边挂错位置而静默失效（见 hook_add 文件头的事故注）。
# 【★ 写法 ★】与 glimmer/hook_calc 逐字同源：r.damage ×1000 → mul_pct(×110) → ÷1000。
# 【★ 窗口判据 ★】zx.lw_lc = 「临敌」到期刻（set_lc 写 #now+80 = 4 秒），`> #now` 即生效中。
# ============================================================

execute unless entity @s[type=minecraft:player] run return 0
execute unless score @s zx.lw_lc > #now manacore.meta run return 0

scoreboard players set #lwc zx.meta 0
execute store result score #lwc zx.meta run data get storage manacore:out r.damage 1000
scoreboard players set #lwk zx.meta 110
function manacore:internal/damage/mul_pct {src:"#lwc",mul:"#lwk",obj:"zx.meta"}
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #mul_out zx.meta
'''

# ============================================================
# 溢流
# ============================================================
F['equipment/armor/overflow/second.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/overflow/second —— 「溢流」常驻生命上限 +4
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】魔力 +80（armor_mana 登记），最大生命值 +4。
#   被过量治疗后 50% 溢出量转临时生命（hook 在 lib/heal 出口 → overflow/hook_heal）。
# 【★ 生命上限用 add_value 4 ★】不是百分比（"+20%" 那种才用 add_multiplied_total）。
# ============================================================

execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"]}] run function sweetdream:equipment/armor/overflow/off
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"]}] run return 0

execute unless score @s zx.ov_hp matches 1 run attribute @s minecraft:max_health modifier add sweetdream:ov_hp 4 add_value
execute unless score @s zx.ov_hp matches 1 run scoreboard players set @s zx.ov_hp 1
'''

F['equipment/armor/overflow/off.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/overflow/off —— 摘下「溢流」：撤生命上限
# ============================================================

execute if score @s zx.ov_hp matches 1 run attribute @s minecraft:max_health modifier remove sweetdream:ov_hp
scoreboard players set @s zx.ov_hp 0
'''

F['equipment/armor/overflow/hook_heal.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/overflow/hook_heal —— 过量治疗 → 50% 转临时生命
# ------------------------------------------------------------
# 【谁调用它】lib/heal 的第 ⑩ 步之后（那一刻 #heal_pt / #heal_got 都还在）
# 【执行者】被治疗的玩家
# 【★ 过量 = 请求量 − 实得 ★】lib/heal 的 ⑥ 会把目标夹到真实上限，所以
#   #heal_got 是"计划实得"，#heal_pt 是"请求量"，差值就是溢出的部分。
# 【★ 只覆盖 lib/heal 这条链 ★】原版再生/瞬治在满血时本来就不产生治疗量，
#   不会"溢出"；本包的治疗技能全部走 lib/heal ⇒ 覆盖面够。
# 【★ 单位都是整点 ★】lib/heal 的入参与出参都是整点，/2 向下取整。
# ============================================================

execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["overflow"]}] run return 0

scoreboard players set #ovf zx.meta 0
scoreboard players operation #ovf zx.meta = #heal_pt zx.meta
scoreboard players operation #ovf zx.meta -= #heal_got zx.meta
execute if score #ovf zx.meta matches ..0 run return 0

# 50%
scoreboard players set #ovf_2 zx.meta 2
scoreboard players operation #ovf zx.meta /= #ovf_2 zx.meta
execute if score #ovf zx.meta matches ..0 run return 0

scoreboard players operation #thp_v zx.meta = #ovf zx.meta
function sweetdream:lib/thp/add
'''

# ============================================================
# 蓄意
# ============================================================
F['equipment/armor/intent/second.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/intent/second —— 「蓄意」常驻生命上限 +20%
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】魔力 +150（armor_mana 登记），最大生命值 +20%。
#   每使用 50 魔力 → +2 临时生命（intent/tick 每刻结算）。
#   临时生命清空 → 5 秒抗性Ⅱ + 迅捷Ⅲ，12 秒冷却（intent/on_empty）。
# 【★ "+20%" 用 add_multiplied_total ★】基数是玩家**原版**最大生命（20 点），
#   与包内其它百分比生命加成同一口径。
# ============================================================

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run function sweetdream:equipment/armor/intent/off
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run return 0

execute unless score @s zx.it_hp matches 1 run attribute @s minecraft:max_health modifier add sweetdream:it_hp 0.2 add_multiplied_total
execute unless score @s zx.it_hp matches 1 run scoreboard players set @s zx.it_hp 1
'''

F['equipment/armor/intent/off.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/intent/off —— 摘下「蓄意」：撤生命上限 + 账本
# ============================================================

execute if score @s zx.it_hp matches 1 run attribute @s minecraft:max_health modifier remove sweetdream:it_hp
scoreboard players set @s zx.it_hp 0
scoreboard players set @s zx.it_sum 0
'''

F['equipment/armor/intent/tick.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/intent/tick —— 「每使用 50 魔力 → +2 临时生命」（每刻）
# ------------------------------------------------------------
# 【谁调用它】core/tick（每刻 as @a）
# 【执行者】玩家
# 【★ 为什么每刻而不是每秒 ★】文案写"单次技能可重复触发"：一个大技能一次花 200 魔力
#   = 20 万毫魔力点 = 4 次触发。每秒只查一次的话，200 点的技能要 4 秒才能兑现完，
#   中途死了/换装就丢了。每刻最多兑现一次（50000），一秒最多兑现 1000 点魔力，够用。
# 【★ 账本 zx.it_sum 从哪来 ★】lib/mana/pay 记（毫魔力点）。与剖面的 zx.pm_sum
#   **各自独立** —— 共用一份会互相饿死（见 lib/mana/pay 头注释）。
# 【★ 50000 = 50 魔力 ×1000 ★】
# ============================================================

# 没穿「蓄意」⇒ 账本清零（别人的账本不动）
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run scoreboard players set @s zx.it_sum 0
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run return 0

execute if score @s zx.it_sum matches ..49999 run return 0
scoreboard players remove @s zx.it_sum 50000

scoreboard players set #thp_v zx.meta 2
function sweetdream:lib/thp/add
'''

F['equipment/armor/intent/on_empty.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/intent/on_empty —— 临时生命清空 → 抗性Ⅱ + 迅捷Ⅲ
# ------------------------------------------------------------
# 【谁调用它】lib/thp/clear（临时生命被清空的那一刻；执行者 = 玩家）
# 【文案】自身临时生命值清空后，获得 5 秒抗性提升Ⅱ和迅捷Ⅲ；该效果每 12 秒最多触发一次。
# 【★ 12 秒冷却 ★】zx.it_cd = 下次可触发的刻；没分数时 `> #now` 判失败 ⇒ 第一次放行。
# 【★ 摘掉「蓄意」之后不会再给 ★】穿着门控放第一行。
# ============================================================

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run return 0
execute if score @s zx.it_cd > #now manacore.meta run return 0

scoreboard players operation @s zx.it_cd = #now manacore.meta
scoreboard players add @s zx.it_cd 240

effect give @s minecraft:resistance 5 1 true
effect give @s minecraft:speed 5 2 true

tellraw @s [{"text":"「蓄意」","color":"gold"},{"text":"  临时生命清空 —— 抗性提升Ⅱ、迅捷Ⅲ（5 秒）","color":"gray"}]
particle minecraft:totem_of_undying ~ ~1 ~ 0.4 0.6 0.4 0.1 12 normal
'''

# ============================================================
# 踏空
# ============================================================
F['equipment/armor/air_step/land.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/air_step/land —— 「踏空」落地冲击（进度入口）
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/air_step_land
#   （trigger = minecraft:fall_from_height，distance.y ≥ 2.0 ⇒ 普通跳跃只掉 1.25 格，不触发）
# 【执行者】落地的玩家
# 【文案】魔力 +50（armor_mana 登记）。从空中落地时，对 4 格内全部生物造成一次相当于
#   自身基础攻击力的伤害并使其击飞 1 格，之后自身恢复 10 点魔力值。每 10 秒最多一次。
# 【★ 为什么用进度而不是 OnGround ★】`@a[nbt={OnGround:1b}]` = 每刻给每个玩家做一次
#   完整 NBT 序列化（≈10 ms/次，卡顿坑 1）。fall_from_height 是事件型进度，落地那刻
#   抛一次，零开销。
# 【★ 击飞写法 ★】生物 NBT 可写（玩家不行）⇒ `data modify entity @s Motion`。
#   0.36 的纵向速度 ≈ 1 格高（包内锚·冲击同款）。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/air_step_land

execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["air_step"]}] run return 0
execute if score @s zx.as_cd > #now manacore.meta run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 10 秒冷却
scoreboard players operation @s zx.as_cd = #now manacore.meta
scoreboard players add @s zx.as_cd 200

# 伤害：基础攻击力 ×1
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=0.1..4]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage

# 击飞 1 格
execute as @e[type=!#sweetdream:no_damage,distance=0.1..4] run data modify entity @s Motion set value [0.0d,0.36d,0.0d]

# 回 10 魔力
data modify storage manacore:in arg set value {uuid:"",value:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# 表现
particle minecraft:cloud ~ ~0.1 ~ 1.6 0.1 1.6 0.02 20 normal
particle minecraft:explosion_emitter ~ ~0.2 ~ 0 0 0 0 1 normal
playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.5 1.2
'''

# ============================================================
# 屏息
# ============================================================
F['equipment/armor/breath_hold/second.mcfunction'] = r'''# ============================================================
# sweetdream:equipment/armor/breath_hold/second —— 「屏息」每秒回魔
# ------------------------------------------------------------
# 【执行者】玩家（lib/fm/read 之后）
# 【文案】魔力 +60（armor_mana 登记）。每有 1 个空闲术阵位，每秒恢复 2 点魔力值。
#   术阵位全满时，改为每秒恢复 1 点魔力值。
# 【★ 空闲 = 上限 − 占用 ★】用 zx.fm_c / zx.fm_u。
# 【★ 全满也给 1 点 ★】文案是"改为"，不是"不再恢复"。
# ============================================================

execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["breath_hold"]}] run return 0

scoreboard players operation #bh_free zx.meta = @s zx.fm_c
scoreboard players operation #bh_free zx.meta -= @s zx.fm_u

# 全满（空闲 ≤0）⇒ 1 点
scoreboard players set #bh_re zx.meta 0
execute if score #bh_free zx.meta matches ..0 run scoreboard players set #bh_re zx.meta 1

# 有空闲 ⇒ 空闲 ×2
execute if score #bh_free zx.meta matches 1.. run scoreboard players operation #bh_re zx.meta = #bh_free zx.meta
scoreboard players set #bh_2 zx.meta 2
execute if score #bh_free zx.meta matches 1.. run scoreboard players operation #bh_re zx.meta *= #bh_2 zx.meta

execute if score #bh_re zx.meta matches ..0 run return 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work mr.value set value 0.0
execute store result storage zx:work mr.value double 1 run scoreboard players get #bh_re zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage zx:work mr.value
function manacore:api/mana/add
'''

for rel, txt in F.items():
    p = os.path.join(FN, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, 'w', encoding='utf-8', newline='\n') as f:
        f.write(txt)
    print('wrote', rel)

# 进度文件
JV = {
    'equipment/sword/oath_victory.json': {
        "criteria": {"oath_victory": {"trigger": "consume_item", "conditions": {"item": {"predicates": {"minecraft:custom_data": {"zx": ["oath_victory"]}}}}}},
        "rewards": {"function": "sweetdream:equipment/sword/oath_victory/cast"},
    },
    'equipment/sword/oath_victory_hit.json': {
        "criteria": {"hit": {"trigger": "player_hurt_entity", "conditions": {"damage": {"type": {"tags": [{"expected": True, "id": "minecraft:is_player_attack"}]}}}}},
        "rewards": {"function": "sweetdream:equipment/sword/oath_victory/hit"},
    },
    'equipment/armor/air_step_land.json': {
        "criteria": {"land": {"trigger": "minecraft:fall_from_height", "conditions": {"distance": {"y": {"min": 2.0}}}}},
        "rewards": {"function": "sweetdream:equipment/armor/air_step/land"},
    },
}
for rel, obj in JV.items():
    p = os.path.join(AD, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(obj, f, ensure_ascii=False, indent=4)
        f.write('\n')
    print('wrote adv', rel)

print('total', len(F))
