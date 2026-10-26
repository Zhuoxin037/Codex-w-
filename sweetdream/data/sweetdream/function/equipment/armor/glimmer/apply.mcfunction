function sweetdream:equipment/armor/glimmer/maintain
# ============================================================
# sweetdream:equipment/armor/glimmer/apply —— 「浮光」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家(@s)（由 lib/second 广播）
# 【★ 文案(逐字, 用户 2026-10-25 16:53 原稿) ★】
#   红：技能伤害 +20%（走 hook_calc, 不在这里）
#   绿：每秒恢复 1% 最大生命值与 0.5% 最大魔力值
#   黄：移速 +20%，离自身最近的 3 个生物移速 -40%
#   白：技能伤害 +30%（独立乘区）, 每秒恢复 3% 最大生命值与 0.8% 最大魔力值,
#       移速 +30%, 离自身最近的 5 个生物移速 -45%,
#       白光满 3 秒后，每秒对自身 5 格内的随机 4 个生物附加「白昼梦」并使其时停 1 秒
# 【★ 白 = 三色齐, 不是第四种状态 ★】三色计分项都在, 白只是"全 1"的判读。
#   白期间**用白的数值替换**三色数值, 不是叠加。
# 【脱掉头盔怎么办】三色本身不清（原文没说脱了就掉）, 但移速 modifier 必须摘 ——
#   否则摘帽子会白留一条 +20%/+30% 的永久加成（这是漏洞, 不是设计）。
# ============================================================

# ⓪ 没穿浮光头盔 ⇒ 摘掉移速加成后收工
#   ★ 必须按账本 zx.gl_spd 决定要不要 remove（remove 不存在的 modifier 会失败并截断）。
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["glimmer"]}] if score @s zx.gl_spd matches 1.. run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_spd
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["glimmer"]}] run scoreboard players set @s zx.gl_spd 0
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["glimmer"]}] run return 0

# ① 白 = 三色齐
scoreboard players set #gl_w zx.meta 0
execute if score @s zx.gl_r matches 1.. if score @s zx.gl_g matches 1.. if score @s zx.gl_y matches 1.. run scoreboard players set #gl_w zx.meta 1

# ② 回血 + 回魔（绿 / 白）
#   绿: 1% 生命 + 0.5% 魔力；白: 3% 生命 + 0.8% 魔力
#   ★ 这里**不能 return** ★ apply 后面还有移速 / 减速 / 群体白昼梦要走,
#     没绿光时只是跳过这一段（`run return 0` 会把整个 apply 截断）。
scoreboard players set #gl_regen zx.meta 0
execute if score @s zx.gl_g matches 1.. run scoreboard players set #gl_regen zx.meta 1
execute if score #gl_w zx.meta matches 1 run scoreboard players set #gl_regen zx.meta 2
execute if score #gl_regen zx.meta matches 1.. run function sweetdream:equipment/armor/glimmer/regen

# ③ 自身移速档（黄 +20% / 白 +30%）
function sweetdream:equipment/armor/glimmer/self_speed

# ④ 敌人减速（黄：最近 3 个 -40% / 白：最近 5 个 -45%）
function sweetdream:equipment/armor/glimmer/foe_slow

# ⑤ 白：白光满 3 秒后，每秒对 5 格内随机 4 个生物附加「白昼梦」并使其时停 1 秒
# 白昼梦脉冲已移到每刻 heartbeat，按白光创建时刻计算。
