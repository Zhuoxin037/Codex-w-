# ============================================================
# fallendream:equipment/staff/intone/again —— 引声·超限：1 秒后的第二次「全员唱一次」
# ------------------------------------------------------------
# 【执行者】施法者(玩家), 由 core/tick 扫 zx.in_next 到期调起
# 【文案】"1 秒后，使自身全部"追随者"再次触发一次被动并刷新其持续时间。"
# 【★ 为什么不用 schedule ★】schedule 调起来的函数没有 @s, 也就找不回"是谁放的"。
#   这里改成 skill 里记 zx.in_next = #now + 20, core/tick 每刻扫一次玩家分数。
# 【★ 刷新持续时间要按醒梦分档 ★】追随者 zx.j_life 满值是 200 刻, 醒梦时 300 刻
#   (见 profession/singer/create)。写死 200 会把醒梦的追随者提前收回。
# ============================================================

scoreboard players reset @s zx.in_next

tag @e[tag=zx.in_vic,distance=0..] remove zx.in_vic
tag @a[tag=zx.j_ally_cast] remove zx.j_ally_cast
tag @s add zx.j_ally_cast
tag @s add zx.in_owner
execute as @e[tag=zx.j_follower,distance=0..] at @s run function fallendream:equipment/staff/intone/again_one
tag @s remove zx.in_owner
tag @a[tag=zx.j_ally_cast] remove zx.j_ally_cast

# 这一次也确实"造成了伤害" -> 同样附加「渊海」(名单已由 pulse 抄好)
function fallendream:equipment/staff/intone/yuanhai

execute at @s run particle minecraft:note ~ ~1.6 ~ 1.0 0.6 1.0 0.3 16 normal
execute at @s run playsound minecraft:block.note_block.chime player @a ~ ~ ~ 0.8 1.5
