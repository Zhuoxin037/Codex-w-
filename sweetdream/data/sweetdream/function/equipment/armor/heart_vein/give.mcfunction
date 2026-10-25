# ============================================================
# sweetdream:equipment/armor/heart_vein/give —— 给一件「心脉」（传说 · 胸甲）
# ------------------------------------------------------------
# 【custom_data】"heart_vein" -> 装备 id; 判定写 custom_data~{zx:["heart_vein"]}
# 【机制】受生物伤害 ⇒ 来源附加「噬心」+3 秒缓慢Ⅱ；自身消耗噬心 ⇒ 给它 5 秒「泵动」（最多 12 秒）；
#   「泵动」每移动一格 ⇒ 最大生命 ×0.05 伤害 + 1 秒缓慢Ⅳ；泵动期间再被消耗噬心 ⇒ 时长叠加
#   + 立即最大生命 ×0.08 伤害 + 自身回 1% 最大魔力；自身恢复上述伤害等量的生命值。
# 【★ 实装必读 ★】
#   ① 「泵动」是**私有资源**，不进标签词表（状态只有五个，_chk_tags 守着）。
#   ② "每移动一格"复用 lib/step 的位移判据（雨迹/踏灰在用），**必须加 0.5 秒闸门** ——
#      否则被击退/高速冲撞的怪一秒触发十几次，按最大生命比例会直接打穿 Boss。
#   ③ 吸血建议封顶（设计稿建议每次 6 点），Boss 高血量下不封顶等于一跳回满。
#   ④ 泵动伤害必须有玩家归属，否则不进账本、不吃乘区、也不触发吸血。
# 【外观】未画（无 item_model / equippable）。
# ============================================================
give @s netherite_chestplate[item_name={text:"心脉",bold:true,color:dark_red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +200。自身受到生物的伤","color":"gray","italic":false},{"text":"害后使伤害来源附加「噬心」，之后使其","color":"gray","italic":false},{"text":"获得 3 秒缓慢Ⅱ效果。若自身消耗了","color":"gray","italic":false},{"text":"「噬心」效果则使其附加持续 5 秒的","color":"gray","italic":false},{"text":"「泵动」（最多 12 秒）。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 泵动","color":"gold","bold":true,"italic":false},{"text":"附有「泵动」的生物每移动一格都会使其","color":"gray","italic":false},{"text":"受到一次相当于其最大生命值 ×0.05 的伤","color":"gray","italic":false},{"text":"害，之后使其获得 1 秒缓慢Ⅳ效果。在此","color":"gray","italic":false},{"text":"期间若其再次被消耗「噬心」则使","color":"gray","italic":false},{"text":"「泵动」持续时间叠加且使其立即受到一","color":"gray","italic":false},{"text":"次相当于其最大生命值 ×0.08 的伤害并使","color":"gray","italic":false},{"text":"自身恢复相当于自身最大魔力值 1% 的魔","color":"gray","italic":false},{"text":"力值。自身会恢复上述相当于对其造成的","color":"gray","italic":false},{"text":"伤害的生命值。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 心脉","color":"gray","italic":false},{"text":"● 剖面","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身对同时附加了「噬心」和「泵动」的","color":"gray","italic":false},{"text":"生物造成伤害时立即触发一次剖面的全部","color":"gray","italic":false},{"text":"效果，且其「泵动」和「噬心」持续时间","color":"gray","italic":false},{"text":"+1 秒。每个生物 10 秒只能触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["heart_vein","chestplate","armor"],tags:["shixin","max_mana","slow","debuff","apply","heal"]},enchantments={"sweetdream:heart_vein":1},enchantment_glint_override=false,tooltip_display={hidden_components:["unbreakable","enchantments"]}]
