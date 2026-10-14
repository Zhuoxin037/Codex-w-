# ============================================================
# sweetdream:equipment/bow/backstring/hook_victim —— 「退弦」命中回调
# ------------------------------------------------------------
# 【谁调用】enchantment/backstring.json 的 post_attack -> affected:"victim"
#   即"这把弩射出的箭打中生物"时由原版回调, 命中判定交给原版。
# 【执行者】@s = 被打中的那只生物
# 【★ 近战门控 ★】必须先有 hook_arrow 打上的 zx.bs_arr(那支箭), 否则是拿弩
#   近战敲人 -> 直接收工。这条门控不能删。
# 【本文件只做"筛人", 真正的结算在 apply -> fire】
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.bs_arr)直接收工
execute unless entity @e[tag=zx.bs_arr,distance=0..,limit=1] run return 0

# ⓪.5 已付账门控: 回到**射手**身上读 zx.bs_paid(坑 141)
#   ★ 不能写成 `execute on attacker unless score ... run return 0`: 万一 on attacker
#     解析不到就**整条命令失败**, return 根本不会执行 => 门控被跳过(坑 138 同族)。
#     改成"先置零再取值", 取不到就是 0 => 收工。
scoreboard players set #bs_p zx.meta 0
execute on attacker store result score #bs_p zx.meta run scoreboard players get @s zx.bs_paid
execute unless score #bs_p zx.meta matches 1 run return 0

# ① 受害者必须是**生物**(排除玩家): 标出来, 是玩家就收工
tag @e[tag=zx.bs_v,distance=0..] remove zx.bs_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.bs_v
execute unless entity @e[tag=zx.bs_v,distance=0..,limit=1] run return 0

# ② 交给 apply(需要射手 uuid / 以射手为执行者做位移与 buff)
data modify storage zx:work bs.target set value "@e[tag=zx.bs_v,limit=1]"
data modify storage zx:work bs.shooter set value "@a[tag=zx.bs_pl,limit=1]"
execute unless entity @a[tag=zx.bs_pl,limit=1] run data modify storage zx:work bs.shooter set value "@p"
function sweetdream:equipment/bow/backstring/apply with storage zx:work bs
