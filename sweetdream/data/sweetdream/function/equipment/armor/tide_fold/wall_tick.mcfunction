# ============================================================
# sweetdream:equipment/armor/tide_fold/wall_tick —— 水墙每刻（由 core/tick 驱动）
# ------------------------------------------------------------
# 【执行者】墙 marker(@s)   【位置/朝向】at @s（脚底; 朝向 = 生成那一刻的 yaw）
# 【★ 文案(逐字)】"穿过水墙的生物会被附加「渊海」并获得 3 秒缓慢Ⅱ，自身穿过水墙时
#   获得 3 秒迅捷Ⅱ，且每 2 秒穿过时可以恢复自身相当于自身最大魔力值 1% 的魔力值。"
# 【★★ 判定口径 = 「共鸣」(staff/chime) ★★（2026-10-25 用户拍板）
#   ① **每刻**跑（"穿过"是刻级事件, 每秒轮询会漏 —— 共鸣 pass_check 头注释同款理由）;
#   ② 判定是**球形 distance**, 不是线段相交 / 判定盒;
#   ③ 找法球**必须把基准抬高 1.6 格**（墙召唤在脚底, 法球飞在眼睛高度, 三维
#      distance 光高度差就 >1.5 ⇒ 不抬**恒不成立**。共鸣 2026-10-09 的真实事故）;
#   ④ 自己人的法球靠 `nbt={data:{u0..u3}}` 比对, 且每颗球只打一次戳;
#   ⑤ 先跑"本刻根本不可能有事件"的**粗筛闸**, 省掉整段（照抄 pass_check ⓪'）。
# 【墙是 8 格长的】沿本地 X 轴（= 视线的右方向）铺 5 个采样点(-4/-2/0/+2/+4),
#   每个点套一次上面那套球形判定 —— 与 fx_wall 用同一组点, 免得表现和判定错位。
#   ★ 采样半径 2 格 ⇒ 墙的实际厚度 ≈ 4 格。别改成 1 格: 每刻移动 >2 格的生物
#     (末影人瞬移 / 弹射)会"两刻都在墙外" ⇒ 整次穿过被漏掉。
# 【★ 归属怎么带 ★】墙活 10 秒, 触发时早就没有施法者上下文 ⇒ UUID 四个整数在
#   **立墙那一刻**就抄在墙身上(zx.tf_u0..u3), 这里搬进 storage 再往下传(零 NBT)。
# ============================================================

# ① 寿命
scoreboard players remove @s zx.tf_life 1
execute if score @s zx.tf_life matches ..0 run return run function sweetdream:equipment/armor/tide_fold/wall_end

# ② 粒子（每 5 刻一次, 别每刻刷 —— 4 面墙 × 每刻 8 条粒子太吵也费）
scoreboard players remove @s zx.tf_fx 1
execute if score @s zx.tf_fx matches ..0 run function sweetdream:equipment/armor/tide_fold/fx_wall
execute if score @s zx.tf_fx matches ..0 run scoreboard players set @s zx.tf_fx 5

# ③ 粗筛闸(照抄共鸣 pass_check ⓪'): 墙附近什么都没有 ⇒ 后面的整段全是白烧。
#    ★ 半径 7 = 采样半长 4 + 采样半径 2 + 一点余量。
execute unless entity @e[type=!minecraft:marker,distance=..7,limit=1] run return 0

# ④ 把墙的归属/编号搬进 storage（下面的 probe 是宏叶子, 只能吃 storage）
execute store result storage zx:work tf.u0 int 1 run scoreboard players get @s zx.tf_u0
execute store result storage zx:work tf.u1 int 1 run scoreboard players get @s zx.tf_u1
execute store result storage zx:work tf.u2 int 1 run scoreboard players get @s zx.tf_u2
execute store result storage zx:work tf.u3 int 1 run scoreboard players get @s zx.tf_u3
execute store result storage zx:work tf.id int 1 run scoreboard players get @s zx.tf_id

# ⑤ 沿墙长边的 5 个采样点（★ `at @s` 已把旋转也设成墙的朝向 ⇒ `^x` 就是墙的长边）
execute at @s positioned ^-4 ^ ^ run function sweetdream:equipment/armor/tide_fold/probe with storage zx:work tf
execute at @s positioned ^-2 ^ ^ run function sweetdream:equipment/armor/tide_fold/probe with storage zx:work tf
execute at @s positioned ^0 ^ ^ run function sweetdream:equipment/armor/tide_fold/probe with storage zx:work tf
execute at @s positioned ^2 ^ ^ run function sweetdream:equipment/armor/tide_fold/probe with storage zx:work tf
execute at @s positioned ^4 ^ ^ run function sweetdream:equipment/armor/tide_fold/probe with storage zx:work tf

execute unless score @s zx.tf_exp matches 1 if score @s zx.tf_fx matches 5 run function sweetdream:equipment/armor/tide_fold/expand_check
