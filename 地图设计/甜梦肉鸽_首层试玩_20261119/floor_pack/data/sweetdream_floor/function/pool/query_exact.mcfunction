# Complete a pending offer from before the weapons/armor rollout using the original list.
$execute unless data storage sweetdream_floor:run {battle_draw:1b} run return run data modify storage sweetdream_floor:run pool append from storage sweetdream_floor:pool entries[{job:$(job),tier:$(tier),tags:["$(tag)"]}]
$data modify storage sweetdream_floor:run pool append from storage sweetdream_floor:pool entries[{job:$(job),tier:$(tier),category:"armor",tags:["$(tag)"]}]
$data modify storage sweetdream_floor:run pool append from storage sweetdream_floor:pool entries[{job:$(job),tier:$(tier),category:"axe",tags:["$(tag)"]}]
$data modify storage sweetdream_floor:run pool append from storage sweetdream_floor:pool entries[{job:$(job),tier:$(tier),category:"bow",tags:["$(tag)"]}]
$data modify storage sweetdream_floor:run pool append from storage sweetdream_floor:pool entries[{job:$(job),tier:$(tier),category:"staff",tags:["$(tag)"]}]
$data modify storage sweetdream_floor:run pool append from storage sweetdream_floor:pool entries[{job:$(job),tier:$(tier),category:"sword",tags:["$(tag)"]}]
