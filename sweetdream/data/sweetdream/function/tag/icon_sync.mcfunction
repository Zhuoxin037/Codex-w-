# 一只生物一个显示实体，通用与专属图标同排；整个文字行一起朝向观察者。
# 计数而非仅判断存在：遗留重复实体会主动去重。
$execute store result score #tag_count zx.meta run execute if entity @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3)]
execute if score #tag_count zx.meta matches 2.. run function sweetdream:tag/icon_dedupe with storage zx:tag owner
execute if score #tag_count zx.meta matches 0 run function sweetdream:tag/icon_spawn with storage zx:tag owner
$execute unless score @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] zx.icon_mask matches $(mask) run function sweetdream:tag/icon_render with storage zx:tag owner
function sweetdream:tag/icon_tp with storage zx:tag owner
