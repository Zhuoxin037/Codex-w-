# ============================================================
# fallendream:overlimit/item/smoke_step —— 给一块「超限·烟履」
# 【接线】custom_data zx:["ol_smoke_step"] 供 advancement 识别；
#   CMD=102 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/smoke_step。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·烟履",bold:true,color:light_purple},custom_model_data={floats:[102.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"烟履","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后烟履更名为「超限·烟履」，自身魔","color":"gray","italic":false},{"text":"力值上限 +120。普通近战命中了原本附有","color":"gray","italic":false},{"text":"「流火」的生物后，为自身恢复 15 点魔","color":"gray","italic":false},{"text":"力值及 1% 魔力值，并获得 3 秒迅捷Ⅱ。","color":"gray","italic":false},{"text":"该效果 3 秒内最多触发一次。在本件给予","color":"gray","italic":false},{"text":"的迅捷持续期间累计移动 4 格后，在 3","color":"gray","italic":false},{"text":"秒内下一次普通近战命中附有「流火」的","color":"gray","italic":false},{"text":"生物后可额外触发一次上述效果。","color":"gray","italic":false}],custom_data={zx:["ol_smoke_step"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
