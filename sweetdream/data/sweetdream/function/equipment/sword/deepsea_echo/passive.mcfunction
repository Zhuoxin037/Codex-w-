# ============================================================
# sweetdream:equipment/sword/deepsea_echo/passive —— 主手持时给水下呼吸 I
# ------------------------------------------------------------
# 【文案】被动技能: 主手持时, 自身获得水下呼吸 Ⅰ。
# 【怎么认"主手持着它"】execute if items entity @s weapon.mainhand <物品>[custom_data={...}]
#   ★ custom_data 这里写的是**整份**内容(三段全写) —— 它是精确比对,
#     少写一段就永远匹配不上, 而且不报错、不闪红。(这个坑踩过一次。)
#     >>> 改 give 里的 custom_data 时, 这里要同步改 <<<
# 【为什么给 3 秒、每秒刷】松手/换手之后最多 3 秒它自己就没了, 不用调
#   effect clear —— clear 在"本来就没有这个效果"时会失败, 那种失败会截断函数。
#   (副作用: 它会盖住别的来源给的水下呼吸, 只要你在用它, 就会一直是这个等级。)
# ============================================================

execute if items entity @s weapon.mainhand diamond_sword[custom_data={zx:["deepsea_echo","sword","itemreplace"]}] run effect give @s minecraft:water_breathing 3 0 true
