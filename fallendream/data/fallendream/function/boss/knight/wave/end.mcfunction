execute store result storage fallendream:knight wave.id int 1 run scoreboard players get @s sdk.waveid
function fallendream:boss/knight/echo/activate with storage fallendream:knight wave
function fallendream:boss/knight/echo/retain_hits with storage fallendream:knight wave
function fallendream:boss/knight/wave/clear_hits with storage fallendream:knight wave
function fallendream:boss/knight/wave/prune with storage fallendream:knight wave
tag @s remove sd.kn.wave
kill @s
