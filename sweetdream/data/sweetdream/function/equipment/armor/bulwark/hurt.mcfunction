# ============================================================
# sweetdream:equipment/armor/bulwark/hurt —— 肉盾：受击自伤 + 基础攻击力提升
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/bulwark_hurt（entity_hurt_player，不过滤类型）
# 【执行者】玩家（挨打的那个）
# 【文案】受到伤害后额外受到一次相当于该次伤害 ×0.2 的伤害
#   （不超过自身最大生命值 ×0.2），随后基础攻击力提升等同于该额外伤害，持续 10 秒
#   （不可叠加）。若当前生命值低于 10%，则改为获得一次瞬间治疗Ⅴ。
# 【★ 本次伤害怎么取 ★】不读全局 zx.hurt_evt（同事件的另一个进度写它，顺序不保证）。
#   这里自己维持"上次受击后的血量"基线 zx.bw_hp，差值就是这次实际掉的血。
# 【★ 自伤不能再触发自己 ★】自伤走 damage，会再点亮受击进度 ⇒ 用 zx.bw_gate
#   记"本刻已经结算过"，同一刻再进来直接返回（下一刻自然过期）。
# 【★ 玩家不能直写 Health ★】原版禁止改玩家 NBT（零日志不生效），
#   自伤走 `damage @s <num> sweetdream:parallel_true_damage`（宏传值）。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/bulwark_hurt

# 本刻已结算过（自己打自己的那一跳）
execute if score @s zx.bw_gate >= #now manacore.meta run return 0

execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["bulwark"]}] run return 0

# 生命值低于 10% → 改为瞬间治疗Ⅴ
function sweetdream:lib/hp_pct
execute if score #hp_p100 zx.meta matches ..999 run effect give @s minecraft:instant_health 1 4 true
execute if score #hp_p100 zx.meta matches ..999 run return 0

# 本次伤害 = 上次基线 − 当前血量（毫点）
function sweetdream:lib/max_health_score
scoreboard players add @s zx.bw_hp 0
scoreboard players operation #bw_cur zx.meta = @s zx.hp_c
scoreboard players operation #bw_dmg zx.meta = @s zx.bw_hp
scoreboard players operation #bw_dmg zx.meta -= #bw_cur zx.meta
#   第一次挨打没有基线 → 不结算，只记基线
execute if score @s zx.bw_hp matches 0 run scoreboard players set #bw_dmg zx.meta 0
execute if score #bw_dmg zx.meta matches ..0 run scoreboard players set #bw_dmg zx.meta 0

# 额外自伤 = min(本次伤害 ×0.2, 最大生命值 ×0.2)
scoreboard players set #bw_ten zx.meta 10
scoreboard players set #bw_two zx.meta 2
scoreboard players operation #bw_x zx.meta = #bw_dmg zx.meta
scoreboard players operation #bw_x zx.meta *= #bw_two zx.meta
scoreboard players operation #bw_x zx.meta /= #bw_ten zx.meta
scoreboard players operation #bw_cap zx.meta = #max_hp zx.meta
scoreboard players operation #bw_cap zx.meta *= #bw_two zx.meta
scoreboard players operation #bw_cap zx.meta /= #bw_ten zx.meta
execute if score #bw_x zx.meta > #bw_cap zx.meta run scoreboard players operation #bw_x zx.meta = #bw_cap zx.meta

# 结算后血量（毫点）—— 不能等 hp_c 刷新，直接算
scoreboard players operation #bw_after zx.meta = #bw_cur zx.meta
scoreboard players operation #bw_after zx.meta -= #bw_x zx.meta

# 真扣血（宏传值；同一刻上闸，防自己触发自己）
execute if score #bw_x zx.meta matches 1.. run scoreboard players operation @s zx.bw_gate = #now manacore.meta
execute if score #bw_x zx.meta matches 1.. store result storage zx:work bw.v double 0.001 run scoreboard players get #bw_x zx.meta
execute if score #bw_x zx.meta matches 1.. run function sweetdream:equipment/armor/bulwark/self_hurt with storage zx:work bw

# 攻击力提升（账本 + 10 秒）
execute if score #bw_x zx.meta matches 1.. run function sweetdream:equipment/armor/bulwark/boost

# 更新基线
scoreboard players operation @s zx.bw_hp = #bw_after zx.meta
