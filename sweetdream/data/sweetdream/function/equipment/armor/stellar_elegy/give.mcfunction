# ============================================================
# sweetdream:equipment/armor/stellar_elegy/give —— 给一件「群星坠落之挽歌」
# ------------------------------------------------------------
# 【custom_data 两段, 和另外两件护甲一个规格】
#   "stellar_elegy" -> 护甲 id, 被动判定靠它认人
#   "leggings"      -> 部位标记
#   ⚠️ 判定请一律写成 custom_data~{zx:["stellar_elegy"]}
#      (部分匹配 + 独有标记) —— 以后往这里加字段也不会静默失效, 见 使用教程 §15.1 ⑤
# 【lore 排版】✦ 小标题 / 灰色正文; 正文按文字宽度硬切, 不为标点换行。
# 【套装】和「黄昏黎明之交界」成套; 套装效果两件都写了, 实现时放在其中一份里。
# ============================================================

give @s netherite_leggings[item_name={text:"群星坠落之挽歌",bold:true,color:"light_purple"},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +280。每次受到攻击后获","color":"gray","italic":false},{"text":"得抗性提升Ⅱ且自身每秒恢复 10 魔力值，","color":"gray","italic":false},{"text":"持续 5 秒。之后使自身 5 格内全部有","color":"gray","italic":false},{"text":"「流火」、「夜火」、「渊海」、","color":"gray","italic":false},{"text":"「白昼梦」、「噬心」中任意一个效果的","color":"gray","italic":false},{"text":"生物受到一次相当于自身当前魔力值","color":"gray","italic":false},{"text":"×0.02 的伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 群星坠落之挽歌","color":"gray","italic":false},{"text":"● 黄昏黎明之交界","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值上限 +200，自身每 3 秒恢复","color":"gray","italic":false},{"text":"1% 魔力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["stellar_elegy","leggings","armor"]},tooltip_display={hidden_components:["unbreakable"]}]
