# ============================================================
# sweetdream:equipment/sword/deepsea_echo/passive —— 主手持时给水下呼吸 I
# ------------------------------------------------------------
# 【文案】被动技能: 主手持时, 自身获得水下呼吸 Ⅰ。
# 【怎么认"主手持着它"】execute if items entity @s weapon.mainhand <物品>[custom_data~{...}]
#   ★ 用 ~ 做**部分匹配**, 只认这把武器独有的那一段标记: custom_data~{zx:["deepsea_echo"]}
#   · 以前写成 =(整份精确比对), 结果 zx 列表多一段就静默失效 —— 水下呼吸一直不生效
#     就是这个原因(2026-09-29 修)。
#   · 标记必须**这把武器独有**, 别用 "itemreplace" 那种公共段, 否则会串到别的武器上。
# 【为什么给 3 秒、每秒刷】松手/换手之后最多 3 秒它自己就没了, 不用调
#   effect clear —— clear 在"本来就没有这个效果"时会失败, 那种失败会截断函数。
#   (副作用: 它会盖住别的来源给的水下呼吸, 只要你在用它, 就会一直是这个等级。)
# ============================================================

execute if items entity @s weapon.mainhand diamond_sword[custom_data~{"zx":["deepsea_echo"]}] run effect give @s minecraft:water_breathing 3 0 true
