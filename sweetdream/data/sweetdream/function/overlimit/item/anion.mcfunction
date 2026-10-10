# ============================================================
# sweetdream:overlimit/item/anion —— 给一块「超限·负离子」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_anion :
#   进度 advancement/overlimit/anion 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[41.0f]}(八芒星, 编号 41)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「负离子」能敲(见 overlimit/api/fit: 副手 zx 必须含 负离子 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·负离子",bold:true,color:light_purple},custom_model_data={floats:[41.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"负离子","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后负离子更名为「超限·负离子」，主","color":"gray","italic":false},{"text":"动技能变为：使用后对自身 6 格内的全部","color":"gray","italic":false},{"text":"生物释放闪电并对其造成相当于自身当前","color":"gray","italic":false},{"text":"魔力值 ×0.12 的伤害，1 秒后再释放闪电","color":"gray","italic":false},{"text":"并对其相当于自身最大魔力值 ×0.08 的伤","color":"gray","italic":false},{"text":"害。之后 8 秒内自身召唤闪电时闪电额外","color":"gray","italic":false},{"text":"对落地处造成相当于自身当前魔力值 ×0.1","color":"gray","italic":false},{"text":"的伤害","color":"gray","italic":false}],custom_data={zx:["ol_anion"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
