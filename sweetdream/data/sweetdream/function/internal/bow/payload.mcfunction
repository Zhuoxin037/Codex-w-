data modify storage zx:work a set value {target:"@s",type:"sweetdream:skill"}
data modify storage zx:work a.num set from storage zx:work shot_stack[-1].damage
data modify storage zx:work a.u0 set from storage zx:work shot_stack[-1].u0
data modify storage zx:work a.u1 set from storage zx:work shot_stack[-1].u1
data modify storage zx:work a.u2 set from storage zx:work shot_stack[-1].u2
data modify storage zx:work a.u3 set from storage zx:work shot_stack[-1].u3
data modify storage zx:work a.channel_atk set from storage zx:work shot_stack[-1].channel_atk
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
function sweetdream:lib/num/plain
