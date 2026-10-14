# ============================================================
# sweetdream:equipment/tool/thunder/strike —— 雷鸣: 抓到"新出现的一道闪电"
# ------------------------------------------------------------
# 【谁调用它】core/tick: `execute in <维度> as @e[distance=0..,
#   type=minecraft:lightning_bolt,tag=!zx.th_seen] at @s run function 本函数`
# 【执行者】那道闪电(位置 = 它自己)
# 【它做什么】"自身 6 格内的生物受到雷击后" -> 6 格内**持「雷鸣」的玩家**各自
#   登记一次"1 秒后原地再劈"(见 on_strike)。没人在场 = 空转。
# 【为什么先打 zx.th_seen】闪电实体要活好几刻(拖尾), 不打标记就会在它活着的
#   每一刻重复触发 —— 1 秒后会劈出一串闪电。
# 【★★ zx.th_seen 与 zx.th_own 的分工(2026-10-13 重构)★★】
#   以前只有 seen 一个标签, 它同时干了两件事 ⇒ 职责混在一起:
#     ① 去重戳(扫过就打上, 免得同一道雷被反复触发)
#     ② "这是我们自己的雷, 别触发雷鸣" —— 武器 summon 时**预先**打上
#   ② 的副作用: 引雷针/负离子/超负荷/威霆/电弧劈的雷**永远触发不了雷鸣**
#     (一出生就带 seen, core/tick 的 tag=!zx.th_seen 直接跳过它们)。
#   现在拆开:
#     · **zx.th_own** = "玩家用武器劈出来的雷" ⇒ **会**被本函数接管(触发雷鸣连锁)
#     · **zx.th_seen** = "已经被扫过了" ⇒ 不再触发(雷鸣自己劈的那道带它, 防无限连锁)
#   ⇒ 链路: 武器雷(own) → 扫到 → 触发雷鸣 → 1 秒后劈一道(seen) → 不再触发。有限。
#   ★ 想退回"自己武器的雷不触发雷鸣": 把那些 summon 的 Tags 改回 zx.th_seen 即可。
# 【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑,
#   所以三个维度要各来一遍; 而裸 @e 会跨维度搜索, distance=0.. 就是用来锁维度的
#   (它本身不过滤任何东西, 见 RULES 坑 55 / core/tick 里的说明)。
# ============================================================

tag @s add zx.th_seen
# 锚注释: 锚: 抓到过一道"新闪电"(诊断见 debug/lightning_probe)
scoreboard players add #th_dbg0 zx.meta 1
execute at @s as @a[distance=..6] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunder"]}] run function sweetdream:equipment/tool/thunder/on_strike
