# ============================================================
# sweetdream:equipment/sword/oath_victory/cast —— 胜利誓约 · 主动（右键）
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/oath_victory（consume_item）
# 【文案】魔力 200 / 冷却 10 秒。突击到自身 5 格内的生物后方并造成 基础攻击力 ×5 的伤害；
#   之后在停留处展开半径 3、持续 6 秒的领域，自身在领域内每秒恢复 3 点生命并获得
#   20% 最大生命的临时生命。
# 【★ 突击怎么写 ★】`execute at <目标> rotated as <目标> run tp @s ^ ^ ^-1.5`
#   · `at` 只换坐标基点（不换执行者）、`rotated as` 只换朝向 ⇒ `^ ^ ^-1.5` 的原点落在
#     目标身上、`-` 方向就是目标背后 1.5 格。
#   · 目标卡在墙里时 tp 可能失败（原版会夹到合法位置），不额外处理：最坏是留在原地，
#     伤害与领域照常结算。
# 【★ 顺序 ★】先扣蓝 → 记冷却 → 位移 → 打伤害 → 放领域（领域在"停留处"= 位移之后）。
# ============================================================

advancement revoke @s only sweetdream:equipment/sword/oath_victory

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# 只读检查：冷却 + 魔力 200
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:oath_victory",mana:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"胜利誓约冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# 5 格内没有生物就不放
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..5] run tellraw @s [{"text":"5 格内没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..5] run return fail

# 扣魔力 200
data modify storage manacore:in arg set value {uuid:"",value:200.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# 记冷却 10 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:oath_victory",cooldown_seconds:10.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# 选最近的一个目标（钉成 zx.ov_t，避免后面每步重挑）
tag @e[tag=zx.ov_t] remove zx.ov_t
execute as @e[type=!#sweetdream:no_damage,distance=0.1..5,sort=nearest,limit=1] run tag @s add zx.ov_t

# 突击到其后方（见文件头）
execute store success score #s2_moved zx.meta run execute at @e[tag=zx.ov_t,limit=1] rotated as @e[tag=zx.ov_t,limit=1] run tp @s ^ ^ ^-1.5
execute if score #s2_moved zx.meta matches 1 at @s run function sweetdream:equipment/armor/empty_cicada/moved

# 伤害：基础攻击力 ×5（把 5 倍算进伤害投递，乘区照常吃）
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.ov_t,distance=..3]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
data modify storage zx:in arg.s2_b_damage set value {n:0,d:1}
data modify storage zx:in arg.s2_b_damage set from storage manacore:out r.s2_b_damage
execute at @s run function sweetdream:api/damage

# 领域：停留在处（位移之后）
data modify storage zx:work ovf.uuid set from storage zx:data self.uuid
execute store result storage zx:work ovf.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work ovf.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work ovf.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work ovf.u3 int 1 run data get entity @s UUID[3]
execute at @s run function sweetdream:equipment/sword/oath_victory/field with storage zx:work ovf

# 表现
particle minecraft:sweep_attack ~ ~1 ~ 0.6 0.2 0.6 0.05 12 normal
playsound minecraft:item.trident.thunder player @a ~ ~ ~ 0.4 1.4

tag @e[tag=zx.ov_t] remove zx.ov_t
