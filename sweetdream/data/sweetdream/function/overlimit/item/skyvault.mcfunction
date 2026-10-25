# ============================================================
# sweetdream:overlimit/item/skyvault —— 给一块「超限·天穹」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_skyvault :
#   进度 advancement/overlimit/skyvault 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[68.0f]}(八芒星, 编号 68)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「天穹」能敲(见 overlimit/api/fit: 副手 zx 必须含 skyvault 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/skyvault -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·天穹",bold:true,color:light_purple},custom_model_data={floats:[68.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"天穹","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后天穹更名为「超限·天穹」，","color":"gray","italic":false},{"text":"「升痕」变为：每次攻击生物后为其附加","color":"gray","italic":false},{"text":"一层「升痕」，最多 3 层。带有「升痕」","color":"gray","italic":false},{"text":"的生物受到来自比自身位置更高的攻击时，","color":"gray","italic":false},{"text":"每层「升痕」使本次技能伤害提升 10%。","color":"gray","italic":false},{"text":"「升痕」每 15 秒减少 1 层。主动技能变","color":"gray","italic":false},{"text":"为：使用后自身立即向上跃升 8 格，并使","color":"gray","italic":false},{"text":"自身 8 格内至多 5 个生物获得 3 秒飘浮","color":"gray","italic":false},{"text":"Ⅱ效果。0.5 秒后，自身可以再次使用该","color":"gray","italic":false},{"text":"技能。再次使用时，自身朝准星方向高速","color":"gray","italic":false},{"text":"俯冲，落地或命中生物后在当前位置产生","color":"gray","italic":false},{"text":"一次半径 6 格的冲击，对范围内全部生物","color":"gray","italic":false},{"text":"造成相当于自身最大魔力值 ×0.12 的伤害，","color":"gray","italic":false},{"text":"本次伤害常态被「升痕」计算加伤。每命","color":"gray","italic":false},{"text":"中一个拥有「升痕」的生物，则额外消耗","color":"gray","italic":false},{"text":"其全部「升痕」，每消耗一层使该生物额","color":"gray","italic":false},{"text":"外受到一次相当于自身基础攻击力 ×3 的","color":"gray","italic":false},{"text":"伤害。若此次俯冲至少消耗 6 层「升痕」，","color":"gray","italic":false},{"text":"则技能冷却时间减少 35 秒。若此次俯冲","color":"gray","italic":false},{"text":"至少消耗 10 层「升痕」，则自身再次跃","color":"gray","italic":false},{"text":"升 6 格并在 0.5 秒后向自身准星位置俯","color":"gray","italic":false},{"text":"冲，并在落地后对半径 5 格内的生物造成","color":"gray","italic":false},{"text":"一次相当于自身当前魔力值 ×0.1 的伤害","color":"gray","italic":false},{"text":"并使受到伤害的生物获得一层「升痕」。","color":"gray","italic":false}],custom_data={zx:["ol_skyvault"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
