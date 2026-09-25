# ------------------------------------------------------------
# internal/debug/warn_mana —— 魔力越界警告
# 【宏参数】manacore:work.a {uuid}
# 【修复建议】用 api/mana/set 重新设定, 或提高 max_mana, 让它回到合法区间。
# ------------------------------------------------------------
scoreboard players add #warn manacore.math 1
$tellraw @s [{"text":"[校验] 当前魔力 > 最大魔力: ","color":"yellow"},{"text":"$(uuid)","color":"white"}]
