# ------------------------------------------------------------
# internal/damage/health_part —— "最大生命 x 生命系数"这一项
# 【宏参数】manacore:work.a {uuid}; #hr = 生命系数 x100(calc 已读好)
# 【作用】#dmg += max_health(x1000) x #hr(x100) / 100
#   —— max_health 保留 3 位小数, 生命系数保留 2 位; 乘积中间量 x100000,
#      可承受的裸数值上限约 21474(详见 calc 顶部的溢出说明)。
# 【什么时候用】给"斩杀技 / 血量越高打越狠"这类技能做额外伤害来源。
# ------------------------------------------------------------
$execute store result score #hp manacore.math run data get storage manacore:players "$(uuid)".stats.max_health 1000
scoreboard players operation #hp manacore.math *= #hr manacore.math
scoreboard players operation #hp manacore.math /= #100 manacore.meta
scoreboard players operation #dmg manacore.math += #hp manacore.math
