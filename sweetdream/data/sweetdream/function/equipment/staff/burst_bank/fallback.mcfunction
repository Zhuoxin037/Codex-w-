$execute store success score #s2_moved zx.meta run execute at @e[type=marker,tag=zx.bb_ctrl_$(uuid),limit=1] run tp @s ~ ~ ~
execute if score #s2_moved zx.meta matches 1 at @s run function sweetdream:equipment/armor/empty_cicada/moved
function sweetdream:equipment/staff/burst_bank/refund
