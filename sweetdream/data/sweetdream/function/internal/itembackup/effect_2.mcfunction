# ============================================================
# sweetdream:internal/itembackup/effect_2 —— 回手: 把盔甲架上备份的武器还回来
# ------------------------------------------------------------
# 【宏参数】zx:work a {uuid}     【执行者】玩家本人(@s)
# 【调用】function sweetdream:internal/itembackup/effect_2 with storage zx:work a
# ------------------------------------------------------------
# 【★ 从哪只手用, 就还回哪只手 ★】本次修复的重点
#   老版本写死 weapon.mainhand。武器放副手右键时, 架子主手槽里还留着上一次
#   主手那把, 于是主手的装备被直接覆盖掉(item replace 不会掉落, 是凭空消失)。
#   现在看标签 zx.ret_off(由 effect_1 在消耗那一刻判定好):
#       有   = 这一下是副手放的 -> 写回 weapon.offhand
#       没有 = 主手             -> 写回 weapon.mainhand
# 【★ 为什么先检查架子上有没有东西 ★】
#   item replace from 一个空槽 = 把空气写进手里。万一备份没做成
#   (架子刚重建 / 极端时序), 不加这道判断就会把玩家手里的东西清成空气。
#   宁可"这一下没还回来", 也不能把玩家别的装备吃掉 —— 这是最后一道保险。
# 【关于宏】只要一行里出现 $(变量), 它就必须以 $ 开头; 反之不含变量的行
#   不能加 $ (否则加载时报 Macro without variables, 整个函数作废)。
#   历史上这里就是因为少了一个 $ 而整条回手失效。
# ============================================================

# ① 副手触发 -> 从架子的副手槽还回副手
#    execute in overworld: 架子固定住在主世界, 玩家可能在下界/末地,
#    所以把"找实体"的维度切过去, @s 仍然指向玩家本人。
$execute if entity @s[tag=zx.ret_off] in minecraft:overworld if items entity @e[tag=test_stand_$(uuid),limit=1] weapon.offhand * run item replace entity @s weapon.offhand from entity @e[tag=test_stand_$(uuid),limit=1] weapon.offhand

# ② 主手触发 -> 从架子的主手槽还回主手
$execute unless entity @s[tag=zx.ret_off] in minecraft:overworld if items entity @e[tag=test_stand_$(uuid),limit=1] weapon.mainhand * run item replace entity @s weapon.mainhand from entity @e[tag=test_stand_$(uuid),limit=1] weapon.mainhand
