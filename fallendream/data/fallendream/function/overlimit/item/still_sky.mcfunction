# ============================================================
# fallendream:overlimit/item/still_sky —— 给一块「超限·静穹」
# 【接线】custom_data zx:["ol_still_sky"] 供 advancement 识别；
#   CMD=122 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/still_sky。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·静穹",bold:true,color:light_purple},custom_model_data={floats:[122.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"静穹","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后静穹更名为「超限·静穹」，最大魔","color":"gray","italic":false},{"text":"力值 +120。普通法球保持满额 4 秒后获","color":"gray","italic":false},{"text":"得一层「星帷」，至多三层，每层独立保","color":"gray","italic":false},{"text":"留 16 秒。✦ 星帷受到生物造成的伤害后，","color":"gray","italic":false},{"text":"若仍有普通法球，则消耗一个普通法球与","color":"gray","italic":false},{"text":"一层星帷，获得 8 秒的相当于自身最大生","color":"gray","italic":false},{"text":"命值 ×0.1 的临时生命（保底 8 点），并","color":"gray","italic":false},{"text":"使伤害来源获得 2 秒缓慢Ⅲ并使其附加","color":"gray","italic":false},{"text":"「白昼梦」。若自身在 8 秒内消耗了三层","color":"gray","italic":false},{"text":"「星帷」，则自身获得 4 秒抗性提升五且","color":"gray","italic":false},{"text":"自身移动速度 +40% 。","color":"gray","italic":false}],custom_data={zx:["ol_still_sky"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
