# ============================================================
# sweetdream:equipment/sword/thunder_wedge/wedge_one —— 召唤"雷楔"本体(宏)
# ------------------------------------------------------------
# 【谁调用它】thunder_wedge/cast ⑩(执行者 = 施法者, 位置 = 自身位置)
# 【宏参数】zx:work twg {dmg, uu, u0, u1, u2, u3, ol, ft}
#   dmg = 基础攻击力 ×2(施放那刻算好) / uu = 施法者 UUID 文本(收术阵用)
#   u0..u3 = UUID 四个整数(伤害归属 + 反查施法者)
#   ol = 1 表示超限版 / ft = 寿命秒数(原版 8, 超限 10)
# 【marker NBT 里存什么】data.zx.{dmg, uu, u, ol}
# 【三个标签】
#   zx.twg_wedge = 是雷楔(每秒 tick / 落雷时找它)
#   zx.twg_new   = **刚生成的这一只**(只活到本函数末尾, 用来定位打分数)
#   zx.twg_ol    = 超限版(12 格 / DoT / 结束落雷)。★ 这里**无条件**先挂上,
#                  非超限由 cast ⑩.5 按 #twg_ol 摘掉 —— 宏里拼可选标签太脆。
# 【两个计分项(不在 NBT 里)】
#   zx.twg_ft   = 剩余秒数, 由 lib/second 每秒 -1, 归零 wedge_end
#   zx.twg_own  = 施法者 UUID[0] —— cast 用它判"这只雷楔是不是我的"(同一使用者只一个)
# ★ 计分项而不是 NBT: 玩家 UUID[0] 是 32 位整数, 计分项天然能比大小/相等, 选择器也好过滤。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.twg_wedge","zx.twg_new","zx.twg_ol"],data:{zx:{dmg:$(dmg),uu:"$(uu)",u:[I;$(u0),$(u1),$(u2),$(u3)],ol:$(ol)}}}

# 寿命(刚生成的那只带 zx.twg_new; 位置上就在自己脚下, distance=..2 足够保险)
$scoreboard players set @e[tag=zx.twg_new,distance=..2,limit=1] zx.twg_ft $(ft)

# 归属标记: 这只雷楔属于谁(#twg_me 由 cast ⑦ 设成施法者 UUID[0])
scoreboard players operation @e[tag=zx.twg_new,distance=..2,limit=1] zx.twg_own = #twg_me zx.meta

# 摘掉临时标签(它只用于"刚生成的那一只", 留着会干扰下一次召唤)
#   ★ 摘 zx.twg_new **之前**先处理 zx.twg_ol ★ 上面是"无条件挂、按档摘":
#     非超限(ol:0)的那只不能留这个标签, 否则它会按 12 格 / DoT / 结束落雷跑。
execute if data storage zx:work twg{ol:0} run tag @e[tag=zx.twg_new,distance=..2] remove zx.twg_ol
tag @e[tag=zx.twg_new,distance=..2] remove zx.twg_new
