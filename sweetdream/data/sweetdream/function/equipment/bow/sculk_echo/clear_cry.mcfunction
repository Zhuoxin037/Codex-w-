# ============================================================
# sweetdream:equipment/bow/sculk_echo/clear_cry —— 按 u0..u3 反查射手清空悲鸣(宏 {u0,u1,u2,u3})
# ------------------------------------------------------------
# 【谁调它】roll_triple 触发三倍之后: 清除射手的全部「悲鸣」(zx.se_cry = 0)。
# 【执行者】不限(只是反查玩家)
# 【反查写法】和 internal/damage/deal 同一套: UUID 的四个整数拼 nbt 选择器。
#   选不到人(射手离线/退出)就什么都不做 —— 不报错。
# ============================================================

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players set @s zx.se_cry 0
