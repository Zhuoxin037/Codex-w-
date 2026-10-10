# ============================================================
# sweetdream:overlimit/item/rogue_star —— 给一块「超限·游星」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_rogue_star :
#   进度 advancement/overlimit/rogue_star 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[32.0f]}(八芒星, 编号 32)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「游星」能敲(见 overlimit/api/fit: 副手 zx 必须含 rogue_star 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·游星",bold:true,color:light_purple},custom_model_data={floats:[32.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"游星","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后游星更名为「超限·游星」，主动技","color":"gray","italic":false},{"text":"能变为：锁定自身 10 格范围内的全部生","color":"gray","italic":false},{"text":"物，3 秒后对其 2 格内的全部生物造成两","color":"gray","italic":false},{"text":"次相当于自身基础攻击力 ×4 的伤害（保","color":"gray","italic":false},{"text":"底 16 点伤害）。","color":"gray","italic":false}],custom_data={zx:["ol_rogue_star"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
