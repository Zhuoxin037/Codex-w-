# ============================================================
# fallendream:overlimit/item/rain_trace —— 给一块「超限·雨迹」
# 【接线】custom_data zx:["ol_rain_trace"] 供 advancement 识别；
#   CMD=120 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/rain_trace。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·雨迹",bold:true,color:light_purple},custom_model_data={floats:[120.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"雨迹","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后雨迹更名为「超限·雨迹」，自身魔","color":"gray","italic":false},{"text":"力值上限 + 120 。自身主动技能完成实际","color":"gray","italic":false},{"text":"位移后，在位移过的地方留下持续 5 秒的","color":"gray","italic":false},{"text":"水迹。之后对在本次水迹处累计停留 1 秒","color":"gray","italic":false},{"text":"的生物附加「渊海」，之后不论其有没有","color":"gray","italic":false},{"text":"在水迹上都会每秒使其受到一次相当于释","color":"gray","italic":false},{"text":"放者基础攻击力 ×2 的伤害，持续至其停","color":"gray","italic":false},{"text":"留的水迹消失。","color":"gray","italic":false}],custom_data={zx:["ol_rain_trace"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
