$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
data modify storage zx:work a set value {target:"@s",mark:"dream",by:"@a[tag=zx.ub,limit=1]",src:"equip"}
data modify storage zx:work fz set value {target:"@s",ticks:20}
function sweetdream:lib/timestop with storage zx:work fz
function sweetdream:lib/mark_consume
