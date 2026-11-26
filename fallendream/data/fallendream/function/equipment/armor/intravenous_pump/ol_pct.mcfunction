# ============================================================
# fallendream:equipment/armor/intravenous_pump/ol_pct —— 超限·静脉泵：满血时上限 +12%
# ------------------------------------------------------------
# 【执行者】玩家  【出参】#ip_want zx.meta = 该给的整点上限量
# 【★ 基准要扣掉已经加过的量 ★】本件 +160（zx.pump_mana）、套装（zx.set_mana）、
#   以及本条自己上一秒加过的（zx.ip_pct）都得减掉，否则每秒在"已加成"的上限上
#   再 ×12% 会滚雪球（0.12 复利，几十秒就爆表）。
# 【★ 向上取整 ★】`÷100000` 是整除；不足 1 点的一律给 0，但下秒基准仍会重算，
#   不会累积误差。R05：×12 前先夹到 INT32_MAX ÷ 12。
# ============================================================

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #ip_mm zx.meta 0
execute store result score #ip_mm zx.meta run data get storage manacore:out r.max 1000

scoreboard players add @s zx.pump_mana 0
scoreboard players add @s zx.set_mana 0
scoreboard players add @s zx.ip_pct 0
scoreboard players operation #ip_base zx.meta = #ip_mm zx.meta
scoreboard players operation #ip_g1 zx.meta = @s zx.pump_mana
scoreboard players operation #ip_g1 zx.meta *= #1000 zx.meta
scoreboard players operation #ip_base zx.meta -= #ip_g1 zx.meta
scoreboard players operation #ip_g2 zx.meta = @s zx.set_mana
scoreboard players operation #ip_g2 zx.meta *= #1000 zx.meta
scoreboard players operation #ip_base zx.meta -= #ip_g2 zx.meta
scoreboard players operation #ip_g3 zx.meta = @s zx.ip_pct
scoreboard players operation #ip_g3 zx.meta *= #1000 zx.meta
scoreboard players operation #ip_base zx.meta -= #ip_g3 zx.meta

scoreboard players set #ip_cap zx.meta 2147483647
scoreboard players set #ip_12 zx.meta 12
scoreboard players operation #ip_cap zx.meta /= #ip_12 zx.meta
execute if score #ip_base zx.meta > #ip_cap zx.meta run scoreboard players operation #ip_base zx.meta = #ip_cap zx.meta
scoreboard players operation #ip_want zx.meta = #ip_base zx.meta
scoreboard players operation #ip_want zx.meta *= #ip_12 zx.meta
scoreboard players set #ip_div zx.meta 100000
scoreboard players operation #ip_want zx.meta /= #ip_div zx.meta
