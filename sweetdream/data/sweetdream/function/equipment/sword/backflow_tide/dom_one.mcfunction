# ============================================================
# sweetdream:equipment/sword/backflow_tide/dom_one —— 清「渊海」+ 额外伤害 + 向外击退
# ------------------------------------------------------------
# 【谁调用它】cast ⑨   【执行者】施法者   【位置】他所在处
# 【目标】zx.bft_src = 本轮就近挑中的那一个"带渊海的命中者"(场上最多一个)
# 【★ 身份不能换 ★】消耗走统一入口 lib/mark_consume; 余烬只认 **@s**(消耗者),
#   by 默认也是 @s。所以这里**绝不能** `as <目标>` —— 一旦换身份, 余烬就认错人。
#   目标只能写成**选择器字符串**塞进 zx:work a.target(同 deep_brine/dom_one)。
# 【★ 只有真的摘掉才结算后半段 ★】
#   · ok   = 它身上真有这个标签(防"选完到消耗之间被别的效果摘掉")。
#   · done = 穿「永恒」时把标签**补回来**了 = 没清除 -> 击退/额外伤害都不该有。
#   两个字段都由 lib/mark_consume / mark_take 写。
# 【额外伤害打谁 —— 2026-10-17 用户拍板: 两者都吃】
#   ① 被清渊海的那只本体(zx.bft_src)
#   ② 它 2 格内的其他生物(zx.bft_push, 不含本体)
#   两者统一挂到 zx.bft_extra 上一次投递 —— 一次 damage 调用只吃一个选择器。
# 【向外击退最多 2 格】"向外" = 背离被清渊海的那只(zx.bft_src)。
#   手法照 iridescent/eff_3(tp 到局部坐标 ^ ^ ^-1), 但原文是"最多 2 格" =>
#   **分两次各推 1 格**, 每次先判目标点方块可替换 —— 撞墙就只推了 1 格(或多推不动),
#   这正是"最多"的语义。不用 Motion 冲量: 冲量的距离由摩擦决定, 且写不出朝向。
# ============================================================

# ① 消耗它的「渊海」(执行者/身份仍是施法者本人)
data modify storage zx:work a set value {target:"@e[tag=zx.bft_src,distance=0..,limit=1]",mark:"yuanhai"}
function sweetdream:lib/mark_consume

# ② 它身上本来就没有 -> 收工
execute unless data storage zx:work mc{ok:1b} run return 0
# ③ 被「永恒」补回来了 = 没真的清除 -> 后半段不结算
execute if data storage zx:work mc{done:1b} run return 0

# ④ 圈出"它 2 格内的其他生物"(不包含它自己)
tag @e[tag=zx.bft_push,distance=0..] remove zx.bft_push
tag @e[tag=zx.bft_extra,distance=0..] remove zx.bft_extra
execute at @e[tag=zx.bft_src,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=0.01..2,tag=!zx.bft_src] add zx.bft_push

# ⑤ 额外伤害名单 = 本体 + 2 格内其他
tag @e[tag=zx.bft_src,distance=0..] add zx.bft_extra
execute at @e[tag=zx.bft_src,distance=0..,limit=1] run tag @e[tag=zx.bft_push,distance=0..] add zx.bft_extra

# ⑥ 额外伤害: 最大魔力值 ×0.07(值已由 cast ⑦ 算好)
#   ★ distance=0.. 显式写: 别的函数可能改过执行维度, 不带它 @e 会跨维度全搜
data modify storage zx:in arg set value {target:"@e[tag=zx.bft_extra,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work bft.dmg2
execute at @s run function sweetdream:api/damage

# ⑦ 向外击退最多 2 格(= 连推两次, 每次 1 格; @s 换成每个被推的生物)
execute at @e[tag=zx.bft_src,distance=0..,limit=1] as @e[tag=zx.bft_push,distance=0..] run function sweetdream:equipment/sword/backflow_tide/push_one

# ⑧ 表现: 渊海被抽干的一圈水环
execute at @e[tag=zx.bft_src,distance=0..,limit=1] run particle minecraft:splash ~ ~0.6 ~ 1.6 0.4 1.6 0.08 40 normal
execute at @e[tag=zx.bft_src,distance=0..,limit=1] run particle minecraft:bubble ~ ~0.8 ~ 1.0 0.6 1.0 0.05 24 normal
execute at @e[tag=zx.bft_src,distance=0..,limit=1] run playsound minecraft:entity.dolphin.splash player @a ~ ~ ~ 0.9 1.1
