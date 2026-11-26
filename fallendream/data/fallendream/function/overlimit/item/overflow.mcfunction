# ============================================================
# fallendream:overlimit/item/overflow —— 给一块「超限·溢流」
# 【接线】custom_data zx:["ol_overflow"] 供 advancement 识别；
#   CMD=89 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/overflow。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·溢流",bold:true,color:light_purple},custom_model_data={floats:[89.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"溢流","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后溢流更名为「超限·溢流」，自身魔","color":"gray","italic":false},{"text":"力值上限 + 160 ，最大生命值 + 8 。自","color":"gray","italic":false},{"text":"身被过量治疗后全部转化为临时生命值，","color":"gray","italic":false},{"text":"最多有相当于自身最大生命值 x 3 的临时","color":"gray","italic":false},{"text":"生命值。自身临时生命值减少时，自身恢","color":"gray","italic":false},{"text":"复 1 % 最大魔力值。若是因为被生物攻击","color":"gray","italic":false},{"text":"而损失则使其附加「渊海」。","color":"gray","italic":false}],custom_data={zx:["ol_overflow"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
