# ============================================================
# sweetdream:debug/menu —— 可点击的调试菜单
# ------------------------------------------------------------
# 【用法】/trigger zx.dbg_menu
# 【这个文件是生成的】条目表在 lib/reg/build.mcfunction 的 menu 里,
#   改完跑 python .workbuddy/gen_reg_unroll.py
# 【怎么可点击】1.21.5 起是 click_event(以前叫 clickEvent, 老写法在这一版不认):
#     {"click_event":{"action":"run_command","command":"/trigger zx.dbg_stats"}}
#   点击时**以点击者本人的身份**执行 —— 所以列的必须是玩家自己有权跑的
#   /trigger, 不能列需要 OP 的 /function。
# ============================================================

# 先清干净中间层, 免得某一项配错了读到上一项残留的值
data modify storage zx:work mi set value {name:"",obj:"",hint:""}

tellraw @s [{"text":"========== 调试菜单 ==========","color":"gold"}]
tellraw @s [{"text":"点下面的蓝色条目即可; 鼠标停上去有说明。","color":"dark_gray"}]
execute if data storage zx:reg menu[0] run function sweetdream:debug/menu_item with storage zx:reg menu[0]
execute if data storage zx:reg menu[1] run function sweetdream:debug/menu_item with storage zx:reg menu[1]
execute if data storage zx:reg menu[2] run function sweetdream:debug/menu_item with storage zx:reg menu[2]
execute if data storage zx:reg menu[3] run function sweetdream:debug/menu_item with storage zx:reg menu[3]
execute if data storage zx:reg menu[4] run function sweetdream:debug/menu_item with storage zx:reg menu[4]
execute if data storage zx:reg menu[5] run function sweetdream:debug/menu_item with storage zx:reg menu[5]
execute if data storage zx:reg menu[6] run function sweetdream:debug/menu_item with storage zx:reg menu[6]
execute if data storage zx:reg menu[7] run function sweetdream:debug/menu_item with storage zx:reg menu[7]
execute if data storage zx:reg menu[8] run function sweetdream:debug/menu_item with storage zx:reg menu[8]
execute if data storage zx:reg menu[9] run function sweetdream:debug/menu_item with storage zx:reg menu[9]
execute if data storage zx:reg menu[10] run function sweetdream:debug/menu_item with storage zx:reg menu[10]
execute if data storage zx:reg menu[11] run function sweetdream:debug/menu_item with storage zx:reg menu[11]

tellraw @s [{"text":"── 没上菜单的其它入口 ──","color":"dark_gray"}]
tellraw @s [{"text":"  用 /function 前缀 + sweetdream:debug/<名字>, 名字列表:","color":"gray"}]
tellraw @s [{"text":"    freeze / fix_noai / deepsea / deepsea_go / damage / true_damage / iframe","color":"gray"}]
tellraw @s [{"text":"    offhand / offhand_go / cold_crow / ember_immolate / leech_spine","color":"gray"}]
tellraw @s [{"text":"    iridescent_mirage / sickle / wind / num_probe","color":"gray"}]
tellraw @s [{"text":"    lore (重刷副手物品的描述, 老装备改规则后用)","color":"gray"}]
