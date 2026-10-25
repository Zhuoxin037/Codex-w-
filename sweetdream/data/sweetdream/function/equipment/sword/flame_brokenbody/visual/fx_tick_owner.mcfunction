$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,tag=zx.fb_cast,distance=0..,limit=1] run return run function sweetdream:equipment/sword/flame_brokenbody/visual/fx_end
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute if entity @a[tag=zx.ub,nbt={Health:0.0f},distance=0..,limit=1] run return run function sweetdream:equipment/sword/flame_brokenbody/visual/fx_end
execute unless score @s zx.fb_fx_t matches 0..12 run return run function sweetdream:equipment/sword/flame_brokenbody/visual/fx_end
# 起手方向固定，跟随本人的位置；不依赖附近最近的玩家。
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
$execute at @a[tag=zx.ub,distance=0..,limit=1] rotated $(yaw) 0 run tp @s ~ ~ ~ ~ 0
data modify storage zx:fbvis pick set value {i:0}
execute store result storage zx:fbvis pick.i int 1 run scoreboard players get @s zx.fb_fx_t
function sweetdream:equipment/sword/flame_brokenbody/visual/fx_apply with storage zx:fbvis pick
scoreboard players add @s zx.fb_fx_t 1
