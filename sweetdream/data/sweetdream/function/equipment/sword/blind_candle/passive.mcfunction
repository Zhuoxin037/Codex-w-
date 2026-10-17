# ============================================================
# sweetdream:equipment/sword/blind_candle/passive —— 盲烛被动(5 秒最多一次)
# ------------------------------------------------------------
# 【谁调用它】hit_go ②   【执行者】动手的玩家   【条件】zx.bcd_v(目标)带「夜火」
# 【结算】目标 2.5 格内**随机一个其他生物**吃一发; 它自己也带夜火就 ×0.1, 否则 ×0.06。
# 【★ 节流记在玩家身上 ★】原文是"**该效果** 5 秒内最多触发一次"(不是"对同一个生物"),
#   ⇒ 换着怪打也只有 5 秒一次。这与重溟那种"对同一生物 10 秒一次"正好相反。
# 【★ add 0 必须有 ★】计分项"没有分数"时 `if score` 判不成立 ⇒ 第一次永远触发不了。
# 【★ 先选目标再扣节流 ★】一个"其他生物"都没有的时候整段不成立, 不该白白吃掉 5 秒。
# 【★ 两只候选倍率都预先算好 ★】max_mana_mul 是 double, 选不了"二选一"的分支,
#   所以按 0.06 / 0.1 各算一次(calc 只读面板、没有副作用), 再按标签取需要的那个。
# ============================================================

# ① 目标 2.5 格内随机一个**其他**生物(排除目标自己)
tag @e[tag=zx.bcd_pick,distance=0..] remove zx.bcd_pick
execute at @e[tag=zx.bcd_v,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=0.01..2.5,tag=!zx.bcd_v,sort=random,limit=1] add zx.bcd_pick
execute unless entity @e[tag=zx.bcd_pick,distance=0..,limit=1] run return 0

# ② 5 秒节流(记玩家; 通过后才扣)
scoreboard players add @s zx.bcd_pd 0
execute if score @s zx.bcd_pd > #now manacore.meta run tag @e[tag=zx.bcd_pick,distance=0..] remove zx.bcd_pick
execute if score @s zx.bcd_pd > #now manacore.meta run return 0
scoreboard players operation @s zx.bcd_pd = #now manacore.meta
scoreboard players add @s zx.bcd_pd 100

# ③ 被波及的那只也带「夜火」吗?
scoreboard players set #bcd_ye2 zx.meta 0
execute as @e[tag=zx.bcd_pick,distance=0..,limit=1] if entity @s[tag=zx.status.yehuo] run scoreboard players set #bcd_ye2 zx.meta 1

# ④ 两个候选倍率各算一次
#   ★★ 先重取 uuid ★★ damage/calc 是按 uuid 查面板里"最大魔力值"的, 而
#   zx:data self.uuid 是全包共用的"最后一次结果"; 平A链本身不经过 lib/uuid,
#   直接读可能读到**另一个玩家**的 uuid ⇒ 伤害按别人的魔力算(静默、零日志)。
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.06,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work bcdp.dmg0 set from storage manacore:out r.damage

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work bcdp.dmg1 set from storage manacore:out r.damage

# ⑤ 按条件选倍率
data modify storage zx:work bcdp.dmg set from storage zx:work bcdp.dmg0
execute if score #bcd_ye2 zx.meta matches 1 run data modify storage zx:work bcdp.dmg set from storage zx:work bcdp.dmg1

# ⑥ 打它(执行者仍是玩家 -> 击杀归属正确)
data modify storage zx:in arg set value {target:"@e[tag=zx.bcd_pick,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work bcdp.dmg
execute at @s run function sweetdream:api/damage

# ⑦ 表现
execute at @e[tag=zx.bcd_pick,distance=0..,limit=1] run particle minecraft:small_flame ~ ~1 ~ 0.3 0.4 0.3 0.02 12 normal
execute at @e[tag=zx.bcd_pick,distance=0..,limit=1] run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.5 1.6
