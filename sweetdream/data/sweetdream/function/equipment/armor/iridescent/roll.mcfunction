# ============================================================
# sweetdream:equipment/armor/iridescent/roll —— 给一只生物随机挑两种效果
# ------------------------------------------------------------
# 【执行者】被选中的那只生物
# 【为什么不用 sort=random 挑"效果"】sort=random 挑的是**实体**, 而五种效果是
#   五段代码, 没有实体可以挑。所以只能自己造一个随机数。
# 【★ 随机数从哪来(2026-10-03 换掉) ★】
#   以前是"这只生物坐标的小数位 + 当前 tick"。那套和**攻击节奏**耦合:
#   站着不动的那只被反复打时坐标不变, 攻击间隔只要是 5 的倍数 tick 取模也不动,
#   于是"每次结果都不一样"的承诺不成立(审查第 5 条)。
#   现在统一走 lib/rnd(全局 LCG): 每调用一次推进一步, 和坐标、节奏无关;
#   同一次 AOE 里的几只各自抽一次, 结果天然错开, 也不会像"自增序号取模"那样
#   整整齐齐地轮一圈。
# 【★ 不用再拉负数了 ★】lib/rnd 出来的 #rnd 已经是 0..32767 的非负值,
#   取模一定落在正区间。(老写法要拉负数是因为坐标可能是负的。)
# 【怎么保证两种"不相同"】第二个不在 0..4 里另抽, 而是抽一个 0..3 的偏移,
#   加到"第一个 +1"上再绕回 —— 这样天然不会和第一个撞。
# ============================================================

# ① 第一个: 0..4
function sweetdream:lib/rnd
scoreboard players operation #ir_a zx.meta = #rnd zx.meta
scoreboard players operation #ir_a zx.meta %= #5 zx.meta

# ② 第二个: 从"第一个的下一个"起偏移 0..3, 绕回后必然不等于第一个
function sweetdream:lib/rnd
scoreboard players operation #ir_b zx.meta = #rnd zx.meta
scoreboard players operation #ir_b zx.meta %= #4 zx.meta
scoreboard players operation #ir_c zx.meta = #ir_a zx.meta
scoreboard players add #ir_c zx.meta 1
scoreboard players operation #ir_c zx.meta += #ir_b zx.meta
scoreboard players operation #ir_c zx.meta %= #5 zx.meta

# ③ 分发(两种各执行一次; 同一个编号不会同时出现在 a 和 c 里)
execute if score #ir_a zx.meta matches 0 run function sweetdream:equipment/armor/iridescent/eff_1
execute if score #ir_a zx.meta matches 1 run function sweetdream:equipment/armor/iridescent/eff_2
execute if score #ir_a zx.meta matches 2 run function sweetdream:equipment/armor/iridescent/eff_3
execute if score #ir_a zx.meta matches 3 run function sweetdream:equipment/armor/iridescent/eff_4
execute if score #ir_a zx.meta matches 4 run function sweetdream:equipment/armor/iridescent/eff_5

execute if score #ir_c zx.meta matches 0 run function sweetdream:equipment/armor/iridescent/eff_1
execute if score #ir_c zx.meta matches 1 run function sweetdream:equipment/armor/iridescent/eff_2
execute if score #ir_c zx.meta matches 2 run function sweetdream:equipment/armor/iridescent/eff_3
execute if score #ir_c zx.meta matches 3 run function sweetdream:equipment/armor/iridescent/eff_4
execute if score #ir_c zx.meta matches 4 run function sweetdream:equipment/armor/iridescent/eff_5
