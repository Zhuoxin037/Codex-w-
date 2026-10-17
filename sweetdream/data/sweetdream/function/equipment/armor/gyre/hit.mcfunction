# ============================================================
# sweetdream:equipment/armor/gyre/hit —— 回旋 ·「旋步」兑现（近战命中触发）
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/gyre_hit（player_hurt_entity，只算平A）
# 【执行者】动手的玩家
# 【技能原文（lore 逐字）】
#   "「旋步」：下一次普通近战命中生物后消耗「旋步」，使自身呈圆形轨迹移动至命中生物
#    的背后，并对本次命中的生物额外造成一次 24 点固定伤害，对移动过程中碰到的生物
#    造成一次 30 点固定伤害。遇到障碍即停。"
# 【★ 兑现顺序 ★】先"消耗旋步"（防同一刻重入），再钉目标、再算落点、再起步。
# 【★ 目标怎么钉 ★】lib/victim（同失血/返照）：进度不能把实体传进函数，靠
#   last_hurt_by_player + HurtTime 反查"刚才这一下打的是哪只"。
# 【★ 2026-10-17 改：绕后变成"有过程" ★】用户反馈旧版是瞬移。现在：
#   ① 这里一次性把三个落点算成 marker（zx.gyr_w1/w2/w3，角度 90°/150°/180°）；
#      —— 必须先算，因为角度基准是"命中那一刻玩家所在的方位"，玩家一动就歪。
#   ② 设 zx.gyr_st = 1，之后由 core/tick 每刻推 arc（7 刻内分三步绕到背后，收尾打 24 点）。
#      ★ 这里**不再**顺手调一次 arc ★ 状态号从 1 起，若同刻再调一次，core/tick 会在
#      下一克从 2 继续 ⇒ 第 1 段被跳过（直接从侧面开始）。删掉那次调用后，最多晚
#      1 刻（0.05 秒）起手，肉眼无感，但状态机永远只前进一步。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/armor/gyre_hit

# ① 穿着门控（护腿）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["gyre"]}] run return 0

# ② 没有「旋步」（或已过期）→ 收工
execute if score @s zx.gy_wd < #now manacore.meta run return 0

# ③ 消耗「旋步」
scoreboard players set @s zx.gy_wd 0

# ④ 钉死刚命中的那只
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ⑤ 给目标 + 玩家各打一个"本次施法专用"的标签（arc 里靠它们选区，不用宏）
#   ★ 先清上一轮残留 ★ 目标被击退到 32 格外时 arc_done 那一行清不到它，标签会留一辈子；
#     而下面 ⑦ 的 `limit=1` 可能就先挑中那只旧的 ⇒ 落点按错误的方位算，绕到歪处。
tag @e[tag=zx.gyr_t,distance=..64] remove zx.gyr_t
tag @e[tag=zx.victim,distance=..32] add zx.gyr_t
tag @s add zx.gyr_p

# ⑥ 清掉上一次可能残留的落点（中途退出/被清场）
kill @e[tag=zx.gyr_way,distance=..32]

# ⑦ 算三个落点 —— 相对"目标看向玩家"的方位（玩家正前方是 0°，顺时针绕）：
#      w1 = +90°、1.5 格（侧面）
#      w2 = +150°、1.5 格（斜后方）
#      w3 = +180°、1.0 格（正背后）
#    ★ `at <目标> facing entity @s feet`：位置在目标、朝向指向玩家；执行者仍是玩家，
#      所以后面 positioned 的 ^ 系是"从目标射向玩家"的方向。
execute at @e[tag=zx.gyr_t,limit=1,distance=..32] facing entity @s feet rotated ~90 0 positioned ^ ^ ^1.5 run summon minecraft:marker ~ ~ ~ {Tags:["zx.gyr_way","zx.gyr_w1"]}
execute at @e[tag=zx.gyr_t,limit=1,distance=..32] facing entity @s feet rotated ~150 0 positioned ^ ^ ^1.5 run summon minecraft:marker ~ ~ ~ {Tags:["zx.gyr_way","zx.gyr_w2"]}
execute at @e[tag=zx.gyr_t,limit=1,distance=..32] facing entity @s feet rotated ~180 0 positioned ^ ^ ^1.0 run summon minecraft:marker ~ ~ ~ {Tags:["zx.gyr_way","zx.gyr_w3"]}

# ⑧ 起步：置 1 = 第 1 步（下一克由 core/tick 推 arc 走段 1）
#   ★ 必须 ≥1 ★ 0 是"未激活"，core/tick 的选择器是 `zx.gyr_st=1..` —— 写成 0 就永远不动。
scoreboard players set @s zx.gyr_st 1
