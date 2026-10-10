# ============================================================
# sweetdream:debug/pal_probe —— 调色盘「色彩」现场探针(手工调用)
# ------------------------------------------------------------
# 【怎么用】聊天栏敲:  /function sweetdream:debug/pal_probe
#   (建议: 先放一次调色盘技能, 再站到光球附近按这个 —— 它报"最近那个光球"的读数)
# 【看什么】① 场上还有几个光球; ② 最近那个光球的 位置 / id / 半径 / 阀值 / 已打数 / 倍率;
#   ③ **它这一刻有没有挑到目标**(#pal_tgt > 0 = 挑到了, 0 = 半径内没锁上);
#   ④ 半径内"候选生物"总数(#pal_cand) —— cand 有数而 tgt = 0 ⇒ 全被"已打过"排除了。
# 【判读】cand = 0 ⇒ 光球附近根本没有生物可追, 于是它就地悬停 ——
#         这是**正常**的(文案: 追踪离自身最近的生物; 没生物可追自然不动), 不是 bug。
# ============================================================

tellraw @a [{"text":"===== 调色盘「色彩」探针 =====","color":"gold"}]
tellraw @a [{"text":"#now(manacore.meta) = ","color":"gray"},{"score":{"name":"#now","objective":"manacore.meta"}}]

# ① 本维度光球数
scoreboard players set #pal_cnt zx.meta 0
execute as @e[tag=zx.pal_col,distance=0..] run scoreboard players add #pal_cnt zx.meta 1
tellraw @a [{"text":"本维度光球数 = ","color":"gray"},{"score":{"name":"#pal_cnt","objective":"zx.meta"}}]
execute if score #pal_cnt zx.meta matches 0 run tellraw @a [{"text":"  (场上没有「色彩」—— 先放一次技能再探)","color":"red"}]

# ② 最近那个光球的详细读数
#   ★ pal_probe_one 里要用 $(rng) 拼选择器, 所以先把它的 pal_rng 抄进宏节点再调用
data modify storage zx:work pc set value {id:0,rng:12}
execute as @e[tag=zx.pal_col,distance=0..,limit=1,sort=nearest] run execute store result storage zx:work pc.rng int 1 run scoreboard players get @s zx.pal_rng
execute as @e[tag=zx.pal_col,distance=0..,limit=1,sort=nearest] at @s run function sweetdream:debug/pal_probe_one with storage zx:work pc
