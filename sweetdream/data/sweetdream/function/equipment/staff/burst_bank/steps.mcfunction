# at @s必须每步执行；rotated在at之后使用施放快照，不追随中途转头。
$execute if score @s zx.bb_left matches 1.. at @s rotated $(yaw) 0 run function sweetdream:equipment/staff/burst_bank/step with storage zx:work bb
# dup-ok: 同刻第二个子步，重新取位置
$execute if score @s zx.bb_left matches 1.. at @s rotated $(yaw) 0 run function sweetdream:equipment/staff/burst_bank/step with storage zx:work bb
# dup-ok: 同刻第三个子步，重新取位置
$execute if score @s zx.bb_left matches 1.. at @s rotated $(yaw) 0 run function sweetdream:equipment/staff/burst_bank/step with storage zx:work bb
# dup-ok: 同刻第四个子步，重新取位置
$execute if score @s zx.bb_left matches 1.. at @s rotated $(yaw) 0 run function sweetdream:equipment/staff/burst_bank/step with storage zx:work bb
