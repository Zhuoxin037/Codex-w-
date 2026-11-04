# ============================================================
# sweetdream:equipment/armor/intent/tick —— 「每使用 50 魔力 → +2 临时生命」（每刻）
# ------------------------------------------------------------
# 【谁调用它】core/tick（每刻 as @a）
# 【执行者】玩家
# 【★ 为什么每刻而不是每秒 ★】文案写"单次技能可重复触发"：一个大技能一次花 200 魔力
#   = 20 万毫魔力点 = 4 次触发。每秒只查一次的话，200 点的技能要 4 秒才能兑现完，
#   中途死了/换装就丢了。每刻最多兑现一次（50000），一秒最多兑现 1000 点魔力，够用。
# 【★ 账本 zx.it_sum 从哪来 ★】lib/mana/pay 记（毫魔力点）。与剖面的 zx.pm_sum
#   **各自独立** —— 共用一份会互相饿死（见 lib/mana/pay 头注释）。
# 【★ 50000 = 50 魔力 ×1000 ★】
# ============================================================

# 没穿「蓄意」⇒ 账本清零（别人的账本不动）
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run scoreboard players set @s zx.it_sum 0
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["intent"]}] run return 0

execute if score @s zx.it_sum matches ..49999 run return 0
scoreboard players remove @s zx.it_sum 50000

scoreboard players set #thp_v zx.meta 2
function sweetdream:lib/thp/add
