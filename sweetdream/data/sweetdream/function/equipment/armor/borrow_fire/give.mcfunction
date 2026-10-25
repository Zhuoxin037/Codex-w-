# ============================================================
# sweetdream:equipment/armor/borrow_fire/give —— 给一件「借火」（传说 · 胸甲）
# ------------------------------------------------------------
# 【custom_data】"borrow_fire" -> 装备 id; 判定写 custom_data~{zx:["borrow_fire"]}
# 【机制】打燃烧中的生物 ⇒ 记一次"可借火"；下一次普攻命中未带流火者 ⇒ 附加流火 →
#   立即结束其燃烧 → 剩余燃烧秒数 ×5 真伤；有护甲则削 30% 护甲 / 50% 韧性并转到自己身上 5 秒。
# 【★ 实装必读：字面量禁区 ★】
#   `attribute ... modifier add` 的**数值不能吃计分项** ⇒ "削减 30% 并转移等量"这种
#   动态数值**写不出来**，必须分档查表（护甲 1-4 / 5-9 / …每档一条，成对 add/remove）。
#   转移给自己的数值同样只能按档给 —— lore 与实现对不上时以**分档**为准（已与设计稿同步）。
# 【★ 两个顺序 ★】先附加流火 → 再结束燃烧 → 再结算真伤（反过来判定会塌）；
#   剩余燃烧时间读目标 Fire(刻)/20，不足 1 秒按 1 秒保底。
# 【外观】未画（无 item_model / equippable）。
# ============================================================
give @s netherite_chestplate[item_name={text:"借火",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +200。自身对在燃烧的生","color":"gray","italic":false},{"text":"物造成伤害后则下一次普通攻击未附有","color":"gray","italic":false},{"text":"「流火」的生物时将使其附加「流火」，","color":"gray","italic":false},{"text":"之后使其燃烧状态立即结束且使其受到相","color":"gray","italic":false},{"text":"当于剩余燃烧时间 ×5 的真实伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"若其有护甲值则使其 -30% 的护甲值及","color":"gray","italic":false},{"text":"-50% 的护甲韧性，之后使削减的数值加到","color":"gray","italic":false},{"text":"自己身上，持续 5 秒。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 明烛","color":"gray","italic":false},{"text":"● 借火","color":"gray","italic":false},{"text":" ","italic":false},{"text":"若借火效果是在“烛火”范围内触发的，","color":"gray","italic":false},{"text":"则护甲和护甲韧性削减额外 -20%，且自身","color":"gray","italic":false},{"text":"额外获得 100 魔力值上限并恢复自身 2%","color":"gray","italic":false},{"text":"魔力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["borrow_fire","chestplate","armor"],tags:["liuhuo","max_mana","true_dmg","debuff","apply"]},tooltip_display={hidden_components:["unbreakable"]}]
