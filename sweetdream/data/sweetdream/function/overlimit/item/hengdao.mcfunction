# ============================================================
# sweetdream:overlimit/item/hengdao —— 给一块「超限·横刀」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_hengdao :
#   进度 advancement/overlimit/hengdao 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[38.0f]}(八芒星, 编号 38)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「横刀」能敲(见 overlimit/api/fit: 副手 zx 必须含 hengdao 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·横刀",bold:true,color:light_purple},custom_model_data={floats:[38.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"横刀","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后横刀更名为「超限·横刀」，主动技","color":"gray","italic":false},{"text":"能变为：使用后向前突击最多 3 格，若碰","color":"gray","italic":false},{"text":"到生物或障碍物则立即停下并对附近 5 格","color":"gray","italic":false},{"text":"内的全部生物造成两次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.1 的伤害。若击杀生物则重置冷","color":"gray","italic":false},{"text":"却时间。","color":"gray","italic":false}],custom_data={zx:["ol_hengdao"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
