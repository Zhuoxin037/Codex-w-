# ============================================================
# sweetdream:overlimit/item/chime —— 给一块「超限·共鸣」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_chime :
#   进度 advancement/overlimit/chime 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[56.0f]}(八芒星, 编号 56)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「共鸣」能敲(见 overlimit/api/fit: 副手 zx 必须含 chime 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·共鸣",bold:true,color:light_purple},custom_model_data={floats:[56.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"共鸣","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后共鸣更名为「超限·共鸣」，基础属","color":"gray","italic":false},{"text":"性变为：使用后召唤一个术阵。之后在原","color":"gray","italic":false},{"text":"地生成一个“共鸣水晶”。其每 2 秒都会","color":"gray","italic":false},{"text":"对其 6 格内的一个生物造成一次相当于自","color":"gray","italic":false},{"text":"身最大魔力值 ×0.05 的伤害。自身释放的","color":"gray","italic":false},{"text":"法术穿过“共鸣水晶”时会立即对其 5 格","color":"gray","italic":false},{"text":"内的全部生物及释放者 3 格内的全部生物","color":"gray","italic":false},{"text":"造成一次相当于自身最大魔力值 ×0.1 的","color":"gray","italic":false},{"text":"伤害。“共鸣水晶”在另一个“共鸣水晶","color":"gray","italic":false},{"text":"”被召唤出来后或 18 秒后自毁。自毁时","color":"gray","italic":false},{"text":"会吸引一次其 5 格内的全部生物并造成相","color":"gray","italic":false},{"text":"当于自身当前魔力值 ×0.2 的伤害。","color":"gray","italic":false}],custom_data={zx:["ol_chime"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
