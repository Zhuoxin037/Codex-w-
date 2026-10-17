# ============================================================
# sweetdream:equipment/axe/deep_brine/field_one —— 生成一个「领域」(宏 {dmg,u0,u1,u2,u3})
# ------------------------------------------------------------
# 【谁调用它】dom_one ④: execute at @e[tag=zx.db_cur] run function ... with storage zx:work dbf
# 【执行位置】被消耗掉「渊海」的那只生物所在处
# 【领域是什么】一个 **marker** 实体, 带标签 zx.db_field, NBT 里存:
#   data.zx.dmg = 每秒那一段的伤害(施放那刻基于施法者最大魔力值算好 = 最大魔力 ×0.03)
#   data.zx.u   = 施法者 UUID 的四个整数(击杀归属)
#   计时用计分项 zx.db_ft(= 4 秒), 由 lib/second 每秒 -1, 归零 kill(见 field_tick)。
# 【为什么用 marker 而不是贴生物】领域是**地面上的区域**: 生物离开它就不该再吃伤害
#   也不该被拉; 施法者走远了领域仍在原地(与神裁领域 / 崩裂裂缝 / 海棠漩涡同构)。
# 【为什么没有外观】文案只说"领域"(范围效果), 没要贴图/模型 ⇒ 不需要实体外观、
#   也不需要每刻铺粒子(RULES: 隐形实体才要每刻铺粒子)。范围提示由 field_tick 每秒画。
# 【半径 3 在哪】在 field_tick 的选择器与拉扯范围(distance=..3); 本文件只负责"生出来"。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.db_field","zx.db_new"],data:{zx:{dmg:$(dmg),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 给刚生成的这个 marker 设 4 秒计时(它带 zx.db_new, 就近取 —— 场上同一刻最多一个)
execute as @e[tag=zx.db_new,distance=..2,limit=1] run scoreboard players set @s zx.db_ft 4
tag @e[tag=zx.db_new,distance=..2] remove zx.db_new
