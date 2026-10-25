function sweetdream:equipment/tool/retro_shine/on_hurt
$execute if data storage zx:work rt.num as $(source) run function sweetdream:equipment/tool/retro_shine/reflect
data remove storage zx:work rt
