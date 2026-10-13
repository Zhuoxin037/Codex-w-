# ============================================================
# sweetdream:equipment/bow/dragon_tongue/hook_victim —— 「龙舌」命中回调
# ------------------------------------------------------------
# 【谁调用】enchantment/dragon_tongue.json 的 post_attack -> affected:"victim"
#   即"这把弩射出的箭打中生物"时由原版回调, 命中判定交给原版。
# 【执行者】@s = 被打中的那只生物
# 【★ 近战门控 ★】必须先有 hook_arrow 打上的 zx.dt_arr(那支箭), 否则说明是拿弩
#   近战敲人 -> 直接收工。这条门控不能删(2026-10-05 同族事故)。
# 【本文件只做"筛人", 真正的结算在 apply -> fire】
#   筛三件事: ① 是箭打的 ② 打中的是生物(不是玩家) ③ 它身上带「夜火」。
#   条件不满足 = 这一箭平凡收工(不消夜火、不放箭雨), 这正是文案的本意。
# ============================================================

# ⓪ 只处理"箭造成的命中": 近战(没被打上 zx.dt_arr)直接收工
scoreboard players add #dt_dbg1 zx.meta 1
execute unless entity @e[tag=zx.dt_arr,distance=0..,limit=1] run return 0

# ⓪.5 已付账门控: 回到**射手**身上读 zx.dt_paid(坑 141)
#   【为什么不在箭上判】射击那一刻箭可能还没进世界, 箭上的 "已付钱" 标签打不上
#     ⇒ 整把弩静默失效。记在射手身上没有这个问题。
#   【execute on attacker】从受害者跳到攻击者(本包圣骸 observe/on_damage 已经在用)。
#     攻击者不是玩家(比如别人的箭)时这一句会失败 => 走 else 分支收工, 不会误伤。
#   ★ 不能写成 `execute on attacker unless score ... run return 0`: 万一 on attacker
#     解析不到就**整条命令失败**, return 根本不会执行 => 门控被跳过(坑 138 同族)。
#     改成"先置零再取值", 取不到就是 0 => 收工。
scoreboard players add #dt_dbg2 zx.meta 1
scoreboard players set #dt_p zx.meta 0
execute on attacker store result score #dt_p zx.meta run scoreboard players get @s zx.dt_paid
execute unless score #dt_p zx.meta matches 1 run return 0

# ① 受害者必须是**生物**(排除玩家): 标出来, 是玩家就收工
scoreboard players add #dt_dbg3 zx.meta 1
tag @e[tag=zx.dt_v,distance=0..] remove zx.dt_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.dt_v
execute unless entity @e[tag=zx.dt_v,distance=0..,limit=1] run return 0

# ② 受害者必须带「夜火」—— 否则这一箭什么都不做(文案: "若射击附加了「夜火」效果
#    的生物, 则…")。用原生标签判, 与通用标签表(zx.status.yehuo)一致。
scoreboard players add #dt_dbg4 zx.meta 1
execute unless entity @s[tag=zx.status.yehuo] run return 0

# ③ 交给 apply(需要射手 uuid 才能反查"自身6格内"与"当前魔力值")
scoreboard players add #dt_dbg5 zx.meta 1
data modify storage zx:work dt.target set value "@e[tag=zx.dt_v,limit=1]"
data modify storage zx:work dt.shooter set value "@a[tag=zx.dt_pl,limit=1]"
execute unless entity @a[tag=zx.dt_pl,limit=1] run data modify storage zx:work dt.shooter set value "@p"
function sweetdream:equipment/bow/dragon_tongue/apply with storage zx:work dt
