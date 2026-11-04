# ============================================================
# 千钧之形(小石像)每刻朝同主人的另一尊移动
# ------------------------------------------------------------
# 【速度 0.30 格/刻 = 6 格/秒】沿革: 0.10(2 格/秒) → 0.15(3) → **0.30(6)**,
# 与崇高之形(10 格/秒)保持约 3:5 的关系, 也贴近玩家走路 4.3。
# ★ 这个数被 collide 的合并判定硬卡上限: 两尊**同时**相向靠近, 相对速度
#   = 2×0.30 = 0.60 格/刻, 必须小于采样窗口, 否则会"一步跨过去、永远判不到
#   合体"。本轮已把 collide 的窗口 0.35 一起放宽到 **0.70**, 留 0.10 余量。
#   ⇒ 想再快, 必须再放宽 0.70, 两个数永远成对改。
# ============================================================
tag @s remove zx.ex_moving
$execute if entity @e[tag=zx.ex_small,tag=!zx.ex_self,distance=..12,sort=nearest,limit=1,nbt={data:{owner:"$(owner)"}}] run tag @s add zx.ex_moving
$execute if entity @s[tag=zx.ex_moving] facing entity @e[tag=zx.ex_small,tag=!zx.ex_self,distance=..12,sort=nearest,limit=1,nbt={data:{owner:"$(owner)"}}] feet positioned ^ ^ ^0.3 run tp @s ~ ~ ~ ~ ~
