# ============================================================
# fallendream:overlimit/item/eagle_hat —— 给一块「超限·鹰羽帽」
# 【接线】custom_data zx:["ol_eagle_hat"] 供 advancement 识别；
#   CMD=134 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/eagle_hat。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·鹰羽帽",bold:true,color:light_purple},custom_model_data={floats:[134.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"鹰羽帽","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后鹰羽帽更名为「超限·鹰羽帽」，自","color":"gray","italic":false},{"text":"身魔力值上限 +220。关于最大魔力值技能","color":"gray","italic":false},{"text":"的伤害提升 10+6X%（X 为法球数量）。自","color":"gray","italic":false},{"text":"身获得法球和消耗法球时自身恢复 1 % 魔","color":"gray","italic":false},{"text":"力值。自身每消费 10 个法球则本装备提","color":"gray","italic":false},{"text":"供的伤害倍率改为独立乘区，持续 16 秒。","color":"gray","italic":false}],custom_data={zx:["ol_eagle_hat"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
