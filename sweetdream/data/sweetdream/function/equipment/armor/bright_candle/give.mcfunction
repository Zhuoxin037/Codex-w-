# ============================================================
# sweetdream:equipment/armor/bright_candle/give —— 给一件「明烛」（传说 · 头盔）
# ------------------------------------------------------------
# 【custom_data】"bright_candle" -> 装备 id; 判定写 custom_data~{zx:["bright_candle"]}
# 【机制】对带「流火」的生物造成伤害 ⇒ 在其位置留 10 秒“烛火”；烛火**内圈 3 格攒 3 秒 /
#   外环 3-5 格攒 5 秒**把「流火」升级为「夜火」；自身在 5 格内每秒回 0.5% 最大魔力。
#   每 8 秒才能召唤一次。
# 【★ 实装必读 ★】
#   ① 流火 → 夜火是**替换不是叠加**（余烬 burned_out 的教训：叠加会变成刷魔力漏洞）。
#   ② 本件是"造夜火"，与**烛跬**（消费夜火/流火回蓝）天然上下游，不冲突。
#   ③ 回魔类一律每 20 刻结算一次，别每刻跑。
# 【外观】未画（无 item_model / equippable），先用原版下界合金头盔外观。
# ============================================================
give @s netherite_helmet[item_name={text:"明烛",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +180，自身获得常态的夜","color":"gray","italic":false},{"text":"视效果。自身对附有「流火」的生物造成","color":"gray","italic":false},{"text":"伤害后在其位置召唤一个持续 10 秒的“","color":"gray","italic":false},{"text":"烛火”。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 烛火","color":"gold","bold":true,"italic":false},{"text":"在“烛火” 3 格内附有「流火」的生物累","color":"gray","italic":false},{"text":"计停留 3 秒后则「流火」转化为「夜火」，","color":"gray","italic":false},{"text":"在“烛火” 3-5 格内附有「流火」的生物","color":"gray","italic":false},{"text":"累计停留 5 秒后则「流火」转化为","color":"gray","italic":false},{"text":"「夜火」。自身在“烛火” 5 格内时每秒","color":"gray","italic":false},{"text":"额外恢复相当于自身最大魔力值 0.5% 的","color":"gray","italic":false},{"text":"魔力值。“烛火”每 8 秒才能召唤一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 明烛","color":"gray","italic":false},{"text":"● 借火","color":"gray","italic":false},{"text":" ","italic":false},{"text":"若借火效果是在“烛火”范围内触发的，","color":"gray","italic":false},{"text":"则护甲和护甲韧性削减额外 -20%，且自身","color":"gray","italic":false},{"text":"额外获得 100 魔力值上限并恢复自身 2%","color":"gray","italic":false},{"text":"魔力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["bright_candle","helmet","armor"],tags:["liuhuo","yehuo","max_mana","cur_mana","summon","apply","consume","buff"]},tooltip_display={hidden_components:["unbreakable"]}]
