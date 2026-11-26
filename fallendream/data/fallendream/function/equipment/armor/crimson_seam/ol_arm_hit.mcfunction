# ============================================================
# fallendream:equipment/armor/crimson_seam/ol_arm_hit —— 超限·绯缝：消耗目标「噬心」，挂"下一次"
# ------------------------------------------------------------
# 【宏参数】context {vx_uuid}（lib/victim 的"刚被打的那一只"）
# 【执行者】动手的那个玩家
# 【★ 消耗走统一入口 lib/mark_consume ★】会照常触发永恒回收、回潮扣等"消耗标签"被动;
#   与 last_breath / backlight 同口径。mc.done=0 表示被永恒补回、不算真消耗 ⇒ 不挂。
# ============================================================

$execute unless entity $(vx_uuid) run return 0

# ① 它带着「噬心」吗（不带的连消耗都不做）
$execute as $(vx_uuid) unless entity @s[tag=zx.status.shixin] run return 0
$execute unless entity $(vx_uuid) run return 0

# ② 消耗（by = 自己）
$data modify storage zx:work a set value {target:"$(vx_uuid)",mark:"shixin",by:"@s",src:"equip"}
function fallendream:lib/mark_consume
$tag $(vx_uuid) remove zx.victim
execute unless data storage zx:work mc{ok:1b,done:0b} run return 0

# ③ 挂"下一次平A追加真伤" + 6 秒节流
scoreboard players set @s zx.cr_ol_next 1

execute at @s run particle minecraft:crit ~ ~1 ~ 0.3 0.4 0.3 0.05 8 normal
