# ============================================================
# fallendream:overlimit/item/external_power —— 给一块「超限·体外供能装置」
# 【接线】custom_data zx:["ol_external_power"] 供 advancement 识别；
#   CMD=110 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/external_power。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·体外供能装置",bold:true,color:light_purple},custom_model_data={floats:[110.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"体外供能装置","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后体外供能装置更名为「超限·体外供","color":"gray","italic":false},{"text":"能装置」，自身生命值上限 +16。自身当","color":"gray","italic":false},{"text":"前魔力值大于最大魔力值的 70% 时，获得","color":"gray","italic":false},{"text":"再生Ⅱ且自身最大生命值 +12%。使用技能","color":"gray","italic":false},{"text":"前，若自身当前魔力值大于最大魔力值的","color":"gray","italic":false},{"text":"70%，则技能成功使用后返还本次消耗魔力","color":"gray","italic":false},{"text":"的 10%。自身当前魔力值低于最大魔力值","color":"gray","italic":false},{"text":"的 70% 时，每秒额外恢复 8 魔力值。","color":"gray","italic":false}],custom_data={zx:["ol_external_power"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
