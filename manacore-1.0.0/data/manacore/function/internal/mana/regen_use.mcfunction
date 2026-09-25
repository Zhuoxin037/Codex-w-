# ------------------------------------------------------------
# internal/mana/regen_use —— 单个修正的"是否已过期"分流
# 【宏参数】manacore:work.entry {uuid,i}
# 【逻辑】槽位带 end(临时修正) -> 交给 expire_check 判到期;
#         不带 end(装备/被动等永久修正) -> 直接计入 mod_sum。
# 【临时魔力恢复就是这么实现的】add 时给 duration, 写入 end=当前刻+duration,
#         到期后会在下一次秒检查里被自动清掉。
# ------------------------------------------------------------
execute if data storage manacore:work entry.e run data remove storage manacore:work entry.e
$execute if data storage manacore:players "$(uuid)".regen_mods."$(i)".end run data modify storage manacore:work entry.e set from storage manacore:players "$(uuid)".regen_mods."$(i)".end
execute unless data storage manacore:work entry.e run function manacore:internal/mana/mod_sum with storage manacore:work entry
execute if data storage manacore:work entry.e run function manacore:internal/mana/expire_check with storage manacore:work entry
