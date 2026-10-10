# ============================================================
# sweetdream:equipment/axe/dream_reader/pet_spawn —— 召唤一个“入梦体”(宏 {dmg,u0..u3})
# ------------------------------------------------------------
# 【谁调用它】dream_reader/cast(⑦, 三次)
# 【执行位置】施法者所在处(附近)
# 【入梦体是什么】一个 marker 实体, 带标签 zx.dr_pet, NBT 里存:
#   data.zx.dmg = 对目标造成的伤害(施法那刻 = 当前魔力 ×0.1 / 超限 ×0.12 算好)
#   data.zx.ol  = 这次施法是不是**超限版**(0b/1b, cast ⑤ 写进 drp; 用来打 tag zx.dr_ol)
#   data.zx.u   = 施法者 UUID 的四个整数(反查施法者 / 判 10(超限 18) 格 / 击杀归属)
#   计时用计分项 zx.dr_life(= 600 tick 的安全寿命, 由 core/tick 每刻 -1, 归零自毁)。
# 【★ 宏参数里的 byte ★】`$(ol)` 展开**自带** `b`(出来就是 `0b` / `1b`) ⇒ 只能写
#   `ol:$(ol)`; 写成 `ol:$(ol)b` 会拼成 `0bb` ⇒ 整行解析失败 ⇒ **整份函数不加载、零日志**
#   (2026-10-10 在 sculk_echo/snapshot 上踩过一次, 见那边头注)。
# 【为什么是 marker 而不是 item_display】入梦体是"会移动、会追人"的逻辑实体;
#   表现先用粒子(以后要给贴图模型, 照暗海 item_display 的路子另开生成器即可)。
# ============================================================

$summon minecraft:marker ~ ~1 ~ {Tags:["zx.dr_pet","zx.dr_new"],data:{zx:{dmg:$(dmg),ol:$(ol),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 初始化(寿命 + 超限 tag) —— 抽成 pet_init 只为让"读 NBT -> 打 tag"这几行有地方写注释
execute as @e[tag=zx.dr_new,distance=..2,limit=1] run function sweetdream:equipment/axe/dream_reader/pet_init
tag @e[tag=zx.dr_new,distance=..2] remove zx.dr_new

# 表现: 入梦的暖白金辉光（「白昼梦」调性）
#   ★ 2026-10-08 由 minecraft:soul 改 —— soul 是**暗青蓝**，那是「噬心」的调性，
#     玩家反馈"释梦的粒子像噬心武器而不是白昼梦武器"。改为暖白偏金的 dust。
particle minecraft:dust{color:[1.0,0.95,0.76],scale:1.2} ~ ~ ~ 0.3 0.3 0.3 0.02 8 normal
particle minecraft:end_rod ~ ~ ~ 0.2 0.2 0.2 0.01 4 normal
