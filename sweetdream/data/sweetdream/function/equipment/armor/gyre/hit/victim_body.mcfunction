$execute unless entity $(vx_uuid) run return 0

# ⑤ 给目标 + 玩家各打一个"本次施法专用"的标签（arc 里靠它们选区，不用宏）
#   ★ 先清上一轮残留 ★ 目标被击退到 32 格外时 arc_done 那一行清不到它，标签会留一辈子；
#     而下面 ⑦ 的 `limit=1` 可能就先挑中那只旧的 ⇒ 落点按错误的方位算，绕到歪处。
tag @e[tag=zx.gyr_t,distance=..64] remove zx.gyr_t
$tag $(vx_uuid) add zx.gyr_t
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
