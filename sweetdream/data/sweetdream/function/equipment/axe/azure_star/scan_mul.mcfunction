# ============================================================
# sweetdream:equipment/axe/azure_star/scan_mul —— 面板: 苍蓝星「被动翻倍」现形
# ------------------------------------------------------------
# @panel: smul_mm
# 【执行者】玩家本人(@s)
# 【出参】仅当"手里是苍蓝星 且 攒着被动翻倍(zx.as_x2=1)"时, 往**加算池** zx:work add
#   的 mm 通道写 100; 由 lib/skill_mul/padd_apply 统一折进 pl.smul_mm(面板上
#   "最大魔力值技能倍率 ×"那一行)。
# 【★ 结算不在这里 ★】真正的 ×2 在 azure_star/recalc(把 manacore:in arg.max_mana_mul
#   ×2, 见 double)。面板第一原则是"显示的必须是真实生效的" —— 攒着翻倍时面板就该
#   显示 ×2, 不然玩家看不到它(玩家 2026-10-07: "我希望翻倍后可以在观测镜上显示出来")。
#   套路和共振 resonance/scan_mul、漫步 styx_walk/scan_mul 完全一样。
# 【为什么只写 mm】文案是"该武器伤害倍率", 而本武器两段都以最大魔力值结算 ->
#   就是 max_mana_mul 这条通道(不挑攻击力/当前魔力那两条)。
# 【判据必须和 recalc 一致】手里是苍蓝星 + zx.as_x2=1, 缺一条就收工(面板保持 ×1)。
# 【★ 不能在这里清 zx.as_x2 ★】scan_mul 是**只读面板**用的(每帧刷新都会跑),
#   清标记会让"看着面板翻倍就没了"。消费只在 recalc 里做。
# 【★ 不再自己乘 smul_mm ★】"先合并再乘一次"才是加算(和共振/风声叠起来要先加)。
# ============================================================

# ① 手里不是苍蓝星 -> 不参与(scan 的调用行已判过, 这里再自查一次防串)
scoreboard players set #as_ok zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["azure_star"]}] run scoreboard players set #as_ok zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["azure_star"]}] run scoreboard players set #as_ok zx.meta 1
execute unless score #as_ok zx.meta matches 1 run return 0

# ② 没攒着被动翻倍 -> 不参与
execute unless score @s zx.as_x2 matches 1.. run return 0

# ③ 往加算池的 mm 通道贡献 +100%(= ×2, 和 recalc 的 double 一致)
data modify storage zx:work put.pct set value 100
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put
