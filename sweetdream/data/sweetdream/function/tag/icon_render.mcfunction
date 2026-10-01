# @s 仍是生物。只有 mask 改变或新建显示实体时才拼接文字。
# fallback 让非中英文客户端也能使用这套字体；顺序固定、没有空槽。
data modify storage zx:tag row set value {text:"",font:"sweetdream:icons",extra:[]}
execute if entity @s[tag=zx.status.yuanhai] run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.yuanhai","fallback":""}
execute if entity @s[tag=zx.status.liuhuo] run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.liuhuo","fallback":""}
execute if entity @s[tag=zx.status.yehuo] run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.yehuo","fallback":""}
execute if entity @s[tag=zx.status.shixin] run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.shixin","fallback":""}
execute if entity @s[tag=zx.status.dream] run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.dream","fallback":""}
$data modify entity @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] text set from storage zx:tag row
$scoreboard players set @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] zx.icon_mask $(mask)
