# ============================================================
# sweetdream:debug/pal_probe_one —— 探针的"单个光球"分支(被 pal_probe 调)
# ------------------------------------------------------------
# 【谁调用它】debug/pal_probe(execute as @e[tag=zx.pal_col,limit=1,sort=nearest] at @s run)
# 【执行者/位置】最近的那个「色彩」光球
# ============================================================

tellraw @a [{"text":"-- 最近的「色彩」--","color":"yellow"}]
tellraw @a [{"text":"  位置 Pos = ","color":"gray"},{"nbt":"Pos","entity":"@s"}]
tellraw @a [{"text":"  归属 uuid = ","color":"gray"},{"nbt":"data.zx.pal.uuid","entity":"@s"}]
tellraw @a [{"text":"  id=","color":"gray"},{"score":{"name":"@s","objective":"zx.pal_id"}},{"text":"  rng=","color":"gray"},{"score":{"name":"@s","objective":"zx.pal_rng"}},{"text":"  thr=","color":"gray"},{"score":{"name":"@s","objective":"zx.pal_thr"}},{"text":"  已打=","color":"gray"},{"score":{"name":"@s","objective":"zx.pal_n"}},{"text":"  倍率=","color":"gray"},{"score":{"name":"@s","objective":"zx.pal_mul"}},{"text":"  蓝数=","color":"gray"},{"score":{"name":"@s","objective":"zx.pal_blu"}}]

# 候选生物数(半径内、排除 no_damage)—— 直接读 pal_rng 当半径
scoreboard players set #pal_cand zx.meta 0
$execute as @e[type=!#sweetdream:no_damage,distance=..$(rng)] run scoreboard players add #pal_cand zx.meta 1
tellraw @a [{"text":"  半径内候选生物 #pal_cand = ","color":"gray"},{"score":{"name":"#pal_cand","objective":"zx.meta"}}]

# 这一刻挑中的目标数
scoreboard players set #pal_tgt zx.meta 0
execute as @e[tag=zx.pal_t,distance=0..] run scoreboard players add #pal_tgt zx.meta 1
tellraw @a [{"text":"  当前锁定目标 #pal_tgt = ","color":"gray"},{"score":{"name":"#pal_tgt","objective":"zx.meta"}}]
execute if score #pal_cand zx.meta matches 1.. if score #pal_tgt zx.meta matches 0 run tellraw @a [{"text":"  ⚠ 有候选但没锁定 —— 候选全被\"已打过(zx.pal_hit = 本 id)\"排除了","color":"red"}]
execute if score #pal_cand zx.meta matches 0 run tellraw @a [{"text":"  ⚠ 半径内没有任何可追的生物 —— 光球会就地悬停不动(这不是 bug)","color":"red"}]

# 顺带报一下释放者 uuid 能不能反查到(找不到 = ②会立刻自毁)
scoreboard players set #pal_hasby zx.meta 0
data modify storage zx:work fb set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work fb.u0 set from entity @s data.zx.pal.u0
data modify storage zx:work fb.u1 set from entity @s data.zx.pal.u1
data modify storage zx:work fb.u2 set from entity @s data.zx.pal.u2
data modify storage zx:work fb.u3 set from entity @s data.zx.pal.u3
function sweetdream:lib/find_by with storage zx:work fb
execute if entity @a[tag=zx.mc_by,limit=1] run scoreboard players set #pal_hasby zx.meta 1
tag @a remove zx.mc_by
tellraw @a [{"text":"  释放者能否反查到(#pal_hasby, 1=能) = ","color":"gray"},{"score":{"name":"#pal_hasby","objective":"zx.meta"}}]
