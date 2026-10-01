# 校验施法者、槽位、维度和登录代数；任一变化就取消，尚未命中则不结算。
$execute unless score @s zx.sd_leave matches $(leave) run return run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
execute if entity @s[nbt={Health:0.0f}] run return run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
$execute unless data entity @s {SelectedItemSlot:$(slot)} run return run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
$execute unless data entity @s {Dimension:"$(dimension)"} run return run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
execute if score @s zx.sd_t matches -1 run return run function sweetdream:equipment/sword/sickle_dreams/sweep/wait with storage zx:sweep current
# 施法中再右键会走公共回手；只短暂等它，不能将武器缺席当成新的攻击。
execute if entity @s[tag=test_pending_return] run return 0
$execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["sickle_dreams"],sd_sweep:$(id)}] run return run function sweetdream:equipment/sword/sickle_dreams/sweep/context_cancel
scoreboard players add @s zx.sd_t 1
execute if data storage zx:sweep current{enhanced:0} run function sweetdream:equipment/sword/sickle_dreams/sweep/normal
execute if data storage zx:sweep current{enhanced:1} run function sweetdream:equipment/sword/sickle_dreams/sweep/heavy
