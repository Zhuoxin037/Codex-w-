# ============================================================
# sweetdream:debug/exalted_form —— 原地摆一尊「崇高之形」的雕像看外观
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/exalted_form      （再执行一次 = 换位置重摆）
# 【为什么单独一个入口】真实链路要 /give 崇高 → 普攻命中几次长出「千钧之形」
#   → 开主动技能铺坟场 → 等两只相撞合并, 才看得到这东西。验外观不该这么麻烦。
# 【它验什么 / 不验什么】
#   验: 尺寸、贴地、贴图、朝向口径(正面朝 +Z)、scale 后的体量。
#   不验: 走路 / 追踪 / 12 格自毁 —— 那些要真打一场(本体是 marker, 每刻被
#   big_move 推着走; 这里只是把外观单独拎出来)。
# 【★ 三个数必须和 merge.mcfunction 里完全一致 ★】
#   scale 3.00 / translation[1] 1.50 (=0.5×scale) / left_rotation 绕 Y 180°。
#   两边不一致的话, 你会看到"debug 里对的、打出来是错的"这种最难查的偏差。
# 【清理】core/load 每次加载会 kill @e[tag=zx.ex_demo], 不会留到下次进世界。
# ============================================================

kill @e[tag=zx.ex_demo]
summon minecraft:item_display ~ ~ ~ {Tags:["zx.ex_demo"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:exalted_form"}},item_display:"fixed",billboard:"fixed",interpolation_duration:0,teleport_duration:0,view_range:3.5f,shadow_radius:0.0f,width:5.6f,height:6.8f,transformation:{translation:[0.0f,1.5f,0.0f],scale:[3.0f,3.0f,3.0f],left_rotation:[0.0f,1.0f,0.0f,0.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
tellraw @s [{"text":"[崇高之形]","color":"gold"},{"text":" 已在脚下摆好一尊雕像（5.62 格高、贴地、正面朝南 = 你面朝北时正对着它）。","color":"gray"}]
tellraw @s [{"text":"  再做一次会先收掉旧的；真实效果请用 /give 崇高 打一场。","color":"dark_gray"}]
