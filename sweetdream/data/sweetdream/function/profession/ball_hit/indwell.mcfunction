$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1,scores={zx.job=4}] positioned ~ ~ ~ run function sweetdream:profession/ball_owner/indwell
