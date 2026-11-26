# ============================================================
# fallendream:overlimit/item/gather_energy —— 给一块「超限·聚能」
# 【接线】custom_data zx:["ol_gather_energy"] 供 advancement 识别；
#   CMD=114 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/gather_energy。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·聚能",bold:true,color:light_purple},custom_model_data={floats:[114.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"聚能","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后聚能更名为「超限·聚能」，主动技","color":"gray","italic":false},{"text":"能变为：魔力 160 · 冷却 35 秒 使用后","color":"gray","italic":false},{"text":"自身获得两个不占用普通法球上限的普通","color":"gray","italic":false},{"text":"法球。若这两个法球超出了当前法球上限","color":"gray","italic":false},{"text":"则法球在 10 秒后消失。之后自身每有一","color":"gray","italic":false},{"text":"个法球则恢复自身最大魔力值 5% 的魔力","color":"gray","italic":false},{"text":"值。若本次恢复至满魔力则也将自身血量","color":"gray","italic":false},{"text":"恢复满。","color":"gray","italic":false}],custom_data={zx:["ol_gather_energy"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
