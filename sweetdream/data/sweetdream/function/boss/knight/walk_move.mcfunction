# Reuse existing collision/step-up checks; macro has only five cached speed combinations.
$execute at @s run function sweetdream:boss/knight/move {step:$(step)}
$execute if score @s sdk.moved matches 0 at @s rotated ~35 0 run function sweetdream:boss/knight/move {step:$(detour)}
$execute if score @s sdk.moved matches 0 at @s rotated ~-35 0 run function sweetdream:boss/knight/move {step:$(detour)}
$execute if score @s sdk.moved matches 0 at @s positioned ~ ~1 ~ run function sweetdream:boss/knight/move {step:$(step)}
