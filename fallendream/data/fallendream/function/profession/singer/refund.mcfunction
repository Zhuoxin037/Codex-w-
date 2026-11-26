scoreboard players set #j_duet_refund zx.meta 0
scoreboard players operation #j_duet_refund zx.meta = @s zx.j_duet_n
execute at @a[tag=zx.ub,limit=1] as @a[distance=..3] run function fallendream:profession/singer/refund_player
kill @s
