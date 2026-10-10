# ============================================================
# sweetdream:overlimit/item/shadow_blade —— 给一块「超限·影刃」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_shadow_blade :
#   进度 advancement/overlimit/shadow_blade 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[33.0f]}(八芒星, 编号 33)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「影刃」能敲(见 overlimit/api/fit: 副手 zx 必须含 shadow_blade 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·影刃",bold:true,color:light_purple},custom_model_data={floats:[33.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"影刃","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后影刃更名为「超限·影刃」，主动技","color":"gray","italic":false},{"text":"能变为：使用后立即瞬移至自身 10 格内","color":"gray","italic":false},{"text":"离自身最近的一个生物并对其造成相当于","color":"gray","italic":false},{"text":"自身基础伤害 ×8 的伤害。若使用技能后","color":"gray","italic":false},{"text":"击杀敌人时自身手持该武器则刷新该武器","color":"gray","italic":false},{"text":"冷却时间并返还 100 魔力值。若手持的是","color":"gray","italic":false},{"text":"其他武器则减少手持武器 15 秒主动技能","color":"gray","italic":false},{"text":"冷却时间。","color":"gray","italic":false}],custom_data={zx:["ol_shadow_blade"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
