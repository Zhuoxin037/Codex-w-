# ============================================================
# sweetdream:equipment/sword/thunder_wedge/ol_tick —— 超限·雷楔: 每秒一跳的持续伤害
# ------------------------------------------------------------
# 【执行者】雷楔 marker   【位置】marker(调用方 lib/second 已经 `at @s`)
# 【设计原文】
#   "在「雷楔」范围内的生物被闪电命中后的 3 秒内每秒都会受到一次相当于释放者
#    当前魔力值 x0.07 的伤害。若在这期间再次被雷电命中则强化为在 5 秒内每秒都会
#    受到一次相当于释放着最大魔力值 x0.08 的伤害。"
# 【★ 数值每秒只算一次 ★】"当前魔力"在同一秒里就该是同一个快照; 每只目标各读一次
#   manacore 只是把同一个数字读 N 遍。算一次、这一秒所有目标共用。
# 【★ 计时不在这里减 ★】DoT 的秒数由 lib/second 的全局扫描每秒 -1(见 ol_dot_down):
#   雷楔只活 10 秒, 而 5 秒档的 DoT 完全可能比它活得久 —— 挂在 marker 上减,
#   marker 一死那些分数就永远不再推进(生物身上会永久带着"每秒掉血"的标记)。
# 【★ 只在有目标时才反查施法者 ★】平时(`return 0` 那行)只有一次空选择器;
#   lib/find_by 要扫 4 个整数 + 全维度 @a, 不值得每秒白跑。
# ============================================================

# ① 范围内没有带 DoT 的生物 -> 走人
execute unless entity @e[type=!#sweetdream:no_damage,scores={zx.twg_dot=1..},distance=..12] run return 0

# ② 反查施法者(marker 上只有 UUID 的四个整数; uuid 文本在 data.zx.uu 里, 那是给术阵用的)
data modify storage zx:work fb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work fb.u0 set from entity @s data.zx.u[0]
data modify storage zx:work fb.u1 set from entity @s data.zx.u[1]
data modify storage zx:work fb.u2 set from entity @s data.zx.u[2]
data modify storage zx:work fb.u3 set from entity @s data.zx.u[3]
function sweetdream:lib/find_by with storage zx:work fb
execute unless entity @a[tag=zx.mc_by,limit=1] run return 0

# ③ 施法者的 uuid 文本(manacore:api/mana/get 只认字符串形式的 uuid)
execute as @a[tag=zx.mc_by,limit=1] run function sweetdream:lib/uuid

# ④ 当前 / 最大魔力
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get

# ⑤ 两档数值: 当前魔力 ×0.07 / 最大魔力 ×0.08
#   ★ 定点算法照抄 gousi/land_hit ★ r.value 是 double, 先 ×10 取"十分位整数",
#     再 ×7 ÷1000 = ×0.07 —— 直接 ÷100 会把 143 变成 1, 精度全丢。
data modify storage zx:work twgdot set value {c:0.0,x:0.0,u0:0,u1:0,u2:0,u3:0}

scoreboard players set #twg_c zx.meta 0
execute store result score #twg_c zx.meta run data get storage manacore:out r.value 10
scoreboard players set #twg_t zx.meta 0
scoreboard players operation #twg_t zx.meta = #twg_c zx.meta
scoreboard players set #twg_k zx.meta 7
scoreboard players operation #twg_t zx.meta *= #twg_k zx.meta
scoreboard players operation #twg_t zx.meta /= #1000 zx.meta
execute store result storage zx:work twgdot.c double 1 run scoreboard players get #twg_t zx.meta

scoreboard players set #twg_x zx.meta 0
execute store result score #twg_x zx.meta run data get storage manacore:out r.max 10
scoreboard players set #twg_t zx.meta 0
scoreboard players operation #twg_t zx.meta = #twg_x zx.meta
scoreboard players set #twg_k zx.meta 8
scoreboard players operation #twg_t zx.meta *= #twg_k zx.meta
scoreboard players operation #twg_t zx.meta /= #1000 zx.meta
execute store result storage zx:work twgdot.x double 1 run scoreboard players get #twg_t zx.meta

# ⑥ 归属: 施法者 UUID 四个整数(从 marker 的 NBT 摊开)
data modify storage zx:work twgdot.u0 set from entity @s data.zx.u[0]
data modify storage zx:work twgdot.u1 set from entity @s data.zx.u[1]
data modify storage zx:work twgdot.u2 set from entity @s data.zx.u[2]
data modify storage zx:work twgdot.u3 set from entity @s data.zx.u[3]

# ⑦ 逐只结算这一秒
execute as @e[type=!#sweetdream:no_damage,scores={zx.twg_dot=1..},distance=..12] at @s run function sweetdream:equipment/sword/thunder_wedge/ol_dot_one

# ⑧ 反查标签只活这一个函数(下次 find_by 会先清场, 这里主动清更干净)
tag @a remove zx.mc_by
