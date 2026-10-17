# ============================================================
# sweetdream:equipment/staff/long_night/field_one —— 生成「夜原」(宏 {uu,u0,u1,u2,u3})
# ------------------------------------------------------------
# 【谁调用它】skill ⑥: execute at @s run function ... with storage zx:work lnf
# 【执行位置】施法者所在处
# 【夜原是什么】一个 **marker** 实体, 带标签 zx.ln_field, NBT 里存:
#   data.zx.uu = 施法者 uuid **文本** —— 收场时拿它当键去 api/formation/remove(同威霆)
#   data.zx.u  = 施法者 UUID 的四个整数 —— 每秒反查施法者(回魔/消耗的余烬被动要认人)
#   计时用计分项 zx.ln_ft(= 8 秒); 已消耗次数用 zx.ln_n(每秒 -1 / +1, 见 field_tick)。
# 【为什么用 marker 而不是贴生物】夜原是**地面上的区域**: 施法者走远了它还在原地
#   (与神裁领域 / 崩裂裂缝 / 重溟领域同构)。
# 【半径 6 在哪】field_tick 的圈选(distance=..6); 本文件只负责"生出来"。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.ln_field","zx.ln_new"],data:{zx:{uu:"$(uu)",u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 给刚生成的这个 marker 设 8 秒计时(它带 zx.ln_new, 就近取 —— 同一刻最多一个)
execute as @e[tag=zx.ln_new,distance=..2,limit=1] run scoreboard players set @s zx.ln_ft 8
tag @e[tag=zx.ln_new,distance=..2] remove zx.ln_new
