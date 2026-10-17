# ============================================================
# sweetdream:equipment/sword/thunder_wedge/wedge_one —— 召唤"雷楔"本体(宏)
# ------------------------------------------------------------
# 【谁调用它】thunder_wedge/cast ⑩(执行者 = 施法者, 位置 = 自身位置)
# 【宏参数】zx:work twg {dmg, uu, u0, u1, u2, u3}
#   dmg = 基础攻击力 ×2(施放那刻算好) / uu = 施法者 UUID 文本(收术阵用)
#   u0..u3 = UUID 四个整数(伤害归属 + 反查施法者)
# 【marker NBT 里存什么】data.zx.{dmg, uu, u}
# 【两个计分项(不在 NBT 里)】
#   zx.twg_ft   = 剩余秒数(8), 由 lib/second 每秒 -1, 归零 wedge_end
#   zx.twg_own  = 施法者 UUID[0] —— cast 用它判"这只雷楔是不是我的"(同一使用者只一个)
# ★ 计分项而不是 NBT: 玩家 UUID[0] 是 32 位整数, 计分项天然能比大小/相等, 选择器也好过滤。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.twg_wedge","zx.twg_new"],data:{zx:{dmg:$(dmg),uu:"$(uu)",u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 8 秒计时(刚生成的那只带 zx.twg_new; 位置上就在自己脚下, distance=..2 足够保险)
scoreboard players set @e[tag=zx.twg_new,distance=..2,limit=1] zx.twg_ft 8

# 归属标记: 这只雷楔属于谁(#twg_me 由 cast ⑦ 设成施法者 UUID[0])
scoreboard players operation @e[tag=zx.twg_new,distance=..2,limit=1] zx.twg_own = #twg_me zx.meta

# 摘掉临时标签(它只用于"刚生成的那一只", 留着会干扰下一次召唤)
tag @e[tag=zx.twg_new,distance=..2] remove zx.twg_new
