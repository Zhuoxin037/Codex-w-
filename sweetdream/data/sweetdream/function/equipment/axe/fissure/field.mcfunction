# ============================================================
# sweetdream:equipment/axe/fissure/field —— 生成一个「裂缝」(宏 {dmg2,ft,u0,u1,u2,u3})
# ------------------------------------------------------------
# 【谁调用它】fissure/cast: execute rotated ~ 0 positioned ^ ^ ^2.5 run function ... with storage zx:work fia
# 【执行位置】落点(施法者前方 2.5 格; 超限版**不变** —— 原文只说前方打击范围变 8 格)
# 【裂缝是什么】一个 **item_display** 实体(带贴图), 标签 zx.fi_field, NBT 里存:
#   data.zx.d2 = 每秒那一段的伤害值(施放那刻基于施放者基础攻击力算好)
#   data.zx.u  = 施放者 UUID 的四个整数(击杀归属)
#   计时用计分项 zx.fi_ft(= ft 秒, 原版 5 / 超限 8), 由 lib/second 每秒 -1, 归零 kill(见 field_tick)。
# 【★ 2026-10-08 从 marker 换成 item_display ★】(用户: "崩裂 技能产生的裂缝需要对应资源包贴图来显示")
#   · 模型 sweetdream:fissure = 横平面贴地(元素 y 8..9, 照 vortex/sea/tide),
#     item_model 值写 **items/ 下的定义名**(sweetdream:fissure)
#     -> 解析到 `assets/sweetdream/items/fissure.json`。
#   · ★ scale 口径(锚点 = 暗海/漩涡): 物品模型 [0,16] 以实体位置为中心 ⇒ scale N ⇒ 平面直径 N 格。
#     裂缝伤害半径 3(field_tick 的 `distance=..3`) ⇒ 直径 6 ⇒ scale 6.0f。
#   · translation y +0.02 抬离地面防闪面。
#   · 逻辑照旧: 坐标 = 位置真相; data.zx 存伤害与归属(display 实体同样吃 `data`, 见 RULES §48)。
#   ★ 换型同步: lib/second 的三行选择器已去掉 `type=marker`(不能只认 marker)。
# 【为什么是"地面上的区域"而不是贴生物】生物离开它就不该再吃伤害;
#   施法者走远了裂缝还在原地(和神裁领域同一个道理)。
# ============================================================

$summon minecraft:item_display ~ ~ ~ {Tags:["zx.fi_field","zx.fi_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:fissure"}},brightness:{sky:6,block:6},interpolation_duration:0,transformation:{translation:[0.0f,0.02f,0.0f],scale:[6.0f,1.0f,6.0f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]},data:{zx:{d2:$(dmg2),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 给刚生成的这个 display 设计时(它带 zx.fi_new, 场上最多一个, 就近取)
#   ★ 秒数是宏参数 ft: 5(原版)/ 8(超限) —— 由 recalc 按 is_ol 写进 zx:work fia。
$execute as @e[tag=zx.fi_new,distance=..2,limit=1] run scoreboard players set @s zx.fi_ft $(ft)
tag @e[tag=zx.fi_new,distance=..2] remove zx.fi_new
