scoreboard players set #trace_left sdk.step 0
$execute store result score #trace_left sdk.step run data get storage sweetdream:knight waves."$(id)".remaining 1
scoreboard players remove #trace_left sdk.step 1
$execute store result storage sweetdream:knight waves."$(id)".remaining int 1 run scoreboard players get #trace_left sdk.step
$execute if score #trace_left sdk.step matches ..0 run data remove storage sweetdream:knight waves."$(id)"
kill @s
