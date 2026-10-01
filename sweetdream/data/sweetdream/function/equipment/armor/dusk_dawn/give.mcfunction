# ============================================================
# sweetdream:equipment/armor/dusk_dawn/give —— 给一件「黄昏黎明之交界」
# ------------------------------------------------------------
# 【custom_data 两段】
#   "dusk_dawn" -> 护甲 id, 被动判定靠它认人
#   "boots"     -> 部位标记
#   ⚠️ 判定请一律写成 custom_data~{zx:["dusk_dawn"]}(部分匹配 + 独有标记)
# 【lore 排版】✦ 小标题 / 灰色正文; 正文按文字宽度硬切, 不为标点换行。
# 【套装】和「群星坠落之挽歌」成套, 套装效果两件都写了。
#   实现时注意: "杀死生物后临时 +200 上限(8 秒)" 要记一笔加了多久, 到点减回去 ——
#   和「静脉泵」那套账本写法一样, 别直接 set 覆盖。
# ============================================================

give @s netherite_boots[item_name={text:"黄昏黎明之交界",bold:true,color:"yellow"},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限+180。若自身魔力值","color":"gray","italic":false},{"text":"低于魔力值上限50%则每秒获得20魔","color":"gray","italic":false},{"text":"力值。自身杀死一个生物后自身临时","color":"gray","italic":false},{"text":"获得200魔力值上限，持续8秒。若杀","color":"gray","italic":false},{"text":"死的生物有「流火」、「夜火」、","color":"gray","italic":false},{"text":"「渊海」、「白昼梦」、「噬心」中","color":"gray","italic":false},{"text":"任意一个效果则额外使自身获得100魔","color":"gray","italic":false},{"text":"力值上限。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 群星坠落之挽歌","color":"gray","italic":false},{"text":"● 黄昏黎明之交界","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身魔力值上限+200，自身每3秒恢复","color":"gray","italic":false},{"text":"1%魔力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["dusk_dawn","boots"]},tooltip_display={hidden_components:["unbreakable"]}]
