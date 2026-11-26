scoreboard players set @s zx.j_reborn -1
function fallendream:profession/twin/reborn
# ---- 超限·复纱(2026-11-22): 死亡后 12 秒内重新召唤出来 ----
# 【★ 放在 reborn 之后 ★】ol_summon 会清 zx.rbv_die, 放前面等于把再生本身拦住。
# 【★ 12 秒窗口在 ol_summon 内部算 ★】这里不做差值运算；非超限玩家必须原样走完
#   再生, 所以这两行都不能 return, 只清账 + 转交。
execute if score @s zx.rbv_die matches 1.. unless items entity @s armor.head *[custom_data~{zx:["rebirth_veil"],ol:"rebirth_veil"}] run scoreboard players set @s zx.rbv_die 0
execute if score @s zx.rbv_die matches 1.. run function fallendream:equipment/armor/rebirth_veil/ol_summon
