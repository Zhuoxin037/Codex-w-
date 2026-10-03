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

# ============================================================
# 待机环境特效 —— 手里握着这把剑时, 剑周一直在渗水
# ------------------------------------------------------------
# 【为什么放在这里】这个文件本来就是"主手持剑时每秒跑一次"的入口,
#   粒子搭同一趟车, 没拿这把剑的人连选择器都过不了, 开销为零。
# 【和释放动画的分工】这里只管"平时"。释放那 1.6 秒由 anim/fx 接管,
#   两边用的是同一套颜色, 所以从待机到爆发不会突然换一种蓝。
# 【三条粒子分别是什么】
#   · 腰间高度的水汽团   —— 剑在手里的位置大约就在那, 慢慢往外渗
#   · 上浮的气泡         —— 深海味的核心, 只给 2 颗, 多了就吵
#   · 贴地的一圈淡雾     —— 站定时脚下像踩在一层薄水上
# 【为什么不用 minecraft:nautilus/water_drop 之类】dust 是唯一能指定颜色的,
#   另外两种偏亮偏白, 和这把剑的深蓝不搭。
# ============================================================
execute if items entity @s weapon.mainhand diamond_sword[custom_data~{"zx":["deepsea_echo"]}] run particle minecraft:dust{color:[0.28,0.55,0.92],scale:0.85} ~ ~1.10 ~ 0.45 0.60 0.45 0 4 normal
execute if items entity @s weapon.mainhand diamond_sword[custom_data~{"zx":["deepsea_echo"]}] run particle minecraft:bubble ~ ~0.95 ~ 0.35 0.50 0.35 0.02 2 normal
execute if items entity @s weapon.mainhand diamond_sword[custom_data~{"zx":["deepsea_echo"]}] run particle minecraft:dust{color:[0.30,0.58,0.95],scale:0.90} ~ ~0.15 ~ 1.10 0.05 1.10 0 5 normal
