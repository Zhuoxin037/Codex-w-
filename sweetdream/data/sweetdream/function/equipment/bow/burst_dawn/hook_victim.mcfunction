# ============================================================
# sweetdream:equipment/bow/burst_dawn/hook_victim —— 「爆裂黎明」命中回调
# ------------------------------------------------------------
# 【谁调用】enchantment/burst_dawn.json 的 post_attack -> affected:"victim"
#   即"这把弩射出的箭打中生物"时由原版回调, 命中判定交给原版。
# 【执行者】@s = 被打中的那只生物
# 【★ 近战门控 ★】必须先有 hook_arrow 打上的 zx.bd_arr(那支箭), 否则说明是拿弩
#   近战敲人 -> 直接收工。这条门控不能删(2026-10-05 同族事故)。
# 【本文件只做"筛人 + 认口径", 真正的结算在 apply -> fire】
#   ① 是箭打的; ② 打中的是生物(不是玩家); ③ 这一发是"主力"还是"续轰"
#      —— 判据是射手身上的 zx.bd_mode(1 主力 / 2 续轰), 命中时 on attacker 读。
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.bd_arr)直接收工
scoreboard players add #bd_dbg1 zx.meta 1
execute unless entity @e[tag=zx.bd_arr,distance=0..,limit=1] run return 0

# ⓪.5 已付账门控: 回到**射手**身上读 zx.bd_paid(坑 141 —— 箭上的标签靠不住)
#   ★ 不能写成 `execute on attacker unless score ... run return 0`: 万一 on attacker
#     解析不到就**整条命令失败**, return 根本不会执行 => 门控被跳过(坑 138 同族)。
#     改成"先置零再取值", 取不到就是 0 => 收工。
scoreboard players add #bd_dbg2 zx.meta 1
scoreboard players set #bd_p zx.meta 0
execute on attacker store result score #bd_p zx.meta run scoreboard players get @s zx.bd_paid
execute unless score #bd_p zx.meta matches 1 run return 0

execute at @s positioned ~ ~0.85 ~ run function sweetdream:equipment/bow/burst_dawn/visual/impact
tag @e[tag=zx.bd_arr,distance=0..] add zx.bv_impacted
# ① 受害者必须是**生物**(排除玩家)
scoreboard players add #bd_dbg3 zx.meta 1
tag @e[tag=zx.bd_v,distance=0..] remove zx.bd_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.bd_v
execute unless entity @e[tag=zx.bd_v,distance=0..,limit=1] run return 0

# ② 记下这一发的口径: 1 = 主力(基础攻击力 ×8 + 最大魔力 ×0.15)
#                     2 = 续轰(基础攻击力 ×4 + 最大魔力 ×0.08)
#    【判据在射手身上, 不在箭上】zx.bd_mode 由 shot(首发=1) / ammo(续轰=2) 写。
#      ★ 原来是看箭上的 zx.bd_ammo 标签, 但射击那一刻箭可能还没进世界 ⇒ 标签
#        打不上 ⇒ 续轰那一发会被误判成主力口径(坑 141)。
#    【为什么写在 zx:work bd.mode 而不是别的】fire 是宏函数, 直接读同一个存储
#     节点最省事; 整条"命中 -> 结算"是**同一刻同步跑完**的, 不存在被插队改掉的可能。
scoreboard players set #bd_m zx.meta 1
execute on attacker store result score #bd_m zx.meta run scoreboard players get @s zx.bd_mode
execute store result storage zx:work bd.mode int 1 run scoreboard players get #bd_m zx.meta

# ③ 交给 apply(需要射手 uuid 才能查面板攻击力 / 最大魔力 / 伤害归属)
scoreboard players add #bd_dbg5 zx.meta 1
data modify storage zx:work bd.target set value "@e[tag=zx.bd_v,limit=1]"
data modify storage zx:work bd.shooter set value "@a[tag=zx.bd_pl,limit=1]"
execute unless entity @a[tag=zx.bd_pl,limit=1] run data modify storage zx:work bd.shooter set value "@p"
function sweetdream:equipment/bow/burst_dawn/apply with storage zx:work bd
