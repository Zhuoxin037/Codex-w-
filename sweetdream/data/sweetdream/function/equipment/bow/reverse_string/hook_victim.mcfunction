# ============================================================
# sweetdream:equipment/bow/reverse_string/hook_victim —— 「逆弦」命中回调
# ------------------------------------------------------------
# 【谁调用它】enchantment/reverse_string.json 的 post_attack -> affected:"victim"
# 【执行者】@s = 被打中的那只生物
# 【筛三件事】① 是箭打的 ② 这一发付过账 ③ 打中的是生物(不是玩家)。
# 【诊断锚】dbg1 进来 / dbg2 过箭门控 / dbg3 过付账门控 / dbg4 过生物门控 / dbg5 到 apply。
# ============================================================

scoreboard players add #rs_dbg1 zx.meta 1

# ⓪ 只处理"箭造成的命中"
execute unless entity @e[tag=zx.rs_arr,distance=0..,limit=1] run return 0
scoreboard players add #rs_dbg2 zx.meta 1

# ⓪.5 已付账门控(先置零再取值, 坑 141 —— 不能写 on attacker unless … return)
scoreboard players set #rs_p zx.meta 0
execute on attacker store result score #rs_p zx.meta run scoreboard players get @s zx.rs_paid
execute unless score #rs_p zx.meta matches 1 run return 0
scoreboard players add #rs_dbg3 zx.meta 1

# ① 受害者必须是生物
tag @e[tag=zx.rs_v,distance=0..] remove zx.rs_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.rs_v
execute unless entity @e[tag=zx.rs_v,distance=0..,limit=1] run return 0
scoreboard players add #rs_dbg4 zx.meta 1

# ② 交给 apply
scoreboard players add #rs_dbg5 zx.meta 1
data modify storage zx:work rs.target set value "@e[tag=zx.rs_v,limit=1]"
data modify storage zx:work rs.shooter set value "@a[tag=zx.rs_pl,limit=1]"
execute unless entity @a[tag=zx.rs_pl,limit=1] run data modify storage zx:work rs.shooter set value "@p"
function sweetdream:equipment/bow/reverse_string/apply with storage zx:work rs
