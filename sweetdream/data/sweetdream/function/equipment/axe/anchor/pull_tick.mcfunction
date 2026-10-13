# ============================================================
# sweetdream:equipment/axe/anchor/pull_tick —— 沉锚 · 牵引(每刻一小段)
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute as @a[scores={zx.an_pull=1..}] at @s run ...
# 【执行者/位置】施法者本人
# 【做什么】每刻把自己朝"被锚住的那只"(zx.an_tgt) 拉 0.5 格, 直到:
#   ① 目标没了(zx.an_tgt 不在) / ② 已经贴到 1.8 格内 / ③ 22 刻用完
#   -> 停下并调 pull_end(就地结算 impact + 清状态)。
# 【★ 为什么"有过程" ★】2026-10-12 用户拍板: 拉近要看得见过程, 不要瞬移。
#   0.5 格/刻 = 10 格/秒 —— 10 格的目标 20 刻拉完, 客户端每刻都收到新坐标,
#   看着是"被拽过去"的一段轨迹, 而不是"啪一下到脸上"。
# 【★ 为什么一步一小段 tp 而不是给 Motion ★】tp 能"撞墙就不动"
#   (if block replaceable), 不会把人塞进墙里; Motion 会被墙里的碰撞挤出去, 落点不可控。
# 【★ 为什么只认 tag 不认 uuid ★】一次牵引只有 0.7 秒, 两个人同时放沉锚的概率极低;
#   真撞上最坏也就是拉向"离自己最近的那个锚", 不影响正确性(结束时必清 tag)。
# 【★ 收尾必须 return ★】pull_end 会清 zx.an_tgt; 不 return 的话下面那句
#   `at @e[tag=zx.an_tgt]` 会选中"另一个人的锚"或空集, 出现莫名的一步位移。
# ============================================================

# ① 目标不在了 -> 收工(pull_end 里面会用 @e[tag=zx.an_tgt] 判空, 所以这里只置 0)
execute unless entity @e[tag=zx.an_tgt,distance=0..,limit=1] run scoreboard players set @s zx.an_pull 0

# ② 已经贴上(1.8 格内) -> 收工
execute if entity @e[tag=zx.an_tgt,distance=..1.8,limit=1] run scoreboard players set @s zx.an_pull 0

# ③ 到点了: 结算 + 退出
execute if score @s zx.an_pull matches ..0 run function sweetdream:equipment/axe/anchor/pull_end
execute if score @s zx.an_pull matches ..0 run return 0

# ④ 朝目标滑一步(0.5 格): **从自己出发、朝目标方向前进 0.5 格**; 那格不可站(墙里)就这一步不动。
#   ★ 2026-10-12 修: 旧版写成 `at 目标 facing @s feet positioned ^ ^ ^-0.5` ——
#     从锚的位置朝"背离玩家"退 0.5 格 = 直接落到锚身上 ⇒ **一步就贴上, 表现为瞬移**。
#     正解是 `at @s`(自己) + `facing 目标` + `^ ^ ^+0.5`(前进): 每刻只挪 0.5 格, 20 格/秒太多?
#     —— 0.5 格/刻 = 10 格/秒, 客户端每刻收到新坐标, 看着就是"被拽过去"的一段轨迹。
#   ★ 用 tp 而不是 Motion: tp 能"落点不可站就不动"(if block replaceable), 不会把人塞进墙里。
execute at @s facing entity @e[tag=zx.an_tgt,distance=0..,sort=nearest,limit=1] feet positioned ^ ^ ^0.5 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~

# ⑤ 拖尾 + 计时
particle minecraft:cloud ~ ~0.1 ~ 0.15 0.1 0.15 0.02 3 normal
scoreboard players remove @s zx.an_pull 1
