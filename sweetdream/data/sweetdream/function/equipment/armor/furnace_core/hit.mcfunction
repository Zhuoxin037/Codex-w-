# ============================================================
# sweetdream:equipment/armor/furnace_core/hit —— 打到燃烧中的生物: 攒一层燃灰
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/furnace_core_hit
#   (player_hurt_entity + 伤害类型 is_player_attack + 受害者 is_on_fire)
# 【文案】自身每攻击一次处于燃烧状态的生物则积攒一层「燃灰」（最大为 10 层）。
# 【为什么限定 is_player_attack】不加这条的话, 技能伤害 / 法球 / 荆棘反弹
#   都会来攒层 —— 文案说的是"攻击", 只认平 A(规则 30)。
# 【★ 第一行必须是 revoke ★】一次性进度, 不撤就只有第一次会触发;
#   而且它必须排在 return 之前(规则 27)。
# 【★ 自己判穿着 ★】本函数由进度以玩家身份调用, 但"打到燃烧的怪"和"穿没穿炉心"
#   是两件事 —— 不判的话没穿也会攒层(静默 bug)。
# 【上限 10】到顶就夹住, 不再往上加(夹而不是"不加" —— 万一被别处推过头,
#   夹一下能自己回到正常区间)。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/furnace_core_hit

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["furnace_core"]}] run return 0

scoreboard players add @s zx.fc_ash 0
scoreboard players add @s zx.fc_ash 1
execute if score @s zx.fc_ash matches 10.. run scoreboard players set @s zx.fc_ash 10

# 表现: 一点火星(轻量 —— 这条每秒可能触发好几次)
execute at @s run particle minecraft:flame ~ ~1 ~ 0.35 0.5 0.35 0.01 6 normal
