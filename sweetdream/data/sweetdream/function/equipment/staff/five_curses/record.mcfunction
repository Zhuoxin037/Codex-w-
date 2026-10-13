# ============================================================
# sweetdream:equipment/staff/five_curses/record —— 第五世: 累计目标受到的伤害
# ------------------------------------------------------------
# 【执行者】被打的那一只(@s = 目标)   【谁调它】internal/damage/one(在 deal 之前)
# 【文案】「第五世: 记录目标在接下来最多 5 秒内受到的全部伤害。」
# 【为什么挂在 internal/damage/one】本包**所有**自行结算的伤害最后都从 one → deal
#   这一条路打出去; 挂在 deal 之前, 记到的就是"这一下打出去多少"。
#   ★ 局限: 走原版路径的伤害(例如玩家用别的东西平砍、摔落、燃烧)不经过这里,
#     不会被累计 —— 文案的"全部"在本包能做到的范围内理解为"全部走本包管道的伤害"。
# 【单位】zx.fcv_rec 是"伤害 ×1000"(定点), 与终世结算那边的口径一致。
# 【★ 为什么只在标签 zx.fcv_5 存在时跑 ★】该标签在推进到第五世时打上、世咒清除时
#   摘掉 ⇒ "标签在" ⟺ "记录窗口开着", 不用另外再看 zx.fcv_t。
# ============================================================

scoreboard players set #fcv_rec_now zx.meta 0
execute if data storage zx:work a.num store result score #fcv_rec_now zx.meta run data get storage zx:work a.num 1000
execute unless data storage zx:work a.num store result score #fcv_rec_now zx.meta run data get storage zx:work a.damage 1000
scoreboard players operation @s zx.fcv_rec += #fcv_rec_now zx.meta
