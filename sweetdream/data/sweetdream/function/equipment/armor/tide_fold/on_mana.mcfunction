# 每笔成功实际扣费最多尝试生成一面；保留现行150魔力累计门槛。
scoreboard players add @s zx.tf_sum 0
scoreboard players operation @s zx.tf_sum += #pm_v zx.meta
execute if score @s zx.tf_sum matches 150000.. run function sweetdream:equipment/armor/tide_fold/spend
