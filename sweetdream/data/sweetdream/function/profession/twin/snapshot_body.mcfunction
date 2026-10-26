$data modify storage zx:jobs p."$(uuid)".body.pos set from entity @s Pos
$data modify storage zx:jobs p."$(uuid)".body.dim set from entity @s Dimension
$data modify storage zx:jobs p."$(uuid)".body.hp set from entity @s Health
$data modify storage zx:jobs p."$(uuid)".body.mana set from storage manacore:players "$(uuid)".stats.current_mana
execute store result storage zx:work jt.max double 0.001 run attribute @s minecraft:max_health get 1000
$data modify storage zx:jobs p."$(uuid)".body.max set from storage zx:work jt.max
