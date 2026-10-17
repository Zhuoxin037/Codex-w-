# ============================================================
# sweetdream:equipment/staff/long_night/field_tick —— 「夜原」每秒一跳(执行者 = 夜原 marker)
# ------------------------------------------------------------
# 【谁调用它】lib/second: 三维度各一行 as @e[tag=zx.ln_field,distance=0..] at @s run ...
# 【每秒干什么】
#   ① 钉住圆心(本 marker) —— 后面所有"半径 6"的圈选都以它当基准
#   ② 圈出本秒的"被消耗者" = 半径 6 内**随机 1 个**带「夜火」的生物
#   ③ 表现  ④ 有目标 -> prepare(换身份 + 消耗 + 流火 + 减甲 + 伤害)
#   ⑤ 计时 -1; 归零 -> field_end 收场  ⑥ 摘圆心标签
# 【★ 为什么要 prepare 那一层 ★】消耗走 lib/mark_consume 时「余烬」只认 @s
#   (见 lib/on_consume), 而这里的 @s 是 marker ⇒ 必须反查施法者并换成他的身份。
#   prepare 做的是"位置留在圆心、身份换成施法者"(execute at @s as <施法者>)。
# 【为什么每秒不是每刻】文案"每秒消耗…" —— 每秒一结算。
# 【表现为什么每秒一次就够】夜原不是"隐形实体", 只是一片区域效果 ⇒ 每秒画一圈
#   (RULES: 要"看得见"的是**隐形实体**, 那是每刻铺)。
# ============================================================

# ① 圆心 = 本 marker
tag @e[tag=zx.ln_center,distance=0..] remove zx.ln_center
tag @s add zx.ln_center

# ② 本秒的被消耗者: 半径 6 内随机 1 个带「夜火」的生物
#   ★ sort=random 每次求值都会重挑, 所以立刻冻结成标签 zx.ln_tgt
tag @e[tag=zx.ln_tgt,distance=0..] remove zx.ln_tgt
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..6,tag=zx.status.yehuo,sort=random,limit=1] add zx.ln_tgt

# ③ 表现: 半径 6 的暗色气流(夜原的地面范围)
particle minecraft:dust{color:[0.3,0.1,0.48],scale:1.6} ~ ~0.3 ~ 5.2 0.25 5.2 0.02 44 normal
particle minecraft:soul_fire_flame ~ ~0.5 ~ 4.4 0.3 4.4 0.01 26 normal
playsound minecraft:block.conduit.ambient player @a ~ ~ ~ 0.3 0.7

# ④ 有目标才消耗(没有目标也照常推进计时 —— 夜原只是"每秒尝试一次")
execute if entity @e[tag=zx.ln_tgt,distance=0..,limit=1] run function sweetdream:equipment/staff/long_night/prepare

# ⑤ 计时 -1; 归零收场(先撤减甲、再删术阵、最后 kill)
scoreboard players remove @s zx.ln_ft 1
execute if score @s zx.ln_ft matches ..0 run function sweetdream:equipment/staff/long_night/field_end

# ⑥ 摘圆心标签(还在继续的那一路; 收场那一路已 kill 自己, 摘不摘都无所谓)
tag @e[tag=zx.ln_center,distance=0..] remove zx.ln_center
