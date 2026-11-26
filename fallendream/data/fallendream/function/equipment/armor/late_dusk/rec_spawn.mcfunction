$summon minecraft:marker ~ ~ ~ {Tags:["zx.lr_record","zx.lr_new"],data:{lr:{tid:$(tid),base:$(base),end:$(end),u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}
$scoreboard players set @e[tag=zx.lr_new,distance=..0.1,limit=1] zx.sid $(tid)
$scoreboard players set @e[tag=zx.lr_new,distance=..0.1,limit=1] zx.lr_end $(end)
tag @e[tag=zx.lr_new,distance=..0.1,limit=1] remove zx.lr_new
