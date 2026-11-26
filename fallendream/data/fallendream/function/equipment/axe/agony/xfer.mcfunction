# ============================================================
# fallendream:equipment/axe/agony/xfer —— 苦痛·超限：把效果转移到新目标
# ------------------------------------------------------------
# 【宏参数】zx:work agq {u:"<新目标 UUID>", my:"<释放者 UUID>"}
# 【执行者】玩家（释放者）
# 【文案】…在 4 秒内攻击一个其他生物则可以把本武器技能效果转移到该生物上，
#   且持续时间 +1 秒，每个技能期间只能使用一次。
# 【★ "其他生物"判据 ★】目标身上还带着 zx.ag_t ⇒ 它已经是某一把苦痛的锁，
#   不是"其他生物"，直接放弃这次转移（用 `as` 是因为裸 UUID 后面不能接选择器参数）。
# 【★ 旧锁怎么找 ★】按 `tag=zx.ag_t` 扫全场，再用 `data.zx.ag{uuid:"<我>"}` 认领。
#   玩家身上存不了 UUID，只能反过来拿 uuid 去匹配 —— 这条用宏展开成字面量。
# ============================================================

# ① 打的是当前锁着的那一只 ⇒ 不算"其他生物"
#   ★ 判据用标签而不是 data.zx.ag：锁到期后那份 NBT 会留在生物身上（既有行为），
#     拿它当判据会把"曾经被锁过"的生物永久排除在转移目标之外。
$execute as $(u) if entity @s[tag=zx.ag_t] run return 0

# ② 找旧锁并把它的剩余时长 / 释放者身份取出来
scoreboard players set #ag_xe zx.meta 0
data remove storage zx:work agid
$execute as @e[tag=zx.ag_t] if data entity @s data.zx.ag{uuid:"$(my)"} run function fallendream:equipment/axe/agony/xfer_drop
execute unless score #ag_xe zx.meta matches 1.. run return 0

# ③ 落到新目标身上（剩余时长 +1 秒；身份整份继承 ⇒ 超限标记也跟着走）
$execute unless entity $(u) run return 0
$data modify entity $(u) data.zx.ag set from storage zx:work agid
$execute store result score $(u) zx.ag_end run scoreboard players get #ag_xe zx.meta
$scoreboard players add $(u) zx.ag_end 20
$tag $(u) add zx.ag_t

# ④ 收尾：本轮机会用掉、窗口关掉、玩家侧到期刻也跟着 +1 秒
scoreboard players set @s zx.ag_xn 1
scoreboard players set @s zx.ag_xfer 0
scoreboard players add @s zx.ag_live 20

tellraw @s {"text":"苦痛已转移。","color":"light_purple"}
$execute as $(u) at @s run particle minecraft:dust{color:[0.45,0.1,0.55],scale:1.5} ~ ~1 ~ 0.7 0.7 0.7 0.04 26 normal
$execute as $(u) at @s run playsound minecraft:entity.warden.heartbeat player @a ~ ~ ~ 0.9 1.1
