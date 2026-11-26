$scoreboard players set #ft_line_until zx.meta $(until)
execute if score #ft_line_until zx.meta <= #now manacore.meta run return 0
$execute as $(uuid) if data entity @s {Health:0.0f} run return 0
data modify storage zx:work ft_pass.kept append from storage zx:work ft_pass.queue[0]
$execute as $(uuid) if entity @s[distance=..12] run tag @s add zx.ft_lnok
