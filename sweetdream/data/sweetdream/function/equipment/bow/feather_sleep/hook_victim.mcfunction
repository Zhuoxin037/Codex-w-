# ============================================================
# sweetdream:equipment/bow/feather_sleep/hook_victim —— 「眠羽」命中回调
# ------------------------------------------------------------
# 【谁调用它】enchantment/feather_sleep.json 的 post_attack -> affected:"victim"
#   即"这把弩射出的箭打中生物"时由原版回调, 命中判定交给原版。
# 【执行者】@s = 被打中的那只生物
# 【本文件只做"筛人", 真正的结算在 apply -> fire】(照龙舌/蚀骨的分层)
#   筛四件事: ① 是箭打的 ② 这一发付过账 ③ 打中的是生物(不是玩家) ④ 它带「白昼梦」。
# 【诊断锚】dbg1 进来几次 / dbg2 过了箭门控 / dbg3 过了付账门控 / dbg4 过了生物门控 /
#   dbg5 走到 apply。**数字从哪一级开始是 0 或空白, 链就断在那一级**
#   (用 /function sweetdream:debug/bow_probe 看)。
# ============================================================

scoreboard players add #fs_dbg1 zx.meta 1

# ⓪ 只处理"箭造成的命中": 近战(没有 zx.fs_arr)直接收工
execute unless entity @e[tag=zx.fs_arr,distance=0..,limit=1] run return 0
scoreboard players add #fs_dbg2 zx.meta 1

# ⓪.5 已付账门控: 回到**射手**身上读 zx.fs_paid(坑 141)
#   【为什么不在箭上判】射击那一刻箭可能还没进世界, 箭上的标签打不上 ⇒ 整把弩静默失效。
#   ★ 不能写成 `execute on attacker unless score ... run return 0`: 万一 on attacker
#     解析不到(比如是别人的箭), 就**整条命令失败**, return 根本不会执行 => 门控被跳过。
#     改成"先置零再取值", 取不到就是 0 => 收工。
scoreboard players set #fs_p zx.meta 0
execute on attacker store result score #fs_p zx.meta run scoreboard players get @s zx.fs_paid
execute unless score #fs_p zx.meta matches 1 run return 0
scoreboard players add #fs_dbg3 zx.meta 1

# ① 受害者必须是**生物**(排除玩家)
tag @e[tag=zx.fs_v,distance=0..] remove zx.fs_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.fs_v
execute unless entity @e[tag=zx.fs_v,distance=0..,limit=1] run return 0
scoreboard players add #fs_dbg4 zx.meta 1

# ② 受害者必须带「白昼梦」(不消任何标签的先决条件)
execute unless entity @s[tag=zx.status.dream] run return 0

# ③ 交给 apply(需要射手 uuid 才能算"自身最大魔力值"与归属)
scoreboard players add #fs_dbg5 zx.meta 1
data modify storage zx:work fs.target set value "@e[tag=zx.fs_v,limit=1]"
data modify storage zx:work fs.shooter set value "@a[tag=zx.fs_pl,limit=1]"
execute unless entity @a[tag=zx.fs_pl,limit=1] run data modify storage zx:work fs.shooter set value "@p"
function sweetdream:equipment/bow/feather_sleep/apply with storage zx:work fs
