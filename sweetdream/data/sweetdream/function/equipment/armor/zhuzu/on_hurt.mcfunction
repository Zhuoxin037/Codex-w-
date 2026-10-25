# ============================================================
# sweetdream:equipment/armor/zhuzu/on_hurt —— 驻足（铁靴 · 被动）
# ------------------------------------------------------------
# 【触发】玩家受伤（advancement entity_hurt_player）
# 【机制】受伤后开始等 1.5 秒：这 1.5 秒内一直没动 → 脚下展开半径 3 的功能领域，
#         持续 10 秒（领域内敌人每秒 5 点固定伤害 + 缓慢Ⅰ）。
#         期间自身移动即收领域（不到 10 秒也收），落地一次后 30 秒冷却。
# 【状态】zx.zz_w = 1 表示"正在等这 1.5 秒"；zx.zz_t = 剩余刻；
#         zx.zz_on = 1 表示"领域在场上"；zx.zz_cd = 冷却到期刻。
# 【★ 为什么 30 秒冷却一过就无条件清 zx.zz_on】领域最长 10 秒，冷却 30 秒 ——
#   冷却已经过去说明场上那一个早该消失了。这样即使 marker 被 /kill 掉、
#   或被区块卸载没收，状态也能自愈，不会把玩家永久卡在"领域在场上"。
# ============================================================
advancement revoke @s only sweetdream:equipment/armor/zhuzu_hurt

execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["zhuzu"]}] run return 0

scoreboard players add @s zx.zz_cd 0
execute if score @s zx.zz_cd <= #now manacore.meta run scoreboard players set @s zx.zz_on 0
execute if score @s zx.zz_cd > #now manacore.meta run return 0

# 已在等待 / 领域已在场上 → 不重复开
execute if score @s zx.zz_w matches 1 run return 0
execute if score @s zx.zz_on matches 1 run return 0

scoreboard players set @s zx.zz_w 1
scoreboard players set @s zx.zz_t 30
