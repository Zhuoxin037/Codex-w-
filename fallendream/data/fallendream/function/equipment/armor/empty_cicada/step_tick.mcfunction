execute unless items entity @s armor.chest *[custom_data~{zx:["empty_cicada"]}] run return 0
execute store result score #s2_dx zx.meta run data get entity @s Pos[0] 100
scoreboard players operation #s2_dx zx.meta -= @s zx.s2_step_x
execute if score #s2_dx zx.meta matches 30000.. run scoreboard players set #s2_dx zx.meta 30000
execute if score #s2_dx zx.meta matches ..-30000 run scoreboard players set #s2_dx zx.meta -30000
scoreboard players operation #s2_dx zx.meta *= #s2_dx zx.meta
execute store result score #s2_dy zx.meta run data get entity @s Pos[1] 100
scoreboard players operation #s2_dy zx.meta -= @s zx.s2_step_y
execute if score #s2_dy zx.meta matches 30000.. run scoreboard players set #s2_dy zx.meta 30000
execute if score #s2_dy zx.meta matches ..-30000 run scoreboard players set #s2_dy zx.meta -30000
scoreboard players operation #s2_dy zx.meta *= #s2_dy zx.meta
execute store result score #s2_dz zx.meta run data get entity @s Pos[2] 100
scoreboard players operation #s2_dz zx.meta -= @s zx.s2_step_z
execute if score #s2_dz zx.meta matches 30000.. run scoreboard players set #s2_dz zx.meta 30000
execute if score #s2_dz zx.meta matches ..-30000 run scoreboard players set #s2_dz zx.meta -30000
scoreboard players operation #s2_dz zx.meta *= #s2_dz zx.meta
scoreboard players operation #s2_d2 zx.meta = #s2_dx zx.meta
scoreboard players operation #s2_d2 zx.meta += #s2_dy zx.meta
scoreboard players operation #s2_d2 zx.meta += #s2_dz zx.meta
execute unless score #s2_d2 zx.meta matches 90000.. run return 0
scoreboard players set @s zx.s2_step_end 0
# 超限：这一路没有"技能位移起点"marker，起点按当前位置记（只会落一个额外余影）
execute if data storage zx:work s2_shadow.ol run data modify storage zx:work cic_pos set value {}
execute if data storage zx:work s2_shadow.ol run data modify storage zx:work cic_pos.start set from entity @s Pos
execute if data storage zx:work s2_shadow.ol run data modify storage zx:work cic_pos.end set from entity @s Pos
data modify storage zx:work s2_shadow set value {owner:""}
function fallendream:lib/uuid
data modify storage zx:work s2_shadow.owner set from storage zx:data self.uuid
function fallendream:equipment/armor/empty_cicada/release with storage zx:work s2_shadow
