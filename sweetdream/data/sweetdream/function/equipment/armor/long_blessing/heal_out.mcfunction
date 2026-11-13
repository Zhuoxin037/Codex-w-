# 毫血累加器兑现: 整点部分写 #heal_pt 调 lib/heal, 余数留着(4% 常不足 1 点)。
scoreboard players operation #heal_pt zx.meta = @s zx.lb_hacc
scoreboard players operation #heal_pt zx.meta /= #1000 zx.meta
scoreboard players operation @s zx.lb_hacc %= #1000 zx.meta
execute if score #heal_pt zx.meta matches 1.. run function sweetdream:lib/heal
