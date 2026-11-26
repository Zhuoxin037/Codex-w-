$data modify storage sweetdream_floor:run filter.tag set value "$(tag)"
data modify storage sweetdream_floor:run filter.tier set from storage sweetdream_floor:run exact_tier
function sweetdream_floor:pool/query_exact with storage sweetdream_floor:run filter
execute if score @s zx.job matches 0 run return 1
data modify storage sweetdream_floor:run filter.job set value 0
function sweetdream_floor:pool/query_exact with storage sweetdream_floor:run filter
