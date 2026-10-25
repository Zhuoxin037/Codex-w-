# ============================================================
# sweetdream:overlimit/item/grayscale —— 给一块「超限·灰度」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_grayscale :
#   进度 advancement/overlimit/grayscale 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[60.0f]}(八芒星, 编号 60)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「灰度」能敲(见 overlimit/api/fit: 副手 zx 必须含 grayscale 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/grayscale -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·灰度",bold:true,color:light_purple},custom_model_data={floats:[60.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"灰度","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后灰度更名为「超限·灰度」，主动技","color":"gray","italic":false},{"text":"能变为：使用后使自身 5 格内的生物受到","color":"gray","italic":false},{"text":"一次相当于自身最大魔力值 ×0.1 的伤害，","color":"gray","italic":false},{"text":"之后使其燃烧 3 秒。若已经处于燃烧状态","color":"gray","italic":false},{"text":"则改为使其附加「流火」并额外附加一次","color":"gray","italic":false},{"text":"相当于自身最大魔力值 ×0.08 的真实伤害。","color":"gray","italic":false}],custom_data={zx:["ol_grayscale"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
