# ============================================================
# sweetdream:equipment/armor/profile/hit_melee —— 剖面: **平A**打中带噬心的目标也计数
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/profile_hit
#   （player_hurt_entity + damage.type.tags 含 minecraft:is_player_attack）
# 【执行者】玩家
# 【★ 为什么还要单独一条进度 ★】internal/damage/one 只覆盖**本包**伤害（技能 / 真伤）。
#   原版平A 不经过它 ⇒ "对带噬心的生物造成 3 次伤害"会漏掉最普通的砍三刀。
#   这条进度把平A 那一路补上, 两条路共用同一个 profile/count。
# 【★ 同刻去重交给 count 自己 ★】平A 常常同时触发"平A附加伤害"（本包 damage）,
#   那两路会在同一刻打到同一只 ⇒ count 里的 zx.pf_hl 只记一次。
# 【★ 自撤销型进度 ★】首行必须 revoke 自己（check 的 selfrev 规则 + lib/rearm 对账）。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/profile_hit

# ① 没穿剖面就没这事（护腿）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["profile"]}] run return 0

# ② 刚才这一下打的是哪一只
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,limit=1] run return 0

# ③ 只有带「噬心」的那只才计数
execute as @e[tag=zx.victim,limit=1] unless entity @s[tag=zx.status.shixin] run return 0

# ④ 施法者 UUID（4 个整数, 供 count 里的 lib/u_by 用）
data modify storage zx:work pf set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work pf.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work pf.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work pf.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work pf.u3 int 1 run data get entity @s UUID[3]

execute as @e[tag=zx.victim,limit=1] run function sweetdream:equipment/armor/profile/count with storage zx:work pf
tag @e[tag=zx.victim] remove zx.victim
