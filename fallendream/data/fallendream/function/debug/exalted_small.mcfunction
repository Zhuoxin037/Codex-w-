# ============================================================
# fallendream:debug/exalted_small —— 原地摆一尊「千钧之形」的小石像看外观
# ------------------------------------------------------------
# 【用法】/function fallendream:debug/exalted_small   （再执行一次 = 换位置重摆）
#   · 想看大小对照: 先跑 debug/exalted_small，往前走两步再跑 debug/exalted_form，
#     两尊并排就是「千钧之形 → 崇高之形」的成长比例。
# 【它验什么 / 不验什么】
#   验: 尺寸(3.74 格 = 模型 1.872 × scale 2.00)、贴地、贴图、朝向口径(正面朝 +Z)。
#   不验: 移动/追踪/碰撞合并 —— 那些要真打一场(本体是 marker，每刻被 small_seek 推)。
# 【★ 三个数必须和 small_model.mcfunction 里完全一致 ★】
#   scale 2.00 / translation[1] 1.00 (=0.5×scale) / left_rotation 绕 Y 180°。
#   两边不一致的话，会出现"debug 里对的、打出来是错的"这种最难查的偏差。
# 【清理】core/load 每次加载会 kill @e[tag=zx.ex_demo_sm]，不会留到下次进世界。
# ============================================================

kill @e[tag=zx.ex_demo_sm]
summon minecraft:item_display ~ ~ ~ {Tags:["zx.ex_demo_sm"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"fallendream:exalted_form"}},item_display:"fixed",billboard:"fixed",interpolation_duration:0,teleport_duration:0,view_range:2.5f,shadow_radius:0.0f,width:3.0f,height:4.4f,transformation:{translation:[0.0f,1.0f,0.0f],scale:[2.0f,2.0f,2.0f],left_rotation:[0.0f,1.0f,0.0f,0.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
tellraw @s [{"text":"[千钧之形]","color":"light_purple"},{"text":" 已在脚下摆好一尊石像（3.74 格高、贴地、正面朝南）。","color":"gray"}]
tellraw @s [{"text":"  两尊对照：往前走两步再执行 debug/exalted_form，看「合成后更大」的差距。","color":"dark_gray"}]
