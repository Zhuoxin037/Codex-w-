# ============================================================
# fallendream:overlimit/item/empty_camp —— 给一块「超限·空营」
# 【接线】custom_data zx:["ol_empty_camp"] 供 advancement 识别；
#   CMD=135 与 _gen_stone_icons.py 的 CMD 表、recovery_compass.json 路由三处一致。
# 【敲入】副手持对应装备 + 主手右键本石 -> consume_item -> apply/empty_camp。
#   三件套(item/advancement/apply)与 oldef 均已就位，敲失败退材料。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·空营",bold:true,color:light_purple},custom_model_data={floats:[135.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"空营","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后空营更名为「超限·空营」，自身魔","color":"gray","italic":false},{"text":"力值上限 +180。自身 8 格内每有 1 个敌","color":"gray","italic":false},{"text":"对生物，护甲值 +1、护甲韧性 +0.5","color":"gray","italic":false},{"text":"（最多 6 层）。满层时自身额外获得抗性","color":"gray","italic":false},{"text":"提升二效果，且自身每次普通近战时自身","color":"gray","italic":false},{"text":"基础攻击力都会 +3% ，每 5 秒最多触发","color":"gray","italic":false},{"text":"一次。自身未保持满血或卸下本装备时，","color":"gray","italic":false},{"text":"清空本件积攒的全部攻击力加成。8 格内","color":"gray","italic":false},{"text":"没有敌对生物时，每秒恢复 1% 魔力值，","color":"gray","italic":false},{"text":"自身套装效果冷却时间每秒额外 -1 秒。","color":"gray","italic":false}],custom_data={zx:["ol_empty_camp"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
