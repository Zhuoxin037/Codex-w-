# ============================================================
# sweetdream:overlimit/item/cold_crow —— 给一块「超限·寒鸦」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_cold_crow :
#   进度 advancement/overlimit/cold_crow 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[42.0f]}(八芒星, 编号 42)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「寒鸦」能敲(见 overlimit/api/fit: 副手 zx 必须含 寒鸦 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·寒鸦",bold:true,color:light_purple},custom_model_data={floats:[42.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"寒鸦","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后寒鸦更名为「超限·寒鸦」，主动技","color":"gray","italic":false},{"text":"能新加：「冰凌」到达 4 层并射击后若自","color":"gray","italic":false},{"text":"身魔力值大于 150，则消耗 120 魔力值并","color":"gray","italic":false},{"text":"使「冰凌」恢复至 3 层。","color":"gray","italic":false}],custom_data={zx:["ol_cold_crow"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
