# ============================================================
# sweetdream:equipment/axe/azure_star/dmg2 —— 苍蓝星 · 主动第 2 段结算(0.35 秒后)
# ------------------------------------------------------------
# 【谁调用它】azure_star/tick_step(core/tick 到点)   【执行者】施法者本人
# 【技能原文】"…之后对**其** 2 格内的生物造成 最大魔力值 ×0.1 的伤害。"
# 【圆心 = 第 1 段打中的那一只】锚点标签 zx.as_t 一直挂在它身上 -> `execute at <那只>`。
#   ★ 它若已被第 1 段打死/走丢, 标签不在 -> 整段跳过(见 ①)。
# 【★ 为什么用 `unless ... run return 0` 而不是让它自然跳过 ★】
#   后面 ③ 要清 zx.as_d, 提前 return 就漏了 —— 所以这里在 return 前先把 zx.as_d 清 0,
#   让 core/tick 的 `zx.as_d=1..` 天然停摆。
# 【★ 入参要整体重写一遍 ★】段① 的 with_from 会逐目标走 internal/damage/one,
#   而 one 会动 zx:work a(全包共用节点)。不重写的话这里可能拿着被改过的类型/归属去打。
# ============================================================

# ① 锚点还在吗?
execute unless entity @e[tag=zx.as_t,distance=0..,limit=1] run scoreboard players set @s zx.as_d 0
execute unless entity @e[tag=zx.as_t,distance=0..,limit=1] run return 0

# ② 算第 2 段的伤害(同样吃"被动翻倍" -> 看 zx.as_db)
function sweetdream:equipment/axe/azure_star/recalc2

# ③ 打第 2 段: 以那一只为圆心, 2 格内全部生物 ×0.1
data modify storage zx:work a.num set from storage zx:work asz.dmg2
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..2]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
execute at @e[tag=zx.as_t,distance=0..,limit=1] run function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 表现(第 2 段)
execute at @e[tag=zx.as_t,distance=0..,limit=1] run particle minecraft:dust{color:[0.2,0.5,1.0],scale:1.2} ~ ~1 ~ 0.6 0.6 0.6 0.05 24 normal
execute at @e[tag=zx.as_t,distance=0..,limit=1] run particle minecraft:end_rod ~ ~1 ~ 0.4 0.4 0.4 0.1 16 normal

# ⑤ 收尾: 摘锚点 + 清存根 (zx.as_d 由 tick_step 统一清 0)
tag @e[tag=zx.as_t,distance=0..] remove zx.as_t
scoreboard players set @s zx.as_db 0
