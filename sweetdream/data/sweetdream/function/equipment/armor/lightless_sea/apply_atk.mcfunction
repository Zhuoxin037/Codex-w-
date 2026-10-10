# ============================================================
# sweetdream:equipment/armor/lightless_sea/apply_atk —— 给基础攻击力加差值
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值   【执行者】玩家
# 【账本】zx.ls_buf 记"已经加了多少", 每次只补差值, 幂等。
# 【改两个地方】(2026-10-08 补齐, 照 brain_leech/apply_atk)
#   ① 面板 base_attack —— 技能伤害公式与 debug/stats 读它
#   ② 原版属性 minecraft:attack_damage —— 平砍也要真的变疼
#   原先只改 ①: "基础攻击力 +N" 只体现在技能面板上, 平砍纹丝不动,
#   与 brain_leech / mirage 的约定不一致。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ② 原版属性: 无条件摘, 再按新账加(幂等; 摘不存在的 id 只是失败, 不会截断函数)
attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_ls_atk

scoreboard players operation @s zx.ls_buf += #diff zx.meta
execute if score @s zx.ls_buf matches 1.. run data modify storage zx:work x set value {v:0}
execute if score @s zx.ls_buf matches 1.. store result storage zx:work x.v int 1 run scoreboard players get @s zx.ls_buf
execute if score @s zx.ls_buf matches 1.. run function sweetdream:equipment/armor/lightless_sea/atk_add with storage zx:work x
