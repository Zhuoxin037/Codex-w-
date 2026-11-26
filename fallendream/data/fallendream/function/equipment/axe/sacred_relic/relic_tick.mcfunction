# @s = 遗骸, zx.sr_ft 为准确的到期 tick。主动最后一跳先结算, 再删除到期遗骸。
execute if score @s zx.sr_ft <= #now manacore.meta run kill @s
