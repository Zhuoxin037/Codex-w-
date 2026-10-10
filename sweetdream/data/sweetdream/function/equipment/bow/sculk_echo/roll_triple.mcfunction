# ============================================================
# sweetdream:equipment/bow/sculk_echo/roll_triple —— 悲鸣三倍判定(命中范围伤用)
# ------------------------------------------------------------
# 【谁调它】fire ①.5; #se_cry = 本发悲鸣值(1..50), #se_dmg = 已算好的伤害(×100 定点)
# 【判定】#rnd % 除数, 若 < 悲鸣值则触发。
#   ★ 除数 = **100**(基础: 每点 1%) / **200**(超限: 每点 0.5%, 满 100 点仍是 50%)。
#     读 fire ①.5 灌好的 `#se_ol` —— 它是"这一发"的属性, 不是"这一只"的。
#   ⚠️ 别写成"概率减半所以悲鸣值 ÷2": 悲鸣值还要用于提示/上限, 除数改一处就够。
# 【触发后果】本次伤害 ×3, 并清除**射手**的全部悲鸣(zx.se_cry = 0)。
# 【射手怎么找】由 fire 灌好的 u0..u3 反查(玩家 UUID 的四个整数)。
#   ⚠️ 这里用 @a 遍历找匹配的 uuid; 找不到(射手离线)就只翻倍伤害, 不清悲鸣。
# 【为什么用 zx.cfg_uuid 临时比对而不是宏】宏要拿 4 个 int 拼, 反而绕;
#   这套"用 u0..u3 反查玩家"在包里已有先例(internal/damage 的 by 选择器)。
# ============================================================

function sweetdream:lib/rnd
scoreboard players set #se_try zx.meta 0
scoreboard players operation #se_try zx.meta = #rnd zx.meta
scoreboard players set #se_div zx.meta 100
execute if score #se_ol zx.meta matches 1 run scoreboard players set #se_div zx.meta 200
scoreboard players operation #se_try zx.meta %= #se_div zx.meta
# 未触发就收工
execute unless score #se_try zx.meta < #se_cry zx.meta run return 0

# 触发: 伤害 ×3
scoreboard players set #3 zx.meta 3
scoreboard players operation #se_dmg zx.meta *= #3 zx.meta

# 清除射手的悲鸣: 用 u0..u3 反查(写进一个临时节点, 用 Uuid 数据比对)
data modify storage zx:work se_clear set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work se_clear.u0 set from storage zx:work se.snap.u0
data modify storage zx:work se_clear.u1 set from storage zx:work se.snap.u1
data modify storage zx:work se_clear.u2 set from storage zx:work se.snap.u2
data modify storage zx:work se_clear.u3 set from storage zx:work se.snap.u3
function sweetdream:equipment/bow/sculk_echo/clear_cry with storage zx:work se_clear

execute at @s run playsound minecraft:block.sculk_shrieker.shriek player @a ~ ~ ~ 1.0 0.8
