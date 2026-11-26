# ============================================================
# fallendream:overlimit/item/lvshuang —— 给一块「超限·履霜」
# 【接线】custom_data zx:["ol_lvshuang"] 供 advancement 识别；
#   CMD=138 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/lvshuang。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·履霜",bold:true,color:light_purple},custom_model_data={floats:[138.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"履霜","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后履霜更名为「超限·履霜」，自身魔","color":"gray","italic":false},{"text":"力值上限 +80 。每移动 1 格，在脚下留","color":"gray","italic":false},{"text":"下一片霜，最多同时存在 24 片，每片持","color":"gray","italic":false},{"text":"续 16 秒。生物踩到霜时获得 5 秒缓慢Ⅱ","color":"gray","italic":false},{"text":"并且会被冰冻 1 秒；自身踩到霜时获得 8","color":"gray","italic":false},{"text":"秒迅捷二，且不消耗该片霜。自身停留在","color":"gray","italic":false},{"text":"霜上时每 0.5 秒可以增加当前位置的霜的","color":"gray","italic":false},{"text":"层数，最高 3 层且增加的层数不会占用霜","color":"gray","italic":false},{"text":"上限。每增加一层则生物踩到霜后冷冻的","color":"gray","italic":false},{"text":"时间 +1 秒。自身使用位移类技能时产生","color":"gray","italic":false},{"text":"的霜将直接提升为 3 层。","color":"gray","italic":false}],custom_data={zx:["ol_lvshuang"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
