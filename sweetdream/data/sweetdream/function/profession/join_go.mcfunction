$execute if data storage zx:jobs p."$(uuid)"{pending_return:1b} if score @s zx.j_form matches 1 run function sweetdream:profession/twin/return
$data remove storage zx:jobs p."$(uuid)".pending_return
