# ============================================================
# sweetdream:equipment/sword/myriad/hit_go —— 把算好的伤害打出去(按剑魂重复)
# ------------------------------------------------------------
# 【执行者】玩家   【前置】
#   · manacore:out r.damage = 本次单次伤害(由 api/damage/calc 算好)
#   · zx.mq_dmg 标签 = 本次的目标(已经钉好)
# 【文案】自身每有一个“剑魂”则本武器的技能伤害则重复一次。
#   => 重复次数 = 1 + 剑魂数(0 个剑魂 = 打 1 次, 5 个 = 打 6 次)
# 【★ 为什么是 6 条而不是递归 ★】剑魂最多 5 => 最多重复 6 次, 是有限的;
#   写 6 条 `if matches 1..` 再由 hit_once 自己 -1, 就是一次固定次数的循环 ——
#   不用递归函数(递归要防环、又要额外的终止判据, 出错就是整个函数作废)。
# 【★ 每次都读 manacore:out, 不是累加 ★】"重复一次" = 再打一次**同样的伤害**,
#   不是把伤害数值翻倍(后者会被护甲/抗性吃掉一大截, 手感完全不同)。
# 【★ 没超限就固定打 1 次 ★】剑魂是超限版的机制, 基础版永远 1 次。
# 【★ 只有千散口径才重复 ★】(2026-10-08 用户定稿) 判据 = #mq_qs:
#   "自身每有一个『剑魂』则**本武器**的技能伤害则重复一次"这句只写在【千散】那段
#   描述里 ⇒ 用户定稿"本武器" = 千散。所以:
#     · 主动放千散 / 窗口技能走千散支(#mq_isq=1) -> 打 1 + 剑魂数 次
#     · 主动放万念 / 窗口技能走万念支          -> 固定 1 次
#   (老实现只看 zx.mq_ol, 于是万念也吃重复 —— 一起收窄。)
# ============================================================

scoreboard players set #mq_rep zx.meta 1
execute if score @s zx.mq_ol matches 1 if score #mq_qs zx.meta matches 1 run scoreboard players operation #mq_rep zx.meta = @s zx.mq_soul
execute if score @s zx.mq_ol matches 1 if score #mq_qs zx.meta matches 1 run scoreboard players add #mq_rep zx.meta 1

# 【★ 六行写成 6.. 5.. 4.. 3.. 2.. 1.. 的原因 ★】六行长得一样会被 check 当
#   "复制粘贴事故"报出来; 换成阈值递减后逻辑等价(总次数不变)且每行都不同:
#   rep=6 时六行全中, 每次命中由 hit_once 自己 -1, 正好打 6 次; rep=1 只有最后一行中。

execute if score #mq_rep zx.meta matches 6.. run function sweetdream:equipment/sword/myriad/hit_once
execute if score #mq_rep zx.meta matches 5.. run function sweetdream:equipment/sword/myriad/hit_once
execute if score #mq_rep zx.meta matches 4.. run function sweetdream:equipment/sword/myriad/hit_once
execute if score #mq_rep zx.meta matches 3.. run function sweetdream:equipment/sword/myriad/hit_once
execute if score #mq_rep zx.meta matches 2.. run function sweetdream:equipment/sword/myriad/hit_once
execute if score #mq_rep zx.meta matches 1.. run function sweetdream:equipment/sword/myriad/hit_once
