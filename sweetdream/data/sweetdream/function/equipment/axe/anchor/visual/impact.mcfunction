# 在原 pull_end 的真实落点调用；即刻把飞锚贴到此位置，伤害仍由原函数同刻结算。
execute unless entity @s[tag=zx.av_cast] run return 0
playsound minecraft:block.anvil.land player @a ~ ~ ~ 0.85 0.65
scoreboard players set @s zx.av_phase 1
scoreboard players set @s zx.av_t 0

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:anchor key set value {uuid:""}
data modify storage zx:anchor key.uuid set from storage zx:data self.uuid

function sweetdream:equipment/axe/anchor/visual/impact_owner with storage zx:anchor key
