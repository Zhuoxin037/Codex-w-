# ============================================================
# sweetdream:equipment/armor/glimmer/foe_one —— 给单只生物挂浮光减速
# ------------------------------------------------------------
# 【执行者】@s = 目标生物
# 【入参】#gl_fv zx.meta：40 = -40%（黄）/ 45 = -45%（白）
# 【★ 两个 id 分开写 ★】数值只能是字面量, 不能 `-0.40 * 档位`;
#   而 modifier **id 必须唯一**, 否则 -40% 之后再挂 -45% 会因为 id 已存在而失败
#   （那只怪就永远停在 -40%）。所以两档用两个 id, 换档时摘掉另一个。
# 【★★ 挂过才摘 ★★】`modifier remove` 一个不存在的 id 会**失败并截断整个函数**
#   （后面的 add 就全没了）⇒ 必须按账本 zx.gl_fv（本生物当前挂着哪档）来决定,
#   而不是"两档都 remove 一遍"。
# ============================================================

# ① 账本补零（scoreboard 不会自动生成条目）
scoreboard players add @s zx.gl_fv 0

# ② 保鲜：本刻被刷到 = 再活 2 秒（★ 必须排在 return 之前, 否则档位不变时不续命）
tag @s add zx.gl_sl
scoreboard players set @s zx.gl_slt 40

# ③ 档位没变 ⇒ 收工
execute if score @s zx.gl_fv = #gl_fv zx.meta run return 0

# ④ 摘旧档
execute if score @s zx.gl_fv matches 40 run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow40
execute if score @s zx.gl_fv matches 45 run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow45
scoreboard players set @s zx.gl_fv 0

# ⑤ 挂新档
execute if score #gl_fv zx.meta matches 40 run attribute @s minecraft:movement_speed modifier add sweetdream:gl_slow40 -0.4 add_multiplied_total
execute if score #gl_fv zx.meta matches 45 run attribute @s minecraft:movement_speed modifier add sweetdream:gl_slow45 -0.45 add_multiplied_total
scoreboard players operation @s zx.gl_fv = #gl_fv zx.meta
