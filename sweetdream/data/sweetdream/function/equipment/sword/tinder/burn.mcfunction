# ============================================================
# sweetdream:equipment/sword/tinder/burn —— 燃烧态: 打一圈 + 点燃未燃者 + 熄灭自己
# ------------------------------------------------------------
# 【谁调用它】tinder/hit(燃烧态分支)
# 【执行者】施法者(玩家); 【分档】#td_ol(0=原版 / 1=超限, 由 hit -> is_ol 拍好)
# 【三步(顺序即技能原文顺序)】
#   ① 对"被击者 N 格内的全部生物"打 伤害(other_mul = 当前魔力 / max_mana_mul = 最大魔力)。
#   ② 使这些生物里**未处于燃烧状态**的燃烧 5 秒(原版 Fire = 100 tick)。
#   ③ 熄灭该武器(zx.td_on = 0) —— ★ **两版共用**: 超限原文那句
#      "…燃烧 5 秒并熄灭该武器，且使附有「夜火」…" 里的"并熄灭该武器"原稿**漏写**,
#      2026-10-12 用户确认补回 ⇒ 超限版打一发同样熄灭(与基础版一致)。
# 【超限另加】④ 使附有「夜火」(zx.status.yehuo) 的生物**额外受到一次**同样的伤害。
# 【★ at 必须在 as 前 ★】execute at @e[victim] as @e[范围] —— as 只换执行者不改坐标。
# ============================================================

# 钉死被击者
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,limit=1] run return 0

# uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ① 伤害: 当前剩余魔力 ×0.1(原版) / 最大魔力值 ×0.1(超限), 对"被击者 N 格内的全部生物"
data modify storage manacore:in arg set value {uuid:"",other_mul:0.1}
execute if score #td_ol zx.meta matches 1.. run data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..2]",damage:0.0}
execute if score #td_ol zx.meta matches 1.. run data modify storage zx:in arg.target set value "@e[type=!#sweetdream:no_damage,distance=..3]"
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @e[tag=zx.victim,limit=1,distance=..32] run function sweetdream:api/damage

# ② 点燃"未处于燃烧状态"的生物 5 秒(Fire=100 tick); 半径与 ① 同档(原版 2 / 超限 3)
#   ★ 逐实体交给 ignite 判(不能用 {Fire:1..} 过滤器: 会让整个函数加载失败)
execute unless score #td_ol zx.meta matches 1.. at @e[tag=zx.victim,limit=1,distance=..32] as @e[type=!#sweetdream:no_damage,distance=..2] run function sweetdream:equipment/sword/tinder/ignite
execute if score #td_ol zx.meta matches 1.. at @e[tag=zx.victim,limit=1,distance=..32] as @e[type=!#sweetdream:no_damage,distance=..3] run function sweetdream:equipment/sword/tinder/ignite

# ③ 熄灭该武器(两版共用 —— 见头部 ③; 2026-10-12 用户确认原稿漏写"并熄灭该武器")
scoreboard players set @s zx.td_on 0
#   ★ 当刻就换回"熄灭"外观(不等下一秒 second 的兜底): 火灭了, 剑要立刻冷下来
function sweetdream:equipment/sword/tinder/visual/sync
#   ★ 熄灭的一声(与 dark 点燃那一下对称; 批 10 重写时漏掉, 2026-10-12 补回)
execute at @s run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.8 1.0

# ④ 超限: 附有「夜火」的生物额外受到一次同样的伤害
execute if score #td_ol zx.meta matches 1.. at @e[tag=zx.victim,limit=1,distance=..32] run tag @e[type=!#sweetdream:no_damage,distance=..3,tag=zx.status.yehuo] add zx.td_nf
execute if entity @e[tag=zx.td_nf,limit=1] run data modify storage zx:in arg set value {target:"@e[tag=zx.td_nf,distance=0..]",damage:0.0}
execute if entity @e[tag=zx.td_nf,limit=1] run data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute if entity @e[tag=zx.td_nf,limit=1] run function sweetdream:api/damage
tag @e[tag=zx.td_nf,distance=0..] remove zx.td_nf

# 表现: 一圈火焰炸开(熄灭的一声在 ③ 那边 —— 它必须紧跟状态翻转的当刻)
execute at @e[tag=zx.victim,limit=1,distance=..32] run particle minecraft:flame ~ ~1 ~ 0.6 0.5 0.6 0.06 24 normal
execute at @e[tag=zx.victim,limit=1,distance=..32] run particle minecraft:lava ~ ~1 ~ 0.5 0.4 0.5 0.02 8 normal
execute at @e[tag=zx.victim,limit=1,distance=..32] run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.9 0.9

# 清理 victim
tag @e[tag=zx.victim] remove zx.victim
