# Only called after >=100 active action ticks; zx.stop bypasses body_tick entirely.
execute if score @s sdk.state matches 13 run return run function sweetdream:boss/knight/shadow/stop
execute if score @s sdk.state matches 10 run return run function sweetdream:boss/knight/phase_end
execute store result storage sweetdream:knight args.id int 1 run scoreboard players get @s sdk.id
function sweetdream:boss/knight/cleanup_fx with storage sweetdream:knight args
scoreboard players set @s sdk.state 0
function sweetdream:boss/knight/finish
