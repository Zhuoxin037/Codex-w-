# 存在拉近对象时支付文案中的 80 魔力；不足时仅跳过副手效果。
# 原技能的消费已经完成，不回滚技能，不附加冷却。
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["tide_buckle"]}] run return 0
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# 三个 0.25 格小步：每步重算朝向、检查脚部和头部。
execute as @e[tag=zx.tb_pull,distance=0..] at @s run function sweetdream:equipment/tool/tide_buckle/pull_step
# dup-ok: 第二步，累计最多 0.50 格，每步重新检查距离与方块。
execute as @e[tag=zx.tb_pull,distance=0..] at @s run function sweetdream:equipment/tool/tide_buckle/pull_step
# dup-ok: 第三步，累计最多 0.75 格，每步重新检查距离与方块。
execute as @e[tag=zx.tb_pull,distance=0..] at @s run function sweetdream:equipment/tool/tide_buckle/pull_step
execute at @e[tag=zx.tb_center,distance=0..,limit=1] run particle minecraft:bubble_pop ~ ~0.6 ~ 0.7 0.5 0.7 0.02 10 normal
