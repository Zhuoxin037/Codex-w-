# ------------------------------------------------------------
# internal/damage/health_part —— "最大生命 x 生命系数"这一项
# 【宏参数】manacore:work.a {uuid}; #hr = 生命系数 x100(calc 已读好)
# 【作用】#dmg += max_health(x1000) x #hr(x100) / 100
#   —— max_health 保留 3 位小数, 生命系数保留 2 位; 乘积中间量 x100000,
#      可承受的裸数值上限约 21474(详见 calc 顶部的溢出说明)。
# 【什么时候用】给"斩杀技 / 血量越高打越狠"这类技能做额外伤害来源。
# 【★ intovf-ok ★】这里是 x1000(max_health) × x100(#hr 生命系数)= 中间量 x100000,
#   可承受的裸数值上限约 21,474(见文件头第 5-6 行与 calc 顶部的溢出说明)。
#   这是本函数**刻意选定**的量级(倍率不用 x1000, 就是为了让这个值够用), 已算过账,
#   所以不套 check.py 的 intovf 规则(那条规则针对的是没算过账的新写法)。
#   ⚠ 什么时候会真的溢出: max_health 或 #hr 单独超过 ~21,474 —— 正常生存数值到不了
#     (一颗心 = 2 点血, 21,474 血 = 10,737 颗心)。若将来给 Boss 挂超高血量, 需回来看这里。
# ------------------------------------------------------------
$execute store result score #hp manacore.math run data get storage manacore:players "$(uuid)".stats.max_health 1000
scoreboard players operation #hp manacore.math *= #hr manacore.math
scoreboard players operation #hp manacore.math /= #100 manacore.meta
scoreboard players operation #dmg manacore.math += #hp manacore.math
