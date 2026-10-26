$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
$function sweetdream:tag/mark_by {target:"$(target)",mark:"$(mark)",by:"@a[tag=zx.ub,limit=1]"}
