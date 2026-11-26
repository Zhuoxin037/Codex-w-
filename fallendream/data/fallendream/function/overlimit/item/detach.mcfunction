# ============================================================
# fallendream:overlimit/item/detach —— 给一块「超限·脱离」
# 【接线】custom_data zx:["ol_detach"] 供 advancement 识别；
#   CMD=109 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/detach。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·脱离",bold:true,color:light_purple},custom_model_data={floats:[109.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"脱离","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后脱离更名为「超限·脱离」，主动技","color":"gray","italic":false},{"text":"能变为：魔力 150 · 冷却 20 秒 仅“本","color":"gray","italic":false},{"text":"我者”可使用。使用后，下一次攻击额外","color":"gray","italic":false},{"text":"造成一次相当于自身最大生命值 ×1.5 的","color":"gray","italic":false},{"text":"伤害，之后切换为“同生体”。若该次命","color":"gray","italic":false},{"text":"中的生物附有「本质」则消耗 1 层，使该","color":"gray","italic":false},{"text":"段技能伤害 +25% 并为本我者提供最大生","color":"gray","italic":false},{"text":"命值 15% 的临时生命值，持续 5 秒。切","color":"gray","italic":false},{"text":"换后的 8 秒内，同生体第一次命中该生物","color":"gray","italic":false},{"text":"时，为本我者恢复 15% 最大生命值。","color":"gray","italic":false}],custom_data={zx:["ol_detach"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
