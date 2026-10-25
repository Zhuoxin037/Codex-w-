execute store result storage sweetdream:knight wave.id int 1 run scoreboard players get @s sdk.waveid
function sweetdream:boss/knight/echo/activate with storage sweetdream:knight wave
function sweetdream:boss/knight/echo/retain_hits with storage sweetdream:knight wave
function sweetdream:boss/knight/wave/clear_hits with storage sweetdream:knight wave
function sweetdream:boss/knight/wave/prune with storage sweetdream:knight wave
tag @s remove sd.kn.wave
kill @s
