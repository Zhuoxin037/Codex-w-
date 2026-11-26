# ============================================================
# fallendream:overlimit/item/agony —— 给一块「超限·苦痛」
# 【接线】custom_data zx:["ol_agony"] 供 advancement 识别；
#   CMD=140 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/agony。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·苦痛",bold:true,color:light_purple},custom_model_data={floats:[140.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"苦痛","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后苦痛更名为「超限·苦痛」，主动技","color":"gray","italic":false},{"text":"能变为：魔力 600   ·   冷却 100 秒 使","color":"gray","italic":false},{"text":"用后召唤一个术阵。之后使离自身最近的","color":"gray","italic":false},{"text":"一个生物每秒受到相当于释放者基础攻击","color":"gray","italic":false},{"text":"力 ×2 的伤害。若持续期间该生物死亡则","color":"gray","italic":false},{"text":"对其 2 格内的全部生物造成一次相当于其","color":"gray","italic":false},{"text":"最大生命值的伤害并附加一个随机标签，","color":"gray","italic":false},{"text":"之后使该效果延续到离它最近的一个生物","color":"gray","italic":false},{"text":"上。该效果持续 16 秒。使用技能期间再","color":"gray","italic":false},{"text":"次使用技能后在 4 秒内攻击一个其他生物","color":"gray","italic":false},{"text":"则可以把本武器技能效果转移到该生物上，","color":"gray","italic":false},{"text":"且持续时间 +1 秒，每个技能期间只能使","color":"gray","italic":false},{"text":"用一次。","color":"gray","italic":false}],custom_data={zx:["ol_agony"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
