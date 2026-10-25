# ============================================================
# sweetdream:equipment/armor/profile/give —— 给一件「剖面」（传说 · 护腿）
# ------------------------------------------------------------
# 【custom_data】"profile" -> 装备 id; 判定写 custom_data~{zx:["profile"]}
# 【机制】累计消耗 100 魔力 ⇒ 5 格内当前生命 >50% 的生物附加「噬心」，之后下一次其他技能伤害 +20%；
#   对带「噬心」的生物造成 3 次伤害 ⇒ 回 50 魔力 + 立即给 5 格内生命 <50% 的生物附加「噬心」+ 回 10% 生命。
# 【★ 撞名提醒 ★】10-25《终端盔甲重设计》里也有一个「剖面」（头盔，剥离心核）。
#   本件按用户 10-25 新稿写（护腿 / 消耗魔力换噬心），两套并存时需用户裁定改名。
# 【★ 实装必读 ★】
#   ① "每消耗 100 魔力"是**累计制**（免费施放/返还/被动扣费不算），不是"单次 ≥100"。
#   ② "下一次 +20%"要有时限（设计稿建议 6 秒）且是独立乘区，一次消耗掉。
#   ③ "3 次伤害"按**每只生物分别计数**，全场合计会被一发 AOE 白嫖；回血要节流。
#   ④ 与绯缝（真伤命中噬心目标回血）同触发面，靠兑现方式错开（计数流 vs 真伤流）。
# 【外观】未画（无 item_model / equippable）。
# ============================================================
give @s netherite_leggings[item_name={text:"剖面",bold:true,color:dark_aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +180，最大生命值 +6。","color":"gray","italic":false},{"text":"自身每消耗 100 魔力值则自身对自身 5","color":"gray","italic":false},{"text":"格内当前生命值高于 50% 的生物附加","color":"gray","italic":false},{"text":"「噬心」，之后自身下一次其他技能伤害","color":"gray","italic":false},{"text":"+20%。自身每对附加了「噬心」的生物造","color":"gray","italic":false},{"text":"成 3 次伤害后则自身恢复 50 魔力值，之","color":"gray","italic":false},{"text":"后立即对自身 5 格内当前生命值低于 50%","color":"gray","italic":false},{"text":"的生物附加「噬心」，且自身恢复 10% 生","color":"gray","italic":false},{"text":"命值。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 心脉","color":"gray","italic":false},{"text":"● 剖面","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身对同时附加了「噬心」和「泵动」的","color":"gray","italic":false},{"text":"生物造成伤害时立即触发一次剖面的全部","color":"gray","italic":false},{"text":"效果，且其「泵动」和「噬心」持续时间","color":"gray","italic":false},{"text":"+1 秒。每个生物 10 秒只能触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["profile","leggings","armor"],tags:["shixin","max_mana","max_hp","cur_mana","indep_mul","apply","heal"]},tooltip_display={hidden_components:["unbreakable"]}]
