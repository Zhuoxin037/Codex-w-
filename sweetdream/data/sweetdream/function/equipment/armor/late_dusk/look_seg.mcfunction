function sweetdream:lib/look/separator
data modify storage zx:look xline append value {text:"回光余时 ",color:"dark_purple"}
function sweetdream:equipment/armor/late_dusk/look_one {o:"zx.ld_t1"}
execute if score @s zx.ld_s matches 2.. run data modify storage zx:look xline append value {text:"/",color:"gray"}
execute if score @s zx.ld_s matches 2.. run function sweetdream:equipment/armor/late_dusk/look_one {o:"zx.ld_t2"}
execute if score @s zx.ld_s matches 3 run data modify storage zx:look xline append value {text:"/",color:"gray"}
execute if score @s zx.ld_s matches 3 run function sweetdream:equipment/armor/late_dusk/look_one {o:"zx.ld_t3"}
