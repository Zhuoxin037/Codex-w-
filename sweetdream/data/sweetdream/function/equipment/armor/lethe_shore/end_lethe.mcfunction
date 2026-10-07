# ============================================================
# sweetdream:equipment/armor/lethe_shore/end_lethe —— 解除「残念」时的爆发
# ------------------------------------------------------------
# 【谁调用它】passive ⑤(残念 3 秒到期)   【执行者】玩家   【位置】玩家处
# 【文案】"自身解除该状态时, 对自身 3 格内的随机 6 个生物造成相当于自身最大魔力值
#   ×0.06 的伤害(该伤害可以被增幅, 且不会消耗增幅), 之后为受到伤害的生物附加「噬心」。
#   若该被动伤害对附有「噬心」的生物造成了伤害则进入「残念」状态所需攻击次数 -1
#   (最低为 3), 直至 20 秒内未触发该被动。"
# 【套装】"…解除「残念」效果时若自身处于“暗海”时, 则本次被动伤害提高 100%
#   (独立乘区), 之后自身下一次使用关于最大魔力值的技能时技能伤害 +20%(不可叠加)。"
#
# 【★ 顺序: 先判定、后附加噬心 ★】"对附有噬心的生物造成了伤害"必须看**挨打前**
#   的状态 —— 本函数随后会给所有目标附加噬心, 顺序反了就会把"刚被附加的"
#   也算成"原本就有噬心的"。
# 【★ "随机 6 个"要立刻冻结 ★】sort=random 每次求值都重挑(RULES 坑 38):
#   圈目标时一次定死成 zx.lt_hit, 之后判噬心 / 打伤害 / 附加噬心都只认这个标签。
# 【★ "不会消耗增幅"怎么落实 ★】mm_add 在 2026-10-08 改成"打出一次最大魔力值
#   技能就清零"(不再是计时 buff), 所以这里必须挂 zx.mm_hold 声明"本次只读":
#   吃了加成(走 hook_calc 折进 mm 加算池), 但不触发 lib/mm_add/take 清零 ——
#   这正是 lore 那句"(该伤害可以被增幅, 且不会消耗增幅)"。
#   ★ ⑧ 给加成排在 ⑤ 之后, 所以本次被动伤害吃的是"施法前**已有**的加成",
#     不会自己把刚刚写下的 +20% 也算进去。
# 【"独立乘区"怎么落】calc 把三条通道加完之后才抛 damage_calc; 套装的 ×200%
#   是在 calc 之后再乘 r.damage, 所以它作用于"最终伤害", 与三条通道互不干涉
#   = 数学上的独立乘区(和共振/暗海那道最终乘区同一位置)。
# 【为什么阈值用 #need 中转再写回】@s zx.lt_need 可能是"没有分数"(从没被削过),
#   直接 remove 会失败。所以先取"当前值或默认 8", 减完夹到最低 3, 再写回。
# ============================================================

# ① 解除状态(摘标签 -> 速度 modifier 跟着走)
tag @s remove zx.lethe
attribute @s minecraft:movement_speed modifier remove sweetdream:lethe_speed

# ② 圈"3 格内随机 6 个活体"(当场冻结成标签)
tag @e[tag=zx.lt_hit] remove zx.lt_hit
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..3,nbt=!{Health:0.0f},sort=random,limit=6] add zx.lt_hit

# ③ 其中"挨打前就带噬心"的有吗(要在 ⑥ 附加噬心之前判)
scoreboard players set #lt_mark zx.meta 0
execute as @e[tag=zx.lt_hit] if entity @s[tag=zx.status.shixin] run scoreboard players set #lt_mark zx.meta 1

# ④ 套装: 自身在"暗海"内 -> 本次伤害 ×200%(独立乘区)
scoreboard players set #lt_mul zx.meta 100
execute at @s if entity @e[tag=zx.sea,distance=..3,limit=1] run scoreboard players set #lt_mul zx.meta 200

# ⑤ 伤害 = 自身最大魔力 ×0.06, 再按套装倍率放大
#   ★ zx.mm_hold = "只读"标记 ★ lore 写死"(该伤害可以被增幅, 且不会消耗增幅)" ——
#     2026-10-08 起 mm_add 改成"打出一次最大魔力值技能才清零", 不挂这个标记的话
#     这道被动会顺手把套装刚给的那份 +20% 吃掉。
tag @s add zx.mm_hold
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.06}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
tag @s remove zx.mm_hold
execute store result score #d zx.meta run data get storage manacore:out r.damage 100
scoreboard players operation #d zx.meta *= #lt_mul zx.meta
scoreboard players operation #d zx.meta /= #100 zx.meta
execute store result storage manacore:out r.damage double 0.01 run scoreboard players get #d zx.meta
data modify storage zx:in arg set value {target:"@e[tag=zx.lt_hit]",damage:0.0,read:"manacore"}
function sweetdream:api/damage

# ⑥ 为受到伤害的生物附加「噬心」(走公共接口, 自带活体守卫)
function sweetdream:tag/mark {target:"@e[tag=zx.lt_hit]",mark:"shixin"}

# ⑦ 命中过带噬心的 -> 进入残念所需攻击次数 -1(最低 3) + 开 20 秒重置窗口
scoreboard players set #need zx.meta 8
execute if score @s zx.lt_need matches 1.. run scoreboard players operation #need zx.meta = @s zx.lt_need
execute if score #lt_mark zx.meta matches 1 run scoreboard players remove #need zx.meta 1
execute if score #lt_mark zx.meta matches 1 if score #need zx.meta matches ..2 run scoreboard players set #need zx.meta 3
execute if score #lt_mark zx.meta matches 1 run scoreboard players operation @s zx.lt_need = #need zx.meta
execute if score #lt_mark zx.meta matches 1 run scoreboard players operation @s zx.lt_reset = #now manacore.meta
execute if score #lt_mark zx.meta matches 1 run scoreboard players add @s zx.lt_reset 400

# ⑧ 套装: 记下"最大魔力值技能 +20%"(不可叠加 = 已有加成时不覆盖)
#   ★ 2026-10-07 起加成落在**玩家自己的**计分项 zx.mm_add 上,
#     不再是按 uuid 拼的 zx:data wg_bonus —— 所以 set_bonus 不再是宏函数,
#     这里直接普通调用即可(原来那两行抄 uuid 的 data modify 一并删掉)。
execute if score #lt_mul zx.meta matches 200 run function sweetdream:equipment/armor/lethe_shore/set_bonus

# ⑨ 收尾 + 表现
tag @e[tag=zx.lt_hit] remove zx.lt_hit
particle minecraft:soul ~ ~1 ~ 1.6 0.6 1.6 0.03 30 normal
particle minecraft:squid_ink ~ ~0.3 ~ 1.6 0.3 1.6 0.01 14 normal
playsound minecraft:block.soul_soil.break player @a ~ ~ ~ 0.8 0.6
