execute unless data storage zx:work shot_hit{id:"lianshi",paid:1b} run return 0
data modify storage zx:work shot_stack append from storage zx:work shot_hit
data remove storage zx:work shot_hit
function sweetdream:equipment/bow/lianshi/hit
data remove storage zx:work shot_stack[-1]
