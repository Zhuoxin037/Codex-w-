# ============================================================
# sweetdream:equipment/armor/withered_garden/give —— 给一件「枯枝园」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "withered_garden" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["withered_garden"]}(部分匹配 + 独有标记)
# 【套装】和「无光海」(lightless_sea)成套, 套装效果两件都写了。
# 【"朽木"是个物件, 不是效果名】头顶图标那套只认 5 种效果名, 别往里塞。
# 【上限】名下最多 3 棵朽木, 逻辑在 withered_garden/cap(宏), 改上限要同步描述。
# 【抗性提升的账本】层数会随朽木数量变化, 要按差值加减, 别直接 set 覆盖。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s netherite_leggings[item_name={text:"枯枝园",bold:true,color:dark_green},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +300。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 朽木","color":"gold","bold":true,"italic":false},{"text":"自身每使用一次技能都会在自身 8 格内的","color":"gray","italic":false},{"text":"随机一个附有「渊海」效果的生物处召唤","color":"gray","italic":false},{"text":"一个持续 8 秒的“朽木”，之后使自身 6","color":"gray","italic":false},{"text":"格内随机一个生物附加「渊海」效果。“","color":"gray","italic":false},{"text":"朽木”每 2 秒对其 5 格内的有缓慢效果","color":"gray","italic":false},{"text":"的生物造成相当于释放者最大魔力值","color":"gray","italic":false},{"text":"×0.08 的伤害，若该目标同时附有","color":"gray","italic":false},{"text":"「渊海」效果则额外造成一次伤害。场上","color":"gray","italic":false},{"text":"最多同时存在 3 个“朽木”，超出时最早","color":"gray","italic":false},{"text":"召唤的一个会立刻消失。自身 12 格内每","color":"gray","italic":false},{"text":"有一个“朽木”则自身获得一层抗性提升","color":"gray","italic":false},{"text":"（最大为 3）。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 无光海","color":"gray","italic":false},{"text":"● 枯枝园","color":"gray","italic":false},{"text":" ","italic":false},{"text":"若“暗潮”内有“朽木”存在，则每秒都","color":"gray","italic":false},{"text":"会使“暗潮”内的全部生物受到相当于释","color":"gray","italic":false},{"text":"放者自身最大魔力值 ×0.1 的伤害，且会","color":"gray","italic":false},{"text":"被附加「渊海」效果。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["withered_garden","leggings","armor"]},tooltip_display={hidden_components:["unbreakable"]}]
