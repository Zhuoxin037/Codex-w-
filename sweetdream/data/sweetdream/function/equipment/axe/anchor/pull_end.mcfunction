# ============================================================
# sweetdream:equipment/axe/anchor/pull_end —— 沉锚 · 牵引收尾(停下那一刻)
# ------------------------------------------------------------
# 【谁调用它】anchor/pull_tick ③: zx.an_pull 归零时调一次
# 【执行者】施法者本人
# 【做什么】① 清牵引状态  ② 落地表现  ③ 以"锚的落点"(zx.an_tgt 所在处)为中心结算 impact
#   ④ 清 zx.an_tgt
# 【★ 为什么在"停下"这一端结算, 而不是 cast 里立刻结算 ★】
#   用户要的是"拉过去再炸"; 若在 cast 里结算, 目标会在你还在飞的时候就吃伤害,
#   视觉上像"伤害凭空出现在原点"。改成停下那一刻结算, 落点伤害正好在锚的位置炸开。
# 【★ 目标中途没了怎么办 ★】`at @e[tag=zx.an_tgt]` 选空 -> impact 不执行,
#   只剩清状态(不结算)。这是对的: 锚的主人没了, 炸空气没有意义。
# ============================================================

scoreboard players set @s zx.an_pull 0

execute at @s run particle minecraft:cloud ~ ~0.3 ~ 0.4 0.3 0.4 0.05 12 normal
execute at @s run playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.7 1.2

execute at @e[tag=zx.an_tgt,distance=0..,limit=1] run function sweetdream:equipment/axe/anchor/impact

tag @e[tag=zx.an_tgt] remove zx.an_tgt
