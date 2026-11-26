# ============================================================
# fallendream:equipment/staff/intone/again_one —— 单个追随者: 刷时长 + 再唱一次
# ------------------------------------------------------------
# 【执行者】追随者(marker)
# 【判据】反查主人 lib/u_by → 主人身上带 zx.in_owner(= 刚施法的那个玩家)
# 【★ 先刷时长再 pulse ★】pulse 末尾可能把追随者收回(余响的 recall_check),
#   所以"刷新持续时间"必须排在 pulse 之前 —— 否则刷了个已经被 kill 的实体。
# ============================================================

tag @a[tag=zx.ub] remove zx.ub
data modify storage zx:work ub set from entity @s data
function fallendream:lib/u_by
execute unless entity @a[tag=zx.ub,tag=zx.in_owner] run return 0

# 刷新持续时间: 平时 200 刻 / 醒梦 300 刻(与 profession/singer/create 同源)
scoreboard players set @s zx.j_life 200
execute if entity @a[tag=zx.ub,tag=zx.in_owner,scores={zx.j_aw=1}] run scoreboard players set @s zx.j_life 300
# 摘掉"到点返回"的旗子: 本来只剩几刻、已经被标了 return 的追随者, 刷新时长之后就该继续唱
tag @s remove zx.j_return

execute at @s run function fallendream:profession/singer/pulse
