# ============================================================
# sweetdream:overlimit/item/backstring —— 给一块「超限·退弦」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_backstring :
#   进度 advancement/overlimit/backstring 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[76.0f]}(八芒星, 编号 76)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「退弦」能敲(见 overlimit/api/fit: 副手 zx 必须含 backstring 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/backstring -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·退弦",bold:true,color:light_purple},custom_model_data={floats:[76.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"退弦","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后退弦更名为「超限·退弦」，主动技","color":"gray","italic":false},{"text":"能变为：箭矢命中后，自身向后位移 2 格","color":"gray","italic":false},{"text":"并获得 5 秒迅捷Ⅱ，之后对射中的生物附","color":"gray","italic":false},{"text":"加一次 8 点固定真实伤害。之后对该生物","color":"gray","italic":false},{"text":"射中一次则该固定伤害翻倍，依靠该被动","color":"gray","italic":false},{"text":"最多翻倍 3 次。每次翻倍持续 6 秒。","color":"gray","italic":false},{"text":"「弦满」变为：每累计 3 次射击，第 3","color":"gray","italic":false},{"text":"发额外造成 30 点伤害。若射中的是被动","color":"gray","italic":false},{"text":"已经翻倍了 3 次或以上的生物则被动额外","color":"gray","italic":false},{"text":"再翻倍一次，本次翻倍单独持续 12 秒。","color":"gray","italic":false}],custom_data={zx:["ol_backstring"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
