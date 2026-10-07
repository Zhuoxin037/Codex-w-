# ============================================================
# sweetdream:tag/ttl_tick —— 通用标签的剩余秒数(每秒一次, 执行者 = 被标记的那只生物)
# ------------------------------------------------------------
# 【谁调它】tag/second_dimension 里 `as @e[tag=zx.tagged] at @s`(三维度各跑一遍)
# 【做什么】
#   ① 兜底初始化: 旧存档里已经挂着的标签没有分数 -> 补满值
#   ② 每秒 -1
#   ③ 归零 -> tag/unmark_one(和"手动摘标签"、"被武器消耗"同一条路, 所以撤销效果
#      只写在 unmark_one 一处就够)
# 【★ "没分数" ≠ 0 ★】没有分数的计分项, `if score @s <obj> matches ..0` 会**直接判定
#   失败**(不是按 0 参与比较) -> 旧标签永远走不到归零、也永远刷不出进度。
#   所以 ① 必须先补值: 判据用 `unless score @s <obj> matches -2147483648..`
#   (-2147483648 是 32 位最小值, 任何存在的分数都 >= 它, 所以 "unless ... matches" 恒为
#   "这条分数不存在")。
# 【★ 时长写两处必须一致 ★】这里(旧标签兜底) 和 tag/mark_one(新贴时给满值)
#   两处的数值要一模一样, 对不上会出现"刚贴上就剩几秒"。check.py 规则 ttl 盯着它。
# 【★ "剩余 ≤3 秒 -> 图标变淡"不在这里做 ★】判据写在 tag/icon_refresh 的位掩码里
#   (淡出位 32/64/128/256/512), 由 tag/icon_render 换淡色字形 —— 本文件只管倒计时。
# ============================================================

# 正在死亡的生物不再维护(本 tick 内它就会被移除, 属性和分数随之消失)
execute if data entity @s {Health:0.0f} run return 0

# ① 兜底: 带标签但没有分数(旧存档残留) -> 补满值
execute if entity @s[tag=zx.status.yuanhai] unless score @s zx.tt.yuanhai matches -2147483648.. run scoreboard players set @s zx.tt.yuanhai 20
execute if entity @s[tag=zx.status.liuhuo] unless score @s zx.tt.liuhuo matches -2147483648.. run scoreboard players set @s zx.tt.liuhuo 15
execute if entity @s[tag=zx.status.yehuo] unless score @s zx.tt.yehuo matches -2147483648.. run scoreboard players set @s zx.tt.yehuo 10
execute if entity @s[tag=zx.status.shixin] unless score @s zx.tt.shixin matches -2147483648.. run scoreboard players set @s zx.tt.shixin 18
execute if entity @s[tag=zx.status.dream] unless score @s zx.tt.dream matches -2147483648.. run scoreboard players set @s zx.tt.dream 15

# ② 每秒 -1
execute if entity @s[tag=zx.status.yuanhai] run scoreboard players remove @s zx.tt.yuanhai 1
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players remove @s zx.tt.liuhuo 1
execute if entity @s[tag=zx.status.yehuo] run scoreboard players remove @s zx.tt.yehuo 1
execute if entity @s[tag=zx.status.shixin] run scoreboard players remove @s zx.tt.shixin 1
execute if entity @s[tag=zx.status.dream] run scoreboard players remove @s zx.tt.dream 1

# ④ 渊海的脉冲(放在归零之前): 施加当刻已经给过 2 秒, 之后每满 5 秒再给一次
#    剩余秒数 15 / 10 / 5 各一次 -> 20 秒里共 4 次(0s / 5s / 10s / 15s), 每次 2 秒。
#    ★ 用原版缓慢而非移速属性: 这是**有意**让它被枯枝园朽木、无光海判定为"有缓慢效果"
#      (套装联动), 见使用教程 9.10。
execute if entity @s[tag=zx.status.yuanhai] if score @s zx.tt.yuanhai matches 15 run effect give @s minecraft:slowness 2 1 true
execute if entity @s[tag=zx.status.yuanhai] if score @s zx.tt.yuanhai matches 10 run effect give @s minecraft:slowness 2 1 true
execute if entity @s[tag=zx.status.yuanhai] if score @s zx.tt.yuanhai matches 5 run effect give @s minecraft:slowness 2 1 true

# ③ 归零 -> 摘标签(撤销效果也在 unmark_one 里, 不必在这里重复写)
execute if score @s zx.tt.yuanhai matches ..0 run function sweetdream:tag/unmark_one {mark:"yuanhai"}
execute if score @s zx.tt.liuhuo matches ..0 run function sweetdream:tag/unmark_one {mark:"liuhuo"}
execute if score @s zx.tt.yehuo matches ..0 run function sweetdream:tag/unmark_one {mark:"yehuo"}
execute if score @s zx.tt.shixin matches ..0 run function sweetdream:tag/unmark_one {mark:"shixin"}
execute if score @s zx.tt.dream matches ..0 run function sweetdream:tag/unmark_one {mark:"dream"}
