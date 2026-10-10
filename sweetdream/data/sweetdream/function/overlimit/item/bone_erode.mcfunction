# ============================================================
# sweetdream:overlimit/item/bone_erode —— 给一块「超限·蚀骨」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_bone_erode :
#   进度 advancement/overlimit/bone_erode 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[43.0f]}(八芒星, 编号 43)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「蚀骨」能敲(见 overlimit/api/fit: 副手 zx 必须含 蚀骨 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·蚀骨",bold:true,color:light_purple},custom_model_data={floats:[43.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"蚀骨","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后蚀骨更名为「超限·蚀骨」，主动技","color":"gray","italic":false},{"text":"能变为：每次射击都会对被射击的生物的","color":"gray","italic":false},{"text":"2 格内的全部生物造成相当于本次射击所","color":"gray","italic":false},{"text":"消耗的魔力值 ×0.5 的真实伤害。若生物","color":"gray","italic":false},{"text":"上附有「噬心」则额外受到一次相当于本","color":"gray","italic":false},{"text":"次伤害 80% 的真实伤害，之后清除","color":"gray","italic":false},{"text":"「噬心」。","color":"gray","italic":false}],custom_data={zx:["ol_bone_erode"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
