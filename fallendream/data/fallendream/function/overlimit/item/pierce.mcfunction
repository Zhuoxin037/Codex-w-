# ============================================================
# fallendream:overlimit/item/pierce —— 给一块「超限·穿孔」
# 【接线】custom_data zx:["ol_pierce"] 供 advancement 识别；
#   CMD=119 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/pierce。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·穿孔",bold:true,color:light_purple},custom_model_data={floats:[119.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"穿孔","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后穿孔更名为「超限·穿孔」，主动技","color":"gray","italic":false},{"text":"能变为：魔力 50 每次射击时消耗 1 个法","color":"gray","italic":false},{"text":"球，本次箭矢贯穿路径上的全部生物并对","color":"gray","italic":false},{"text":"命中的生物额外附加一次相当于自身最大","color":"gray","italic":false},{"text":"魔力值 ×0.04 的伤害。同一箭的命中了至","color":"gray","italic":false},{"text":"少 3 个生物时，该箭接下来的伤害提升为","color":"gray","italic":false},{"text":"相当于自身最大魔力值 ×0.08 ，之后使其","color":"gray","italic":false},{"text":"护甲值及护甲韧性 -30% ，持续 5 秒。","color":"gray","italic":false}],custom_data={zx:["ol_pierce"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
