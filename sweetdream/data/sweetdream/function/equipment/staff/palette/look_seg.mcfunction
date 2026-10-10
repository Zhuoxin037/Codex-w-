# ============================================================
# sweetdream:equipment/staff/palette/look_seg —— 调色盘: 观测镜里的「色彩」段
# ------------------------------------------------------------
# 【谁调用它】equipment/tool/look/render_go —— 手里拿着调色盘时, 拼在层数段**后面**
# 【执行者】玩家本人
# 【为什么要单开一段(不走 lib/reg 的 layer 表)】
#   layer 表只会画"数值": 「标签 当前值/上限」。而调色盘的颜色存的是**色码**
#   (1 红 / 2 黄 / 3 蓝), 直接把 1/2/3 摆上去等于没标 —— 玩家要看的是颜色本身,
#   所以这里是"**文字型段**": 把色码翻成带色的「红」「黄」「蓝」两个字。
#   ★ 层数表是给"数值机制"用的, 别再往表里塞色码行(会显示成 "色彩 2/3" 这种天书)。
# 【分隔符与 layer 段共用同一套】#ly_first 由 render_go 每轮置 1; layer_row 用
#   "先抄一份再清"的写法垫 "  ｜ "(第一条命中) / "  ·  "(后续命中)。这里照抄那 4 行,
#   于是不管"层数段"和"色彩段"谁先命中, 分隔符都既不重复也不缺。
# 【只在有颜色时显示】两个槽都是 0(空盘)就直接 return —— 和 layer_row 的
#   "层数为 0 不显示"同一个口径。
# 【★ 必须先 add 0 把分数建出来 ★】玩家从没攒过色时 zx.pal_c1 是**没有分数的**,
#   这时 `matches 0` 会**直接失败**(不是当成 0) ⇒ 守卫放行 ⇒ 观测镜上冒出一个
#   空的"色彩"标签(2026-10-05 幽灵段事故同款, 见 layer_row 头注释)。
# ============================================================

scoreboard players add @s zx.pal_c1 0
scoreboard players add @s zx.pal_c2 0
execute if score @s zx.pal_c1 matches 0 if score @s zx.pal_c2 matches 0 run return 0

# ---- 分隔符(和 layer_row 同一套: 先抄一份再清, 免得两个都垫) ----
scoreboard players operation #ly_was zx.meta = #ly_first zx.meta
scoreboard players set #ly_first zx.meta 0
execute if score #ly_was zx.meta matches 1 run data modify storage zx:look xline append value {"text":"  ｜ ","color":"dark_gray"}
execute if score #ly_was zx.meta matches 0 run data modify storage zx:look xline append value {"text":"  ·  ","color":"dark_gray"}

# ---- 标签 ----
data modify storage zx:look xline append value {"text":"色彩 ","color":"gray"}

# ---- 槽 ① ----
execute if score @s zx.pal_c1 matches 1 run data modify storage zx:look xline append value {"text":"红","color":"red"}
execute if score @s zx.pal_c1 matches 2 run data modify storage zx:look xline append value {"text":"黄","color":"yellow"}
execute if score @s zx.pal_c1 matches 3 run data modify storage zx:look xline append value {"text":"蓝","color":"blue"}

# ---- 槽 ②(两个槽都有色时中间垫个分隔点) ----
execute if score @s zx.pal_c1 matches 1.. if score @s zx.pal_c2 matches 1.. run data modify storage zx:look xline append value {"text":"·","color":"dark_gray"}
execute if score @s zx.pal_c2 matches 1 run data modify storage zx:look xline append value {"text":"红","color":"red"}
execute if score @s zx.pal_c2 matches 2 run data modify storage zx:look xline append value {"text":"黄","color":"yellow"}
execute if score @s zx.pal_c2 matches 3 run data modify storage zx:look xline append value {"text":"蓝","color":"blue"}
