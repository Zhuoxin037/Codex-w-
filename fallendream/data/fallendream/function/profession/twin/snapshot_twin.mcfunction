$data modify storage zx:jobs p."$(uuid)".twin.pos set from entity @s Pos
$data modify storage zx:jobs p."$(uuid)".twin.dim set from entity @s Dimension
$data modify storage zx:jobs p."$(uuid)".twin.hp set from entity @s Health
$data modify storage zx:jobs p."$(uuid)".twin.mana set from storage manacore:players "$(uuid)".stats.current_mana

execute store result storage zx:work jt_twinmax double .001 run attribute @s minecraft:max_health get 1000
$data modify storage zx:jobs p."$(uuid)".twin.max set from storage zx:work jt_twinmax
