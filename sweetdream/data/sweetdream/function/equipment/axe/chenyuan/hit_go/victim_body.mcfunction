$execute as $(vx_uuid) run function sweetdream:equipment/axe/chenyuan/slow_check

# 不带缓慢 -> 收掉临时标签就到此为止
$execute if score #cy_slow zx.meta matches 0 run tag $(vx_uuid) remove zx.victim
execute if score #cy_slow zx.meta matches 0 run return 0

# ① 该武器技能冷却 -1 秒(= 20 tick)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:chenyuan",ticks:20}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reduce

# ② 读自己的当前魔力, 高于 300 才进额外分支
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #cy_m zx.meta 0
execute store result score #cy_m zx.meta run data get storage manacore:out r.value 1
execute if score #cy_m zx.meta matches 301.. run function sweetdream:equipment/axe/chenyuan/mana_branch

$tag $(vx_uuid) remove zx.victim
