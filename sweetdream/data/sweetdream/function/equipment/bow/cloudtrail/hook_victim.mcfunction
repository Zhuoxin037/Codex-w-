# ============================================================
# sweetdream:equipment/bow/cloudtrail/hook_victim —— 「云迹」命中回调
# ------------------------------------------------------------
# 【谁调用】enchantment/cloudtrail.json 的 post_attack -> affected:"victim"
# 【执行者】@s = 被打中的那只生物
# 【★ 近战门控 ★】必须先有 hook_arrow 打上的 zx.ct_arr(那支箭), 否则是拿弩近战
#   敲人 -> 直接收工。
# 【本文件只做"筛人", 真正的结算在 apply -> fire】
#   筛两件事: ① 是箭打的 ② 打中的是生物(不是玩家)。
#   "被打中的那只在不在自己的领域里"交给 fire 判 —— 那一步要射手的 uuid,
#   拿到 uuid 之后才好按 owner 去认"自己的"领域。
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.ct_arr)直接收工
scoreboard players add #ct_dbg1 zx.meta 1
execute unless entity @e[tag=zx.ct_arr,distance=0..,limit=1] run return 0

# ⓪.5 已付账门控: 回到**射手**身上读 zx.ct_paid(坑 141 —— 箭上的标签靠不住)
#   ★ 不能写成 `execute on attacker unless score ... run return 0`: 万一 on attacker
#     解析不到就**整条命令失败**, return 根本不会执行 => 门控被跳过(坑 138 同族)。
#     改成"先置零再取值", 取不到就是 0 => 收工。
scoreboard players add #ct_dbg2 zx.meta 1
scoreboard players set #ct_p zx.meta 0
execute on attacker store result score #ct_p zx.meta run scoreboard players get @s zx.ct_paid
execute unless score #ct_p zx.meta matches 1 run return 0

# ① 受害者必须是**生物**(排除玩家)
scoreboard players add #ct_dbg3 zx.meta 1
tag @e[tag=zx.ct_v,distance=0..] remove zx.ct_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.ct_v
execute unless entity @e[tag=zx.ct_v,distance=0..,limit=1] run return 0

# ② 交给 apply(要射手的 uuid 才能认"自己的领域")
scoreboard players add #ct_dbg5 zx.meta 1
data modify storage zx:work ct.target set value "@e[tag=zx.ct_v,limit=1]"
data modify storage zx:work ct.shooter set value "@a[tag=zx.ct_pl,limit=1]"
execute unless entity @a[tag=zx.ct_pl,limit=1] run data modify storage zx:work ct.shooter set value "@p"
function sweetdream:equipment/bow/cloudtrail/apply with storage zx:work ct
