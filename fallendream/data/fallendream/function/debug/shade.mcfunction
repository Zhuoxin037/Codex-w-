# ============================================================
# fallendream:debug/shade —— 当场摆一只「魂灵之影」, 不必真打一场
# ------------------------------------------------------------
# 【用法】/function fallendream:debug/shade
# 【它验什么】
#   ① 贴地 —— 模型底部应该和铁傀儡脚底齐平, 不该浮在半空/陷进地里
#   ② 铁傀儡本体是否真的隐身(看不见 = attributes/active_effects 生效)
#   ③ 模型大小/朝向/贴图是否是完整一团(不是散碎小方块)
#   ④ 头顶那圈 soul 粒子应该在模型身上, 不在两格高的空中
# 【它不验什么】伤害/索敌转移/被当弹药吃掉 —— 那些要真流程。
# 【为什么直接调 shade_make】保证 debug 看到的和实战生成的是**同一份参数**,
#   不另写一套 summon, 免得"debug 里对的、打出来是错的"。
#   代价: 这里会先把场上已有的影和载体一起清掉(debug 入口, 可以接受)。
# 【寿命】拉到 300 秒, 方便绕圈看; 载体寿命同步拉长, 否则 21 秒后模型先没了。
#   载体寿命由 lib/second 的 shade_model 每秒扣, 所以它一定会掉。
# ============================================================

kill @e[tag=zx.bd_shade]
kill @e[type=minecraft:item_display,tag=zx.bd_model]

data modify storage zx:work bd set value {uu:"__demo__",u0:0,u1:0,u2:0,u3:0}
function fallendream:equipment/bow/burst_dawn/shade_make with storage zx:work bd

scoreboard players set @e[tag=zx.bd_shade,distance=..4,limit=1] zx.bd_ft 300
scoreboard players set @e[type=minecraft:item_display,tag=zx.bd_model,distance=..4,limit=1] zx.bd_mft 320
schedule function fallendream:debug/shade_read 5t

tellraw @s [{"text":"[魂灵之影]","color":"light_purple"},{"text":" 已在脚下摆好一只（300 秒）。","color":"gray"}]
tellraw @s [{"text":"  验收：① 模型底部与铁傀儡脚底齐平（贴地）；② 看不见铁傀儡本体；③ 模型是完整一团，不是散碎方块。","color":"dark_gray"}]
tellraw @s [{"text":"  5 刻后会打印贴地诊断（载具 y / 载体 y / translation），贴地不对时把那三行发我。","color":"dark_gray"}]
tellraw @s [{"text":"  再执行一次会先清掉这只；想收掉就 /kill @e[tag=zx.bd_shade] 与 /kill @e[tag=zx.bd_model]。","color":"dark_gray"}]
