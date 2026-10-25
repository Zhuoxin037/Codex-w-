$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute if entity @a[tag=zx.bd_owner,tag=zx.ub,limit=1] run scoreboard players set #bd_tt zx.meta 1
