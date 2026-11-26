# ============================================================
# fallendream:overlimit/item/chengxing —— 给一块「超限·秤星」
# 【接线】custom_data zx:["ol_chengxing"] 供 advancement 识别；
#   CMD=142 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/chengxing。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·秤星",bold:true,color:light_purple},custom_model_data={floats:[142.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"秤星","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后秤星更名为「超限·秤星」，主手持","color":"gray","italic":false},{"text":"时自身护甲值 +1。每次普通攻击命中生物","color":"gray","italic":false},{"text":"后，额外附带一次固定伤害，数值为（自","color":"gray","italic":false},{"text":"身护甲韧性 + 自身护甲值）×2.2。每普通","color":"gray","italic":false},{"text":"攻击命中 4 次后，下一次普通攻击的本武","color":"gray","italic":false},{"text":"器附带伤害可被当前生效的技能伤害倍率","color":"gray","italic":false},{"text":"增幅（取最高），且不会消耗增幅。","color":"gray","italic":false}],custom_data={zx:["ol_chengxing"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
