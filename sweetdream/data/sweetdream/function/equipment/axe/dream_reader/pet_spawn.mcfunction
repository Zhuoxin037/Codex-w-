# ============================================================
# sweetdream:equipment/axe/dream_reader/pet_spawn —— 召唤一个“入梦体”(宏 {dmg,u0..u3})
# ------------------------------------------------------------
# 【谁调用它】dream_reader/cast(⑦, 三次)
# 【执行位置】施法者所在处(附近)
# 【入梦体是什么】一个 marker 实体, 带标签 zx.dr_pet, NBT 里存:
#   data.zx.dmg = 对目标造成的伤害(施法那刻 = 当前魔力 ×0.1 算好)
#   data.zx.u   = 施法者 UUID 的四个整数(反查施法者 / 判 10 格 / 击杀归属)
#   计时用计分项 zx.dr_life(= 600 tick 的安全寿命, 由 core/tick 每刻 -1, 归零自毁)。
# 【为什么用 marker 而不是 item_display】入梦体是"会移动、会追人"的逻辑实体;
#   表现先用粒子(以后要给贴图模型, 照暗海 item_display 的路子另开生成器即可)。
# ============================================================

$summon minecraft:marker ~ ~1 ~ {Tags:["zx.dr_pet","zx.dr_new"],data:{zx:{dmg:$(dmg),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 给刚生成的这个 marker 设 30 秒安全寿命
execute as @e[tag=zx.dr_new,distance=..2,limit=1] run scoreboard players set @s zx.dr_life 600
tag @e[tag=zx.dr_new,distance=..2] remove zx.dr_new

# 表现: 入梦的幽紫魂光
particle minecraft:soul ~ ~ ~ 0.3 0.3 0.3 0.02 8 normal
particle minecraft:end_rod ~ ~ ~ 0.2 0.2 0.2 0.01 4 normal
