# 施放后20/40/60/80刻各一跳，不依赖全服秒相位。
scoreboard players operation #sc_due zx.meta = @s zx.sc_until
scoreboard players remove #sc_due zx.meta 60
scoreboard players operation #sc_offset zx.meta = @s zx.sc_step
scoreboard players operation #sc_offset zx.meta *= #20 zx.meta
scoreboard players operation #sc_due zx.meta += #sc_offset zx.meta
execute if score #sc_due zx.meta > #now manacore.meta run return 0
function sweetdream:equipment/sword/sacrifice/second
