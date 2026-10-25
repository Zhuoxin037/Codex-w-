# ============================================================
# sweetdream:overlimit/item/anchor —— 给一块「超限·沉锚」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_anchor :
#   进度 advancement/overlimit/anchor 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[72.0f]}(八芒星, 编号 72)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「沉锚」能敲(见 overlimit/api/fit: 副手 zx 必须含 anchor 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/anchor -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·沉锚",bold:true,color:light_purple},custom_model_data={floats:[72.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"沉锚","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后沉锚更名为「超限·沉锚」，被动技","color":"gray","italic":false},{"text":"能变为：每次攻击时都有 30% 的概率将自","color":"gray","italic":false},{"text":"身前方 2 格内的生物击飞 1 格并对其造","color":"gray","italic":false},{"text":"成相当于自身最大魔力值 ×0.06 的伤害。","color":"gray","italic":false},{"text":"主动技能变为：向自身 12 格内的准星上","color":"gray","italic":false},{"text":"的目标掷出沉锚并位移到目标位置，之后","color":"gray","italic":false},{"text":"对其 5 格内的生物造成相当于释放者基础","color":"gray","italic":false},{"text":"攻击力 ×8 的伤害并击飞 3 格并使其获得","color":"gray","italic":false},{"text":"5 秒缓慢Ⅳ，之后自身获得 8 秒抗性提升","color":"gray","italic":false},{"text":"Ⅳ。之后在 4 秒内可以再次使用技能并回","color":"gray","italic":false},{"text":"到原处。","color":"gray","italic":false}],custom_data={zx:["ol_anchor"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
