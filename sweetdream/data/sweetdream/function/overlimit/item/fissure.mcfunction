# ============================================================
# sweetdream:overlimit/item/fissure —— 给一块「超限·崩裂」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_fissure :
#   进度 advancement/overlimit/fissure 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[55.0f]}(八芒星, 编号 55)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「崩裂」能敲(见 overlimit/api/fit: 副手 zx 必须含 fissure 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·崩裂",bold:true,color:light_purple},custom_model_data={floats:[55.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"崩裂","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后崩裂更名为「超限·崩裂」，基础属","color":"gray","italic":false},{"text":"性变为：立即对自身前方 8 格的生物造成","color":"gray","italic":false},{"text":"一次相当于自身基础攻击力 ×6 的伤害并","color":"gray","italic":false},{"text":"形成一个持续 8 秒的裂缝。之后在裂缝处","color":"gray","italic":false},{"text":"的生物将每秒受到一次相当于释放者基础","color":"gray","italic":false},{"text":"攻击力的伤害。在裂缝上的生物将无法离","color":"gray","italic":false},{"text":"开裂缝。","color":"gray","italic":false}],custom_data={zx:["ol_fissure"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
