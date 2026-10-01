# ------------------------------------------------------------
# 临时上限到期: 两个账本清零, 再由 temp_apply 把差值(负数)抵掉
# ------------------------------------------------------------
scoreboard players set @s zx.dd_t1 0
scoreboard players set @s zx.dd_t2 0
function sweetdream:equipment/armor/dusk_dawn/temp_apply
