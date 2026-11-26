# ============================================================
# fallendream:overlimit/item/breathing_soil —— 给一块「超限·息土」
# 【接线】custom_data zx:["ol_breathing_soil"] 供 advancement 识别；
#   CMD=128 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/breathing_soil。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·息土",bold:true,color:light_purple},custom_model_data={floats:[128.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"息土","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后息土更名为「超限·息土」，自身最","color":"gray","italic":false},{"text":"大生命值 +20% 。自身生命值降至最大生","color":"gray","italic":false},{"text":"命值 30% 以下时，召唤一个术阵，之后召","color":"gray","italic":false},{"text":"唤一个半径 8 格的领域，持续 12 秒。该","color":"gray","italic":false},{"text":"效果 40 秒内最多触发一次。在领域中自","color":"gray","italic":false},{"text":"身每秒恢复 4 点生命值；每次受到伤害时","color":"gray","italic":false},{"text":"恢复 1 点生命值，之后使该装备的冷却时","color":"gray","italic":false},{"text":"间 -1 秒，该效果 0.5 秒内最多触发一次。","color":"gray","italic":false},{"text":"领域结束时，自身若还在领域内且生命值","color":"gray","italic":false},{"text":"未满，则恢复 12% 生命值；若生命值已满，","color":"gray","italic":false},{"text":"则改为使该装备的冷却时间 -10 秒。","color":"gray","italic":false}],custom_data={zx:["ol_breathing_soil"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
