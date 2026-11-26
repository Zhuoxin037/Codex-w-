# ============================================================
# fallendream:overlimit/item/bone_breaker —— 给一块「超限·碎骨」
# 【接线】custom_data zx:["ol_bone_breaker"] 供 advancement 识别；
#   CMD=106 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/bone_breaker。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·碎骨",bold:true,color:light_purple},custom_model_data={floats:[106.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"碎骨","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后碎骨更名为「超限·碎骨」，主动技","color":"gray","italic":false},{"text":"能变为：魔力 130 每次射击若场上没有“","color":"gray","italic":false},{"text":"碎刀”，则召唤“碎刀”。✦ 碎刀“碎刀","color":"gray","italic":false},{"text":"”为 3 把旋转刀刃，刀刃每刻碰到生物时","color":"gray","italic":false},{"text":"都会对其造成相当于自身基础攻击力 ×0.5","color":"gray","italic":false},{"text":"的伤害。“碎刀”会跟着自身的准星移动，","color":"gray","italic":false},{"text":"持续 10 秒。同一生物每累计受到 6 次碎","color":"gray","italic":false},{"text":"刀伤害，则额外受到一次基础攻击力 ×3","color":"gray","italic":false},{"text":"的真实伤害并获得 2 秒缓慢Ⅲ，之后使其","color":"gray","italic":false},{"text":"附加「噬心」。“碎刀”持续期间若自身","color":"gray","italic":false},{"text":"再次射击则“碎刀”的刀刃 +1 且持续时","color":"gray","italic":false},{"text":"间重置，每个“碎刀”最多触发 2 次该效","color":"gray","italic":false},{"text":"果。","color":"gray","italic":false}],custom_data={zx:["ol_bone_breaker"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
