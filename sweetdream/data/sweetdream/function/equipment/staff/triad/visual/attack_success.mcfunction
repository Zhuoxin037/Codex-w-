# 此入口仍位于原 attack 扣费和算伤害之后；沿用原法球发射器。
data modify storage zx:work ball.tri_visual_new set value 1b
function sweetdream:projectile/ball/fire
# 标记仅存在于本次同步创建的法球；接线后立刻移除，不靠最近实体认亲。
execute as @e[type=minecraft:marker,tag=zx.ball,nbt={data:{tri_visual_new:1b}},distance=0..] at @s run function sweetdream:equipment/staff/triad/visual/ball_spawn
function sweetdream:equipment/staff/triad/visual/start
execute unless score @s zx.tri_form matches 1.. run playsound minecraft:item.trident.throw player @a ~ ~ ~ 0.7 0.8
execute if score @s zx.tri_form matches 1 run playsound minecraft:item.trident.throw player @a ~ ~ ~ 0.55 1.3
execute if score @s zx.tri_form matches 2 run playsound minecraft:item.trident.throw player @a ~ ~ ~ 0.9 0.6
