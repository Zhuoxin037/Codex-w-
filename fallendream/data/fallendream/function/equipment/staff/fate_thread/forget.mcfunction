scoreboard players set #ft_forgot zx.meta 0
$execute unless data storage zx:ft live."$(uuid)" run return 0
$data remove storage zx:ft live."$(uuid)"
scoreboard players set @s zx.ft_mine 0
scoreboard players set @s zx.ft_got 0
scoreboard players set @s zx.ft2_end 0
scoreboard players set @s zx.ft_end 0
tag @s remove zx.ft_link
scoreboard players set #ft_forgot zx.meta 1
