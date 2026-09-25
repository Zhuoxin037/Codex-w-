# ============================================================
# sweetdream:internal/itembackup/effect_2 —— 回手: 把盔甲架上备份的武器拿回主手
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {uuid}
# 【调用】function sweetdream:internal/itembackup/effect_2 with storage zx:work a
# 【原来为什么没回手】这一行原来是以 execute 开头的, 开头没有 $ ——
#   而没有 $ 的行【不会做宏替换】。于是 $(uuid) 被原样送进了命令,
#   选择器就变成"找一个 CustomName 字面等于 $(uuid) 的盔甲架",
#   当然永远选不中, item replace 失败, 手上自然什么都没有。
#   对比一下同目录的 itemreplace_mainhand_2.mcfunction: 那一行开头有 $,
#   所以"复制到盔甲架"是好的 —— 这正是你能看到复制有效、却没有回手的原因。
# 【规则】只要一行里出现 $(变量), 它就必须以 $ 开头; 反之不含变量的行
#   不能加 $ (否则加载时报 Macro without variables, 整个函数作废)。
# ============================================================

# execute in overworld: 架子固定住在主世界, 这样玩家在下界/末地也能回手。
# 注意 @s(目标)仍然是玩家本人, 只把"找实体"的维度切到了主世界。
$execute in minecraft:overworld run item replace entity @s weapon.mainhand from entity @e[tag=test_stand_$(uuid),limit=1] weapon.mainhand
