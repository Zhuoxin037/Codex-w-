data modify storage sweetdream_floor:run pool set value []
scoreboard players add @s zx.job 0
execute store result storage sweetdream_floor:run filter.job int 1 run scoreboard players get @s zx.job
$execute if data storage sweetdream_floor:run exact_tier run return run function sweetdream_floor:pool/filter_exact {tag:"$(tag)"}
$function sweetdream_floor:pool/query {tag:"$(tag)",job:0}
$execute unless score @s zx.job matches 0 run function sweetdream_floor:pool/query_job {tag:"$(tag)"}
