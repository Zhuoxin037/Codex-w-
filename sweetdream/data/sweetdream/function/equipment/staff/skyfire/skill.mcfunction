# 天火 主动: 240 魔力 / 40 秒冷却。
# 消耗全部法球 zx.j_orb 记进 zx.sf_orb(强化普攻可用次数), 开 16 秒(320 刻)强化窗口。
execute unless score @s zx.job matches 1 run tellraw @s {"text":"当前职业无法使用这件专属装备。","color":"red"}
execute unless score @s zx.job matches 1 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:skyfire",mana:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",value:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return fail
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:skyfire",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start
scoreboard players add @s zx.j_orb 0
scoreboard players operation @s zx.sf_orb = @s zx.j_orb
scoreboard players set @s zx.j_orb 0
scoreboard players operation @s zx.sf_end = #now manacore.meta
scoreboard players add @s zx.sf_end 320
playsound minecraft:item.firecharge.use player @s ~ ~ ~ 0.8 1.2
