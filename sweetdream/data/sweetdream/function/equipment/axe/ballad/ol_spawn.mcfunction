# ============================================================
# sweetdream:equipment/axe/ballad/ol_spawn —— 超限·歌谣: 召唤（9-X）个「音符」
# ------------------------------------------------------------
# 【谁调用它】hit ④.6(奏响之后, 用 #bd_x = **奏响时**的层数)
# 【执行者】施法者   【位置】他身上
# 【设计原文】"然后召唤（9-X）个「音符」，每个「音符」都会先锁定一个不同的生物，
#   1 秒后向锁定到该生物的位置发射出去并对路径上的生物造成相当于自身基础攻击力
#   x X 的真实伤害，在到达该生物原先的位置后自毁。"
# 【★ 个数 = 9-X, 伤害倍率 = X ★】X 越大越少但越疼(X=8 -> 1 个 ×8; X=1 -> 8 个 ×1)。
# 【★ "锁定一个不同的生物" = X 格内最近的 n 个(各不重复) ★】用 sort=nearest 一次性圈,
#   天然不重复。周围不够 n 个就只召唤那么多。
# 【★ 音符本体是 marker, 坐标存两份 ★】
#   marker **召唤在目标生物的位置**(= 终点), NBT 里记**起点**(施法者位置 sx/sy/sz)。
#   结算时从起点朝 marker 铺球 —— 这样"1 秒后发射"不需要反查玩家(反查 = 10ms/次)。
# ============================================================

# ⓪ 不是超限版 -> 没有音符
execute unless data storage zx:work bdly{ol:1} run return 0

# ① 个数 n = 9 - X
scoreboard players set #bdn zx.meta 9
scoreboard players operation #bdn zx.meta -= #bd_x zx.meta
execute if score #bdn zx.meta matches ..0 run return 0

# ② 每个音符的伤害 = 基础攻击力 × X
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",attack_mul:1.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.attack_mul double 1 run scoreboard players get #bd_x zx.meta
function manacore:api/damage/calc
scoreboard players set #bdnd zx.meta 1
execute store result score #bdnd zx.meta run data get storage manacore:out r.damage
execute if score #bdnd zx.meta matches ..0 run scoreboard players set #bdnd zx.meta 1

# ③ 音符模板: 伤害(整点) + 起点坐标 + 施法者 UUID
data modify storage zx:work nt set value {dmg:0,sx:0.0,sy:0.0,sz:0.0,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work nt.dmg int 1 run scoreboard players get #bdnd zx.meta
data modify storage zx:work nt.sx set from entity @s Pos[0]
data modify storage zx:work nt.sy set from entity @s Pos[1]
data modify storage zx:work nt.sz set from entity @s Pos[2]
data modify storage zx:work nt.u0 set from entity @s UUID[0]
data modify storage zx:work nt.u1 set from entity @s UUID[1]
data modify storage zx:work nt.u2 set from entity @s UUID[2]
data modify storage zx:work nt.u3 set from entity @s UUID[3]

# ④ 圈 n 个不同的生物(X 格内最近)
tag @e[tag=zx.bd_lock] remove zx.bd_lock
execute store result storage zx:work bdly.n int 1 run scoreboard players get #bdn zx.meta
execute store result storage zx:work bdly.x int 1 run scoreboard players get #bd_x zx.meta
execute at @s run function sweetdream:equipment/axe/ballad/ol_pick with storage zx:work bdly

# ⑤ 在每只被锁定生物的位置召唤一个音符
execute at @e[tag=zx.bd_lock] run function sweetdream:equipment/axe/ballad/ol_note_spawn with storage zx:work nt
tag @e[tag=zx.bd_lock] remove zx.bd_lock
