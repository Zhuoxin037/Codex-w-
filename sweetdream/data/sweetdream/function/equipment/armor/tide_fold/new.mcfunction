# ============================================================
# sweetdream:equipment/armor/tide_fold/new —— 在自身位置立一面水墙
# ------------------------------------------------------------
# 【执行者】玩家(@s), 位置 = 自身位置。  【@s 身份】玩家
# 【★ 文案(逐字)】"自身在消耗「渊海」或消耗了 150 魔力值后在自身位置生成一面长 8 格
#   持续 10 秒的水墙，水墙同时只能存在 4 个。"
# 【★★ 判定口径: 与「共鸣」(staff/chime)完全一致（2026-10-25 用户拍板）★★
#   用户原话: "折潮的水墙判定同共鸣的判定"。共鸣那套（见 chime/pass_check 头注释）:
#     · **每刻**驱动（刻级事件, 每秒轮询会漏）;
#     · 判定用**球形 distance**, 不是线段/判定盒;
#     · **找法球要把基准抬高 1.6 格**（水晶/墙召唤在脚底, 法球飞在眼睛高度,
#       三维 distance 光高度差就 > 1.5 ⇒ 不抬就**恒不成立**, 2026-10-09 实测事故）;
#     · 自己人的法球靠 `nbt={data:{u0..u3}}` 比对;
#     · 每颗球对这件东西只触发一次（球上打一次性戳）;
#     · 先做"本刻根本不可能有事件"的粗筛闸, 省掉整段开销。
#   ⇒ 水墙是一面**长 8 格的墙**而不是一个点, 所以沿墙的本地 X 轴（视线的右方向）
#     铺 5 个采样点(-4/-2/0/+2/+4), 每个点跑一次同一套球形判定。
#     ★ 这样墙的朝向可以是**任意角度**（marker 记下生成那一刻的 yaw,
#       `execute at <墙> positioned ^x ^ ^` 自动带上那个朝向）,
#       不需要量化成轴向 —— 也就绕开了"dx/dy/dz 只能是轴对齐整数盒"的死结。
# 【4 个上限】满了**不再生成, 也不消耗掉触发它的那次消费** ⇒ 门控放在最前面。
# 【出参】#tf_ok zx.meta = 1 生成成功 / 0 已满没生成
#   ★ spend(消费 150 魔力那条)必须"生成成功了才扣账"。
# ============================================================

scoreboard players set #tf_ok zx.meta 0

# ① 门控: 4 面封顶（★ distance=0.. 限定本维度, 裸 @e 会跨维度重复计数）

# ② 分配墙编号（0..3; 只用于"同一面墙对同一只生物 5 秒一次"的节流）
scoreboard players add #tf_seq zx.meta 1

# ③ 归属: 一律走 manacore.u0..u3（已经缓存好的 4 个整数分数）, **绝不读玩家 NBT**
#    ★ `data get entity @s UUID[0]` 会把整份玩家 NBT 序列化一遍（≈10 ms/次, 卡顿坑 1）。
scoreboard players operation #tf_u0 zx.meta = @s manacore.u0
scoreboard players operation #tf_u1 zx.meta = @s manacore.u1
scoreboard players operation #tf_u2 zx.meta = @s manacore.u2
scoreboard players operation #tf_u3 zx.meta = @s manacore.u3
scoreboard players set #tf_count zx.meta 0
execute as @e[tag=zx.tf_wall,distance=0..] if score @s zx.tf_u0 = #tf_u0 zx.meta if score @s zx.tf_u1 = #tf_u1 zx.meta if score @s zx.tf_u2 = #tf_u2 zx.meta if score @s zx.tf_u3 = #tf_u3 zx.meta run scoreboard players add #tf_count zx.meta 1
execute if score #tf_count zx.meta matches 4.. run return 0

# ④ 朝向: 生成那一刻的 yaw（写进 marker 的 Rotation, 后面 `^` 偏移靠它）
#    ★ 读法是玩家 NBT, 但**只有立墙这一次**（每 150 魔力 / 每次消费渊海才跑一次）,
#      不是每刻热路径 —— 与"每刻反查玩家"完全是两回事。
scoreboard players set #tf_y zx.meta 0
execute store result score #tf_y zx.meta run data get entity @s Rotation[0]

# ⑤ 摆进宏节点, 交给 new_go（summon 的 Rotation 必须字面量 ⇒ 只能走宏）
execute store result storage zx:work tf.u0 int 1 run scoreboard players get #tf_u0 zx.meta
execute store result storage zx:work tf.u1 int 1 run scoreboard players get #tf_u1 zx.meta
execute store result storage zx:work tf.u2 int 1 run scoreboard players get #tf_u2 zx.meta
execute store result storage zx:work tf.u3 int 1 run scoreboard players get #tf_u3 zx.meta
execute store result storage zx:work tf.id int 1 run scoreboard players get #tf_seq zx.meta
execute store result storage zx:work tf.yaw int 1 run scoreboard players get #tf_y zx.meta
function sweetdream:equipment/armor/tide_fold/new_go with storage zx:work tf
