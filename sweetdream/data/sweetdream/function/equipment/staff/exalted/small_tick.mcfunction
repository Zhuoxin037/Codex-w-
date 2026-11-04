execute unless entity @s[tag=zx.ex_small] run return 0
execute unless score @s zx.ex_until > #now manacore.meta run return run function sweetdream:equipment/staff/exalted/small_die
data modify storage zx:work ub set from entity @s data
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,distance=0..,limit=1] run return run function sweetdream:equipment/staff/exalted/small_die
particle minecraft:dust{color:[0.42,0.32,0.51],scale:1.2} ~ ~ ~ 0.18 0.18 0.18 0 3 normal
tag @s add zx.ex_self
function sweetdream:equipment/staff/exalted/small_seek with entity @s data
execute if entity @s at @s run function sweetdream:equipment/staff/exalted/small_after with entity @s data
tag @s remove zx.ex_self

# ============================================================
# 外观载体(小石像)的每刻同步 —— 2026-11-01
# ------------------------------------------------------------
# ① 位置: 载体不是本体的乘客 ⇒ 每刻硬 tp。`tp … ~ ~ ~` 只给 3 个坐标 = 保留朝向,
#    正是我们要的(② 里说明为什么不抄).
# ② 朝向**故意不抄**: 千钧之形一生只活 20 秒、形体是 1.87 格的原尺寸, 它是个悬浮的石像,
#    跟着 small_seek 的 `facing` 乱转反而像在原地打转。固定朝南最稳, 还省两条命令/刻。
# ③ zx.ex_live: 每刻重打, lib/second 靠"这一秒有没有被打过"判孤儿。
#    ★ 别删 —— 本体被任何未预见的方式收掉时, 这是唯一的兜底。
# 【为什么 distance=..0.8 + sort=nearest + limit=1】没有 UUID 绑定。稳态下自己的
#   载体就在脚上(距离≈0), 所以"最近的载体"永远是自己那一个。
#   ★ limit=1 不能省: 两只千钧之形靠到 0.35 以内时, 0.8 半径会把**两个**载体都罩住,
#     不带 limit 就是两个都被拽到 @s 身上 ⇒ 两只小石像叠成一坨、另一只凭空少一尊。
# 【@s 已经死了(合并当刻)】以 @s 为前提 ⇒ 整条不执行, 不会误伤旁边的。
# ============================================================
execute at @s run tp @e[tag=zx.ex_sm_model,distance=..0.8,sort=nearest,limit=1] ~ ~ ~
# ★ 这一行也必须包在 `execute at @s` 里 ★：上一行的 small_after 可能已经走 collide
#   → merge → small_die 把 @s 杀掉了。执行者不存在时 `distance` 失去参照点，会退化成
#   **整维度扫描** —— 届时这一行会给全世界的小石像打标记，孤儿就再也清不掉了。
execute at @s run tag @e[tag=zx.ex_sm_model,distance=..0.8] add zx.ex_live
