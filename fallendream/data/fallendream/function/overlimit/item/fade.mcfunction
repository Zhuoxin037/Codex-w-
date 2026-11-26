# ============================================================
# fallendream:overlimit/item/fade —— 给一块「超限·息影」
# 【接线】custom_data zx:["ol_fade"] 供 advancement 识别；
#   CMD=94 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/fade。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·息影",bold:true,color:light_purple},custom_model_data={floats:[94.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"息影","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后息影更名为「超限·息影」，自身魔","color":"gray","italic":false},{"text":"力值上限＋160，自身技能冷却时间－ 10% 。","color":"gray","italic":false},{"text":"自身释放技能后若在 10 秒内没有再次释","color":"gray","italic":false},{"text":"放技能则使当前手持装备冷却时间减半（","color":"gray","italic":false},{"text":"至少减少 10 秒）且自身恢复 5% 魔力值。","color":"gray","italic":false},{"text":"释放该装备提供的减冷却后的技能时该技","color":"gray","italic":false},{"text":"能伤害 + 10% 并使受到伤害的生物额外附","color":"gray","italic":false},{"text":"加五大标签的随机一种。","color":"gray","italic":false}],custom_data={zx:["ol_fade"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
