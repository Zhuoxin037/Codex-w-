summon minecraft:marker ~ ~ ~ {Tags:["zx.ex_big","zx.ex_new"],data:{}}
# ============================================================
# 外观载体(item_display) —— 2026-11-01 建模实装
#   资源包 fallendream:exalted_form = 322 块的修女石像(模型 1.872 格高)。
#   · scale 3.00 => 5.62 格高: 比「千钧之形」(scale 2.00 = 3.74 格) 整整大一圈。
#     2026-11-01 用户改口径："太小了，全部放大一倍" —— 两尊一起 ×2,
#     所以 1.0→2.0 / 1.5→3.0, 差距比例保持不变。
#   · translation[1] 必须 = 0.5 × scale ★：item model 的渲染原点恒在 (8,8,8),
#     模型 y=0 那一面被渲染在**实体位置下方半格**, 乘 scale 后是 -0.5×s。
#     漏了这半格 = 整尊石像埋进地板只剩上半身。0.5×3.00 = 1.50。
#   · left_rotation 绕 Y 转 180° ★：模型是朝 -Z(北) 建的, 而实体 yaw=0 的朝向是
#     +Z(南)。转过来之后 big_tick 就能直接抄本体的 Rotation[0], 不必每刻 +180。
#   · billboard:"fixed" 必须写 —— 不写会变成永远面向玩家, 石像走路时原地转圈。
# ============================================================
summon minecraft:item_display ~ ~ ~ {Tags:["zx.ex_model","zx.ex_model_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"fallendream:exalted_form"}},item_display:"fixed",billboard:"fixed",interpolation_duration:0,teleport_duration:0,view_range:3.5f,shadow_radius:0.0f,width:5.6f,height:6.8f,transformation:{translation:[0.0f,1.5f,0.0f],scale:[3.0f,3.0f,3.0f],left_rotation:[0.0f,1.0f,0.0f,0.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
# 出生就先打上 zx.ex_live: lib/second 的收尸判据是"这一秒一次都没被打过标记",
# 不打的话刚召出来的这一瞬有 1/20 的概率被当成孤儿收掉。
tag @e[tag=zx.ex_model_new,distance=..2] add zx.ex_live
tag @e[tag=zx.ex_model_new,distance=..2] remove zx.ex_model_new

data modify entity @e[tag=zx.ex_new,distance=0..,limit=1] data set from entity @s data
data modify entity @e[tag=zx.ex_new,distance=0..,limit=1] data.g0 set from entity @e[tag=zx.ex_grave_used,distance=0..,limit=1] UUID[0]
data modify entity @e[tag=zx.ex_new,distance=0..,limit=1] data.g1 set from entity @e[tag=zx.ex_grave_used,distance=0..,limit=1] UUID[1]
data modify entity @e[tag=zx.ex_new,distance=0..,limit=1] data.g2 set from entity @e[tag=zx.ex_grave_used,distance=0..,limit=1] UUID[2]
data modify entity @e[tag=zx.ex_new,distance=0..,limit=1] data.g3 set from entity @e[tag=zx.ex_grave_used,distance=0..,limit=1] UUID[3]
scoreboard players set @e[tag=zx.ex_new,distance=0..,limit=1] zx.ex_walk 0
tag @e[tag=zx.ex_new,distance=0..] remove zx.ex_new
