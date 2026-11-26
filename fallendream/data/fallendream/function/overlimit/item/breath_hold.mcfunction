# ============================================================
# fallendream:overlimit/item/breath_hold —— 给一块「超限·屏息」
# 【接线】custom_data zx:["ol_breath_hold"] 供 advancement 识别；
#   CMD=92 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/breath_hold。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·屏息",bold:true,color:light_purple},custom_model_data={floats:[92.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"屏息","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后屏息更名为「超限·屏息」，自身魔","color":"gray","italic":false},{"text":"力值上限 + 140。每有 1 个空闲术阵位，","color":"gray","italic":false},{"text":"自身每秒恢复 0.5% 魔力值，且自身最大","color":"gray","italic":false},{"text":"魔力值 + 2% 。 术阵位全满时，改为每秒","color":"gray","italic":false},{"text":"恢复 5 点魔力值，且自身技能伤害 + 12%。","color":"gray","italic":false}],custom_data={zx:["ol_breath_hold"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
