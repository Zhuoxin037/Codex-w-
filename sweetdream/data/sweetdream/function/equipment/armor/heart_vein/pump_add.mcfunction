# ============================================================
# sweetdream:equipment/armor/heart_vein/pump_add —— 泵动期间**再次**被消耗噬心
# ------------------------------------------------------------
# 【执行者】已带「泵动」的那只生物   【宏参数】zx:work hv {by}
# 【文案(逐字)】"在此期间若其再次被消耗「噬心」则使「泵动」持续时间叠加且使其
#   立即受到一次相当于其最大生命值 ×0.08 的伤害并使自身恢复相当于自身最大
#   魔力值 1% 的魔力值。"
# 【★ "叠加"按 +5 秒、封顶 12 秒（240 刻）★】原文只说"叠加"没给量, 取与首次
#   等长的 5 秒（设计稿口径）; "最多 12 秒"是硬上限, 超过就夹到 240 刻。
# 【★ 归属要刷新 ★】这次消耗者可能换人（另一件装备 / 另一个玩家消耗了噬心）。
# ============================================================

# ① 叠加 5 秒, 封顶 12 秒
scoreboard players add @s zx.hv_t 100
execute if score @s zx.hv_t matches 241.. run scoreboard players set @s zx.hv_t 240

# ② 归属刷新为本次的消耗者
$execute as $(by) store result score #hv_u0 zx.meta run scoreboard players get @s manacore.u0
$execute as $(by) store result score #hv_u1 zx.meta run scoreboard players get @s manacore.u1
$execute as $(by) store result score #hv_u2 zx.meta run scoreboard players get @s manacore.u2
$execute as $(by) store result score #hv_u3 zx.meta run scoreboard players get @s manacore.u3
scoreboard players operation @s zx.hv_u0 = #hv_u0 zx.meta
scoreboard players operation @s zx.hv_u1 = #hv_u1 zx.meta
scoreboard players operation @s zx.hv_u2 = #hv_u2 zx.meta
scoreboard players operation @s zx.hv_u3 = #hv_u3 zx.meta

# ③ 立即结算一次 ×0.08（伤害归属 = 上面那位）
function sweetdream:equipment/armor/heart_vein/owner
data modify storage zx:work hv.mul set value 80
function sweetdream:equipment/armor/heart_vein/pump_dmg with storage zx:work hv

# ④ 自身恢复相当于自身最大魔力值 1% 的魔力值（@s 是生物 ⇒ 换成玩家身份）
$execute as $(by) run function sweetdream:equipment/armor/heart_vein/regen

# ⑤ 表现
execute at @s run particle minecraft:dust{color:[0.95,0.25,0.15],scale:1.6} ~ ~1 ~ 0.4 0.6 0.4 0.02 20 normal
execute at @s run playsound minecraft:entity.warden.heartbeat player @a ~ ~ ~ 0.7 1.0
