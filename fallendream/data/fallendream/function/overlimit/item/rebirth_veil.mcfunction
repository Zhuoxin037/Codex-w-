# ============================================================
# fallendream:overlimit/item/rebirth_veil —— 给一块「超限·复纱」
# 【接线】custom_data zx:["ol_rebirth_veil"] 供 advancement 识别；
#   CMD=121 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/rebirth_veil。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·复纱",bold:true,color:light_purple},custom_model_data={floats:[121.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"复纱","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后复纱更名为「超限·复纱」，最大生","color":"gray","italic":false},{"text":"命值 + 8 。同生体进入再生阶段后，本我","color":"gray","italic":false},{"text":"者每累计实际造成相当于自身基础攻击力","color":"gray","italic":false},{"text":"×4 的伤害，则使本次再生剩余时间缩短 2","color":"gray","italic":false},{"text":"秒。若同生体死亡后自身在 12 秒内将其","color":"gray","italic":false},{"text":"重新召唤出来，则召唤时对自身 12 格内","color":"gray","italic":false},{"text":"的生物造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.03 的伤害并击退 2 格，且自身最大魔","color":"gray","italic":false},{"text":"力值 +20% ，持续 12 秒。之后本我者和","color":"gray","italic":false},{"text":"同生体每秒恢复 8% 生命值，持续 4 秒。","color":"gray","italic":false}],custom_data={zx:["ol_rebirth_veil"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
