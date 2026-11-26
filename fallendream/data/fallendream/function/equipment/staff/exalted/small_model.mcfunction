# ============================================================
# fallendream:equipment/staff/exalted/small_model —— 「千钧之形」的外观载体
# ------------------------------------------------------------
# 【执行者】刚召出来的那个千钧之形 marker（由 ball_hit 用 `execute at … run` 调用，
#   所以 `~ ~ ~` 就是它的位置）。**不要**在别的上下文里直接调。
# 【设定】千钧之形本身就是一尊小石像，合成之后的「崇高之形」才是大的一尊。
#   两者共用同一份资源包模型(fallendream:exalted_form)，只差 scale。
#     · 千钧之形   scale 2.00 ⇒ 3.74 格高（2026-11-01 用户："太小了，全部放大一倍"）
#     · 崇高之形   scale 3.00 ⇒ 5.62 格高（merge.mcfunction 里，仍比千钧之形大一档）
#   改这里的数就要同步 merge 里那一组，别让两边各说各话。
# 【★ translation[1] 必须 = 0.5 × scale ★】item model 的渲染原点恒在模型中心
#   (8,8,8)，所以模型 y=0 那一面被渲染在**实体位置下方半格**，乘 scale 后是
#   -0.5×s；translation 正好补回来。0.5×2.00 = 1.00，漏了整尊埋进地面。
# 【★ left_rotation 绕 Y 转 180° ★】模型是朝 -Z(北) 建的，实体 yaw=0 朝 +Z(南)。
#   转过来之后正面才朝南。千钧之形**不跟随本体旋转**（见 small_tick），
#   所以这个朝向就是它一生的朝向 —— 它是个悬浮的小石像，不该边走边转。
# 【★ billboard:"fixed" 必写 ★】不写会变成永远面向玩家，移动时像在原地打转。
# 【★ 放大只改视觉，不改判定 ★】碰撞/合并半径仍是 collide 里的 0.35 格 ——
#   石像变大之后两只靠得很近时会看起来"叠在一起"，那是判定没跟着变，不是 bug。
# ============================================================

summon minecraft:item_display ~ ~ ~ {Tags:["zx.ex_sm_model"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"fallendream:exalted_form"}},item_display:"fixed",billboard:"fixed",interpolation_duration:0,teleport_duration:0,view_range:2.5f,shadow_radius:0.0f,width:3.0f,height:4.4f,transformation:{translation:[0.0f,1.0f,0.0f],scale:[2.0f,2.0f,2.0f],left_rotation:[0.0f,1.0f,0.0f,0.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}

# 出生就先打一次 zx.ex_live：lib/second 的收尸判据是"这一秒一次都没被打过标记"，
# 不打的话刚召出来的这一瞬有 1/20 的概率被当成孤儿收掉（big 那边同样的坑）。
tag @e[tag=zx.ex_sm_model,distance=..0.6] add zx.ex_live
