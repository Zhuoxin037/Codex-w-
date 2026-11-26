# ============================================================
# fallendream:overlimit/item/last_breath —— 给一块「超限·归息」
# 【接线】custom_data zx:["ol_last_breath"] 供 advancement 识别；
#   CMD=116 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/last_breath。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·归息",bold:true,color:light_purple},custom_model_data={floats:[116.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"归息","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后归息更名为「超限·归息」，自身魔","color":"gray","italic":false},{"text":"力值上限 +180。普通近战命中了附有","color":"gray","italic":false},{"text":"「渊海」或「噬心」且仍存活的生物后，","color":"gray","italic":false},{"text":"消耗其一种效果，并为自身恢复 30% 生命","color":"gray","italic":false},{"text":"值及 3% 魔力值（优先消耗「渊海」）。","color":"gray","italic":false},{"text":"该效果 8 秒内不可再次触发，自身生命值","color":"gray","italic":false},{"text":"为满时不触发。消耗的若是「渊海」，则","color":"gray","italic":false},{"text":"额外使自身移速提高 20% ，持续 8 秒。","color":"gray","italic":false},{"text":"消耗的若是「噬心」，则使自身下一次其","color":"gray","italic":false},{"text":"他技能伤害 + 10% 。","color":"gray","italic":false}],custom_data={zx:["ol_last_breath"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
