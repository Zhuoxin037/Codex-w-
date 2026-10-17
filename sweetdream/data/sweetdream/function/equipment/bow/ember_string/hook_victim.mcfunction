# ============================================================
# sweetdream:equipment/bow/ember_string/hook_victim —— 「烬弦」命中回调
# ------------------------------------------------------------
# 【谁调用它】enchantment/ember_string.json 的 post_attack -> affected:"victim"
# 【执行者】@s = 被打中的那只生物
# 【筛三件事】① 是箭打的 ② 这一发付过账 ③ 打中的是生物(不是玩家)。
#   ★ 本件**不要求**受害者带任何状态 —— 三种分支覆盖"带/不带流火夜火"的所有情况。
# 【诊断锚】dbg1 进来 / dbg2 过箭门控 / dbg3 过付账门控 / dbg4 过生物门控 / dbg5 到 apply。
# ============================================================

scoreboard players add #es_dbg1 zx.meta 1

# ⓪ 只处理"箭造成的命中"
execute unless entity @e[tag=zx.es_arr,distance=0..,limit=1] run return 0
scoreboard players add #es_dbg2 zx.meta 1

# ⓪.5 已付账门控(回到射手身上读; 先置零再取值, 坑 141 —— 不能写 on attacker unless … return)
scoreboard players set #es_p zx.meta 0
execute on attacker store result score #es_p zx.meta run scoreboard players get @s zx.es_paid
execute unless score #es_p zx.meta matches 1 run return 0
scoreboard players add #es_dbg3 zx.meta 1

# ① 受害者必须是生物
tag @e[tag=zx.es_v,distance=0..] remove zx.es_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.es_v
execute unless entity @e[tag=zx.es_v,distance=0..,limit=1] run return 0
scoreboard players add #es_dbg4 zx.meta 1

# ② 交给 apply
scoreboard players add #es_dbg5 zx.meta 1
data modify storage zx:work es.target set value "@e[tag=zx.es_v,limit=1]"
data modify storage zx:work es.shooter set value "@a[tag=zx.es_pl,limit=1]"
execute unless entity @a[tag=zx.es_pl,limit=1] run data modify storage zx:work es.shooter set value "@p"
function sweetdream:equipment/bow/ember_string/apply with storage zx:work es
