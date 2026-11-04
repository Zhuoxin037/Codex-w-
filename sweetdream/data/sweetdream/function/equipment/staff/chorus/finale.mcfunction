function sweetdream:tag/mark {target:"@e[tag=zx.cs_final_hit,distance=0..]",mark:"dream"}
scoreboard players set @e[tag=zx.cs_final_hit,tag=zx.status.dream,distance=0..] zx.tt.dream 6
data modify storage zx:work fz set value {target:"@e[tag=zx.cs_final_hit,distance=0..]",ticks:20}
function sweetdream:lib/timestop with storage zx:work fz
