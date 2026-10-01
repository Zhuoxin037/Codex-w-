# ============================================================
# sweetdream:equipment/sword/deepsea_echo/seed —— 挑最近的 + 上渊海
# ------------------------------------------------------------
# 【宏参数】zx:work de {uuid}   【执行者】施法者
# 【挑法】sort=nearest + limit=1 = 12 格内离自己最近的那一个。
#   挑完**当场打标签冻结**: @e 每次求值都会重挑一次, 不冻结的话
#   后面几步可能作用在别人身上(流光那边踩过同一个坑)。
# ============================================================

# 挑最近的生物, 冻结成"第一波的源"
$tag @e[type=!#sweetdream:no_damage,distance=0.1..12,sort=nearest,limit=1] add zx.de_$(uuid)

# 给它附加「渊海」
#   【存法】由公共接口写入原生实体标签 zx.status.yuanhai。
#   五个通用标签(渊海/流火/夜火/白昼梦/噬心)将来都放这个位子,
#   现在只做一个"存在"标记; 持续时间和层数等通用系统做好之后再补。
# 贴「渊海」标记: 走通用接口 —— 写 NBT + 给这只生物分配图标编号 + 生成图标显示实体
#   (以前这里只写 NBT, 所以"有渊海"这件事玩家完全看不见)
$data modify storage zx:work ic.target set value "@e[tag=zx.de_$(uuid),limit=1]"
data modify storage zx:work ic.mark set value "yuanhai"
function sweetdream:tag/mark with storage zx:work ic

# 起手的表现(海味三件套 + 范围提示):
#   · block.conduit.activate  潮涌核心被激活的那一声(最能代表"海")
#   · nautilus                潮涌核心周围那种鹦鹉螺粒子
#   · bubble                  一串上浮的气泡
#   · 脚下半径 12 的蓝色光环  —— 那是"范围", 所以用蓝色 dust
#   分工原则: 范围(12 格搜索环 / 3 格伤害球) = 蓝色 dust;
#             其余(起手 / 命中) = 海味的鹦鹉螺·气泡·水花。
# (音效/粒子 id 都是从你这版的 sounds.json 和客户端 jar 里核对过的, 不是猜的)
$execute at @e[tag=zx.de_$(uuid),limit=1] run playsound minecraft:block.conduit.activate player @a ~ ~ ~ 0.9 0.9
$execute at @e[tag=zx.de_$(uuid),limit=1] run particle minecraft:nautilus ~ ~1 ~ 0.6 0.6 0.6 0.05 40 normal
$execute at @e[tag=zx.de_$(uuid),limit=1] run particle minecraft:bubble ~ ~1.2 ~ 0.5 0.6 0.5 0.02 25 normal
function sweetdream:equipment/sword/deepsea_echo/sfx_ring12

# 到第一波之间的那一秒里, 每 5 tick 补画一次, 让水面不"断"
# 范围环补画改由每秒循环负责(见 lib/second) —— 优化建议第 3 条



# 记下"总共还要推进几波"。
#   文案是"重复 2 次后结束" = 初次 1 波 + 重复 2 波 = 共 3 波。
#   left 在 wave_go 里每波减 1, 减到 0 就收尾; 所以这里填 3。
#   (110 魔力是在"要开下一波"的时候才扣, 所以正好扣 2 次 = 重复 2 次。)
#   想改成"重复 N 次"就把这个数改成 N+1。
$data modify storage zx:data de."$(uuid)" set value {left:3}
