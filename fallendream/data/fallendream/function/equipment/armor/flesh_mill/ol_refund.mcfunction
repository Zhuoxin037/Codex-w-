# ============================================================
# fallendream:equipment/armor/flesh_mill/ol_refund —— 超限·血肉磨坊: 补发未结算 + 回 1% 生命
# ------------------------------------------------------------
# 【执行者/受益者】玩家(穿超限血肉磨坊、窗口还在时又挨了一下的人)
# 【谁调用它】flesh_mill/hurt —— 已判过"超限"且"本秒窗口还在(zx.fm_t >= 1)"
# 【文案(逐字)】"上述效果持续期间再次受到伤害时，立即恢复本轮尚未结算的额外魔力值
#   并恢复 1% 生命值，随后重新开始该效果。"
# 【拆分】
#   ① 未结算秒数 = 5 - 本轮已结算秒数(zx.fm_n)
#   ② 未结算魔力 = 未结算秒数 × 3(超限每秒的量) —— 一次性进 api/mana/add
#   ③ 恢复 1% 生命值 —— 走 lib/heal 整点入口, 向下取整保底 1 点
#   ④ 已结算计数清零(窗口由 hurt 那边刷满) = "重新开始"
# 【★ 为什么"×3"写死 ★】文案超限把每秒量写成了 3; 二件套那条"每秒额外 +1"是
#   常驻账本, 不属于本轮窗口, 补发时不能算进来(否则等于把常驻也一次性预支)。
# 【★ 补发不写 zx.regen_extra ★】那个账本是 debug 面板的"回魔/秒", 补发是一次性
#   入账, 记进去会把面板数字撑成假的。
# ============================================================

# 常量(超限每秒 3 魔力 / 毫点换整点的 1000)
scoreboard players set #fm_3 zx.meta 3
scoreboard players set #fm_k zx.meta 1000

# ① 未结算秒数
scoreboard players set #fm_left zx.meta 5
execute if score @s zx.fm_n matches 1.. run scoreboard players operation #fm_left zx.meta -= @s zx.fm_n

# ② 未结算魔力 = 秒数 × 3
scoreboard players set #fm_add zx.meta 0
execute if score #fm_left zx.meta matches 1.. run scoreboard players operation #fm_add zx.meta = #fm_left zx.meta
execute if score #fm_add zx.meta matches 1.. run scoreboard players operation #fm_add zx.meta *= #fm_3 zx.meta

# ③ 回 1% 生命(先算, 不依赖 uuid, 魔力那条万一失败也不该吞掉回血)
function fallendream:lib/max_health_score
scoreboard players set #mp_out zx.meta 0
execute if score #max_hp zx.meta matches 1.. run scoreboard players operation #mp_src zx.meta = #max_hp zx.meta
execute if score #max_hp zx.meta matches 1.. run scoreboard players set #mp_mul zx.meta 10
execute if score #max_hp zx.meta matches 1.. run function fallendream:lib/math/mul_permille
execute if score #max_hp zx.meta matches 1.. run scoreboard players operation #mp_out zx.meta /= #fm_k zx.meta
execute if score #max_hp zx.meta matches 1.. unless score #mp_out zx.meta matches 1.. run scoreboard players set #mp_out zx.meta 1
scoreboard players operation #heal_pt zx.meta = #mp_out zx.meta
execute if score #heal_pt zx.meta matches 1.. run function fallendream:lib/heal

# ④ 补发魔力(要 uuid; 拿不到就只少这一笔, 不 return)
function fallendream:lib/uuid
execute if score #fm_add zx.meta matches 1.. if data storage zx:data self{ok:1b} run function fallendream:equipment/armor/flesh_mill/gain

# ⑤ 本轮已结算计数清零 = 本轮作废, 由 hurt 把窗口刷满后重新开始
scoreboard players set @s zx.fm_n 0

# ⑥ 表现
execute at @s run particle minecraft:heart ~ ~1.2 ~ 0.4 0.4 0.4 0.05 10 normal
execute at @s run particle minecraft:witch ~ ~1.0 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:entity.player.levelup player @a ~ ~ ~ 0.5 1.6
