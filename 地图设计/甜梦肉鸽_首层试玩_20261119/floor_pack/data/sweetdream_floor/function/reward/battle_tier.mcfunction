# Choose the highest threshold reached, then replace it at lower thresholds.
data modify storage sweetdream_floor:run exact_tier set value 4
$execute if score #quality sd.floor matches ..$(t3_max) run data modify storage sweetdream_floor:run exact_tier set value 3
$execute if score #quality sd.floor matches ..$(t2_max) run data modify storage sweetdream_floor:run exact_tier set value 2
$execute if score #quality sd.floor matches ..$(t1_max) run data modify storage sweetdream_floor:run exact_tier set value 1
