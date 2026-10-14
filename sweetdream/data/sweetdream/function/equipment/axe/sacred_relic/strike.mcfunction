# ============================================================
# sweetdream:equipment/axe/sacred_relic/strike —— 一颗「遗骸」的一跳
# ------------------------------------------------------------
# 【谁调用它】sacred_relic/second: execute as @e[tag=zx.sr_near] at @s run function ...
# 【执行者】**遗骸**(marker)  【位置】遗骸处
# 【一跳做四件事】
#   ① 锁定半径 = 3 + 「流火」+1; 随机目标数 = 1 + 「渊海」+2
#   ② 在半径内随机挑 1 / 3 只互不重复的生物(挑不到就跳过)
#   ③ 伤害 = 释放者最大魔力 ×0.1 ×(1 + 流火 0.3 + 夜火 0.8)
#   ④ 额外: 「噬心」追加死者最大生命 5% 真伤 / 「白昼梦」追加 0.3 秒时停
# 【★ 释放者是谁 ★】本函数 @s 是遗骸, 拿不到释放者 —— 靠 second 预先钉的
#   zx.sr_caster 标签反查, 在开头现取一次 uuid(算面板 + 归因都要)。
# 【★ 为什么每颗遗骸都重取一次 ★】一圈遗骸是逐个结算的, 上一次 with_from 可能碰过
#   zx:data self —— 每颗都在这里重取, 才不会被上一颗的残留带偏。
# 【随机目标】pick 宏只接收整数 range / limit。流火改半径, 渊海改目标数;
#   sort=random + limit 是无放回选择, 同一个目标一跳不会被选三次。
# ============================================================

# 现取释放者身份(必须: 下面 calc 用 zx:data self.uuid)
execute as @a[tag=zx.sr_caster,limit=1] run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ① 锁定半径
scoreboard players set #sr_r zx.meta 3
execute if data entity @s data.zx.lh run scoreboard players add #sr_r zx.meta 1
scoreboard players set #sr_n zx.meta 1
execute if data entity @s data.zx.yh run scoreboard players add #sr_n zx.meta 2

# ② 半径内随机挑 1 / 3 只
tag @e[tag=zx.sr_t] remove zx.sr_t
data modify storage zx:sr pick set value {range:3,limit:1}
execute store result storage zx:sr pick.range int 1 run scoreboard players get #sr_r zx.meta
execute store result storage zx:sr pick.limit int 1 run scoreboard players get #sr_n zx.meta
function sweetdream:equipment/axe/sacred_relic/pick with storage zx:sr pick
execute unless entity @e[tag=zx.sr_t,distance=0..,limit=1] run return 0

# ③ 伤害: 释放者最大魔力 ×0.1, 再按标签乘独立乘区(千分比: 100 = 不加成)
scoreboard players set #sr_m zx.meta 100
execute if data entity @s data.zx.lh run scoreboard players add #sr_m zx.meta 30
execute if data entity @s data.zx.ye run scoreboard players add #sr_m zx.meta 80

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1,independent_multiplier:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.independent_multiplier double 0.01 run scoreboard players get #sr_m zx.meta
function manacore:api/damage/calc

# ④ 打出去(带**释放者归属**; 这里 @s 是遗骸, 所以不能走 sweetdream:api/damage,
#    改用 internal/damage/with_from + 手工填 u0..u3 —— 同 fissure/field_tick 的口径)
data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[tag=zx.sr_t,distance=0..]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set value 0
data modify storage zx:work a.u1 set value 0
data modify storage zx:work a.u2 set value 0
data modify storage zx:work a.u3 set value 0
execute as @a[tag=zx.sr_caster,limit=1] run data modify storage zx:work a.u0 set from entity @s UUID[0]
execute as @a[tag=zx.sr_caster,limit=1] run data modify storage zx:work a.u1 set from entity @s UUID[1]
execute as @a[tag=zx.sr_caster,limit=1] run data modify storage zx:work a.u2 set from entity @s UUID[2]
execute as @a[tag=zx.sr_caster,limit=1] run data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# 表现: 目标身上冒一缕骨火
execute at @e[tag=zx.sr_t,distance=0..,limit=1] run particle minecraft:soul ~ ~0.5 ~ 0.3 0.3 0.3 0.02 6 normal

# ⑤ 额外两段(噬心真伤 / 白昼梦时停)
execute if data entity @s data.zx.sx run function sweetdream:equipment/axe/sacred_relic/shixin
execute if data entity @s data.zx.dm run function sweetdream:equipment/axe/sacred_relic/timestop

# 收尾: 清本轮随机目标标记
tag @e[tag=zx.sr_t] remove zx.sr_t
# 遗骸模型共鸣，只作用于本 marker 的显示载体。
function sweetdream:equipment/axe/sacred_relic/visual/remnant/pulse
