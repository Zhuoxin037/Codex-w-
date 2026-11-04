# ============================================================
# sweetdream:lib/thp/clear —— 清空临时生命（硬清：连 absorption 效果一起撤）
# ------------------------------------------------------------
# 【谁调用它】lib/thp/tick（到期 / 被打空）
# 【执行者】玩家(@s)
# 【★ 为什么要清 effect ★】账本归零之后如果吸收还挂在身上，玩家会白拿一层黄心，
#   而我们的账本是"这层黄心归谁"的唯一真相 —— 两边不一致就是白送血。
#   `effect clear` 会连"法师预言·新生"给的吸收一起清掉：两者本来就互斥（见
#   lib/thp/set 文件头），这里按独占处理。
# ============================================================

execute if entity @s[tag=zx.thp_on] run attribute @s minecraft:max_absorption modifier remove sweetdream:thp_cap
tag @s remove zx.thp_on
effect clear @s minecraft:absorption
scoreboard players set @s zx.thp 0
scoreboard players set @s zx.thp_end 0


# ===== 批 20（2026-10-27）：临时生命清空的回调（蓄意：抗性提升Ⅱ + 迅捷Ⅲ）=====
#   ★ 执行者仍是玩家；没穿「蓄意」时 on_empty 第一行就会返回。
function sweetdream:equipment/armor/intent/on_empty
