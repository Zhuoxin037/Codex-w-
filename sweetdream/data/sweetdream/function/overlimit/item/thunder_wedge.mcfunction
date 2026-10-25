# ============================================================
# sweetdream:overlimit/item/thunder_wedge —— 给一块「超限·雷楔」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_thunder_wedge :
#   进度 advancement/overlimit/thunder_wedge 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[65.0f]}(八芒星, 编号 65)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「雷楔」能敲(见 overlimit/api/fit: 副手 zx 必须含 thunder_wedge 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/thunder_wedge -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·雷楔",bold:true,color:light_purple},custom_model_data={floats:[65.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"雷楔","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后雷楔更名为「超限·雷楔」，主动技","color":"gray","italic":false},{"text":"能变为：使用后召唤 1 个术阵，并在自身","color":"gray","italic":false},{"text":"位置召唤一个持续 10 秒的“雷楔”。同","color":"gray","italic":false},{"text":"一使用者同时只能存在一个。「雷楔」变","color":"gray","italic":false},{"text":"为：使用者攻击了“雷楔”12 格内的生物","color":"gray","italic":false},{"text":"后，“雷楔”对命中位置释放一次闪电，","color":"gray","italic":false},{"text":"对其 1 格内的生物造成一次相当于使用者","color":"gray","italic":false},{"text":"基础攻击力 ×2 的伤害。在“雷楔”范围","color":"gray","italic":false},{"text":"内的生物被闪电命中后的 3 秒内每秒都会","color":"gray","italic":false},{"text":"受到一次相当于释放者当前魔力值 ×0.07","color":"gray","italic":false},{"text":"的伤害。若在这期间再次被雷电命中则强","color":"gray","italic":false},{"text":"化为在 5 秒内每秒都会受到一次相当于释","color":"gray","italic":false},{"text":"放着最大魔力值 ×0.08 的伤害。“雷楔”","color":"gray","italic":false},{"text":"在结束后对范围内的全部生物都会释放一","color":"gray","italic":false},{"text":"次闪电。","color":"gray","italic":false}],custom_data={zx:["ol_thunder_wedge"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
