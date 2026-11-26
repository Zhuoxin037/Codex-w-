# Only called after >=100 active action ticks; zx.stop bypasses body_tick entirely.
execute if score @s sdk.state matches 13 run return run function fallendream:boss/knight/shadow/stop
execute if score @s sdk.state matches 10 run return run function fallendream:boss/knight/phase_end
execute store result storage fallendream:knight args.id int 1 run scoreboard players get @s sdk.id
function fallendream:boss/knight/cleanup_fx with storage fallendream:knight args
scoreboard players set @s sdk.state 0
function fallendream:boss/knight/finish
