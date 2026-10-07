# ============================================================
# sweetdream:equipment/armor/blaze_armor/pig_tick —— 焱·「视为金甲」(每刻)
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute as @a at @s run function ...
# 【为什么从"每秒"改成"每刻"】2026-10-08 事故: 玩家反馈"猪灵还是打我"。
#   根因是**猪灵挑目标的通道不止一条**, 而且刷新比 1 秒快得多:
#     · AngryAt 那条(被打/被激怒才走) —— 清一次能顶一阵
#     · Brain 记忆 NEAREST_TARGETABLE_PLAYER_NOT_WEARING_GOLD 那条 —— 由
#       NearestPlayersSensor 刷新, 只影响"附近有没有不穿金甲的玩家"这一件事,
#       而**它才是原版"你没穿金甲所以猪灵打你"的真正通道**。
#   秒级清完, 传感器下一刻就把它填回来, 猪灵照打不误。→ 必须每刻清。
# 【两条线各自干什么】
#   ① pig_calm(宏): 精确匹配 AngryAt == 我的 UUID -> 清 AngryAt + angry_at +
#      attack_target。这是"已经打起来的那些", 精确匹配才不会误伤追别人的猪灵。
#   ② pig_near_one: 清 NEAREST_TARGETABLE_PLAYER_NOT_WEARING_GOLD。
#      ★ 这条是按"16 格内"清的, 不是按 UUID —— 那条记忆存的是 UUID, NBT 里
#        匹配它的写法(路径/是否包一层 {uuid:[I;…]})随版本变, 写错就静默失效。
#      ★ 代价: 站在你旁边的**别人**也会一起沾光(猪灵暂时也不挑他)。
#        这是有意的取舍 —— 写不准 = 功能完全没有, 写宽 = 偶尔多护一个人。
#        而且它只掐"不穿金甲"这一条通道: 已经因挨打而记仇的猪灵(AngryAt 有值)
#        不受影响, 该打别人还打别人。
# ============================================================

# ① 穿着门控(认装备用 ~ 部分匹配 + 独有标记)
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["blaze_armor"]}] run return 0

# ② 已记仇的: AngryAt 精确等于我 -> 连根拔掉
data modify storage zx:work ba set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work ba.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work ba.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work ba.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work ba.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/armor/blaze_armor/pig_calm with storage zx:work ba

# ③ "附近有不穿金甲的玩家"这条挑人通道: 16 格内的猪灵一律清掉
execute as @e[type=minecraft:piglin,distance=..16] run function sweetdream:equipment/armor/blaze_armor/pig_near_one
