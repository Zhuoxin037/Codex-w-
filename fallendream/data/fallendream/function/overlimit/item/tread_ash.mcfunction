# ============================================================
# fallendream:overlimit/item/tread_ash —— 给一块「超限·踏灰」
# 【接线】custom_data zx:["ol_tread_ash"] 供 advancement 识别；
#   CMD=104 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/tread_ash。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·踏灰",bold:true,color:light_purple},custom_model_data={floats:[104.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"踏灰","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后踏灰更名为「超限·踏灰」，被动技","color":"gray","italic":false},{"text":"能变为：自身魔力值上限 +150。自身主动","color":"gray","italic":false},{"text":"技能完成实际位移后为自身恢复最大生命","color":"gray","italic":false},{"text":"值 12% 的生命，并使本次位移技能的冷却","color":"gray","italic":false},{"text":"时间 -5 秒。该效果 8 秒内最多触发一次。","color":"gray","italic":false},{"text":"触发后在位移终点留下半径 1 格、持续 6","color":"gray","italic":false},{"text":"秒的灰痕。生物首次经过时获得 3 秒缓慢","color":"gray","italic":false},{"text":"Ⅲ；自身离开后再次走入时，额外恢复 8%","color":"gray","italic":false},{"text":"最大生命值，并获得 6 秒迅捷Ⅱ。每片灰","color":"gray","italic":false},{"text":"痕的缓慢与自身重入效果合计最多触发一","color":"gray","italic":false},{"text":"次。","color":"gray","italic":false}],custom_data={zx:["ol_tread_ash"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
