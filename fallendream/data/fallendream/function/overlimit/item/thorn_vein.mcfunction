# ============================================================
# fallendream:overlimit/item/thorn_vein —— 给一块「超限·刺纹」
# 【接线】custom_data zx:["ol_thorn_vein"] 供 advancement 识别；
#   CMD=123 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/thorn_vein。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·刺纹",bold:true,color:light_purple},custom_model_data={floats:[123.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"刺纹","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后刺纹更名为「超限·刺纹」，自身魔","color":"gray","italic":false},{"text":"力值上限 +160 。自身生命值低于最大生","color":"gray","italic":false},{"text":"命值的 50% 时，攻击命中了未附有","color":"gray","italic":false},{"text":"「噬心」的生物后则为其附加「噬心」，","color":"gray","italic":false},{"text":"并获得 6 秒抗性提升二。该效果 8 秒内","color":"gray","italic":false},{"text":"最多触发一次。若自身生命值低于最大生","color":"gray","italic":false},{"text":"命值的 30% ，则额外使其 3 格内的其他","color":"gray","italic":false},{"text":"2 个生物获得「噬心」，且自身恢复 1%","color":"gray","italic":false},{"text":"魔力值，效果冷却时间缩短至 6 秒。","color":"gray","italic":false}],custom_data={zx:["ol_thorn_vein"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
