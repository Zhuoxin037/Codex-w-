# ============================================================
# fallendream:overlimit/item/cease_war —— 给一块「超限·止战」
# 【接线】custom_data zx:["ol_cease_war"] 供 advancement 识别；
#   CMD=129 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/cease_war。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·止战",bold:true,color:light_purple},custom_model_data={floats:[129.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"止战","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后止战更名为「超限·止战」，被动技","color":"gray","italic":false},{"text":"能变为：最大生命值 +6。自身职业攻击增","color":"gray","italic":false},{"text":"益全部自然到期后，获得持续 16 秒的","color":"gray","italic":false},{"text":"「余勇」，每 16 秒最多触发一次。✦ 余","color":"gray","italic":false},{"text":"勇立即恢复 20% 生命值。护甲值 +6，护","color":"gray","italic":false},{"text":"甲韧性 +1，击退抗性 +0.3。普通近战命","color":"gray","italic":false},{"text":"中生物后恢复 12 魔力。重新获得职业攻","color":"gray","italic":false},{"text":"击增益时，余勇效果改为普通近战命中生","color":"gray","italic":false},{"text":"物后使其护甲值及护甲韧性 -20% 且自身","color":"gray","italic":false},{"text":"基础攻击力 +5% ，可以叠加三次，持续至","color":"gray","italic":false},{"text":"余勇效果结束。","color":"gray","italic":false}],custom_data={zx:["ol_cease_war"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
