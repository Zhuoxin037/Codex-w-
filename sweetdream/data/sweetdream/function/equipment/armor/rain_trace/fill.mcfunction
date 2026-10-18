# ============================================================
# sweetdream:equipment/armor/rain_trace/fill —— 沿"上一个水迹点 → 玩家"按固定间距铺满
# ------------------------------------------------------------
# 【谁调用它】① rain_trace/sow（每刻，位移已确认时）
#             ② **它自己**（递归：铺完一段，剩下的继续铺）
# 【执行者】玩家
# 【执行位置】通常就是玩家脚下（不影响结果 —— 点的位置由 @e 锚点算，见 ④）
#
# 【★ 2026-10-18 第四次改：为什么要递归，而不是"补一两档" ★】
#   上一版是"一步跨 >2.6 格就在中间补 1 个，>3.9 格补 2 个"，档位写死的。
#   用户实测三件位移技能各断一处：
#     · 无息（去程 0.5 格/刻 × 16 步 = 8 格，再以 2 格/刻闪回）→ "大约到中间就断了"
#     · 影刃（一步跳得远）→ "前面一段没有"
#     · 沉锚（后段位移更长）→ "后面一段没了"
#   前两条的共同点是**实际跨度超出了写死的档位**：补 2 个点最多盖到 2.6 格，
#   一步跳 4 格就空出 1.4 格；跳 8 格就空出 5.4 格 —— 板宽 2.2 格根本搭不上。
#   ⇒ 现在不再"猜跨度"，而是**循环**：只要离上一点还差 ≥1.4 格，就沿连线再走
#     1.4 格撒一个，撒完重新算 —— 跨 0.5 格、3 格、15 格，走法完全一样。
#
# 【为什么每段是 1.4 格】
#   水迹板宽 2.2 格（见资源包 models/item/rain_puddle.json），贴图四边余弦渐隐
#   （中心 alpha 135，到边缘平方级衰减到 0）。段长 1.4 ⇒ 相邻点只重叠 0.8 格，
#   而重叠区起始半径 = 1.1-0.8 = 0.7 格，那里 alpha 只剩 26/255 ⇒ 叠上去几乎看不出。
#   ★ 2026-10-18 第五次改：上一版取 0.9 格（= 板宽的 41%），重叠 1.3 格，
#     重叠区一直压到对方中心附近，用户实测"间隔太小、都重叠了"。
#     下限约束：段长必须 < 板宽 2.2，否则中间露缝；上限约束：段长 > 1.1 才不至于
#     让两摊的中心区叠在一起。1.4 正好在中间。
#
# 【递归怎么收敛】④ 撒完一个点之后，dot_spawn 会把玩家自己的 `zx.rt_lx/ly/lz`
#   更新成**刚生成那一只的真实坐标** ⇒ 下一轮重算的 #fl_d 自然少了 1.4 格。
#   万一因为位置取整（×100 存整数）导致某轮没缩短，① 的计数器兜底（16 段 = 22.4 格）。
#
# 【计数器为什么放 zx.meta 的假玩家上】
#   它是"本次 sow 内部"的临时量，跨玩家不能混（否则两个人同时冲会抢同一个计数）。
#   但 lib/step 是 `as @a[...]` **逐个**执行、每次都从 sow 开头重置 #rt_n，
#   所以先后串行、不会串味；也省掉一个"必须进 player_reset"的玩家计分项。
# ============================================================

# ① 次数保护：一次 sow 最多铺 16 段（1.4 × 16 = 22.4 格，够沉锚/影刃单步跨度）
scoreboard players remove #rt_n zx.meta 1
execute if score #rt_n zx.meta matches ..0 run return 0

# ② 还差多远：当前玩家坐标 − 上一个水迹点（全部 ×100 整数）
execute store result score #fl_x zx.meta run data get entity @s Pos[0] 100
execute store result score #fl_y zx.meta run data get entity @s Pos[1] 100
execute store result score #fl_z zx.meta run data get entity @s Pos[2] 100

scoreboard players operation #fl_dx zx.meta = #fl_x zx.meta
scoreboard players operation #fl_dx zx.meta -= @s zx.rt_lx
scoreboard players operation #fl_dz zx.meta = #fl_z zx.meta
scoreboard players operation #fl_dz zx.meta -= @s zx.rt_lz
scoreboard players operation #fl_dy zx.meta = #fl_y zx.meta
scoreboard players operation #fl_dy zx.meta -= @s zx.rt_ly

#   ★ 钳位防平方溢出：|d| 上限 30000（300 格）⇒ 单轴平方 9e8，两轴相加 1.8e9 < 2^31。
#     不钳位的话"rt_l 还没初始化（=0）而玩家在 x=1500 格"会把平方算成 2.25e10，
#     溢出成负数 ⇒ 判据恒假 ⇒ 一个点都不撒（这类静默失效最难查）。
execute if score #fl_dx zx.meta matches 30000.. run scoreboard players set #fl_dx zx.meta 30000
execute if score #fl_dx zx.meta matches ..-30000 run scoreboard players set #fl_dx zx.meta -30000
execute if score #fl_dz zx.meta matches 30000.. run scoreboard players set #fl_dz zx.meta 30000
execute if score #fl_dz zx.meta matches ..-30000 run scoreboard players set #fl_dz zx.meta -30000

scoreboard players operation #fl_d zx.meta = #fl_dx zx.meta
scoreboard players operation #fl_d zx.meta *= #fl_dx zx.meta
scoreboard players operation #fl_t zx.meta = #fl_dz zx.meta
scoreboard players operation #fl_t zx.meta *= #fl_dz zx.meta
scoreboard players operation #fl_d zx.meta += #fl_t zx.meta

# ③ 够近了就收：水平 < 1.4 格（140² = 19600）且 竖直 < 1.3 格（130）
execute if score #fl_d zx.meta matches ..19599 if score #fl_dy zx.meta matches -129..129 run return 0

# ④ 在"上一个水迹点"处朝玩家走 1.4 格，撒一个
#   ★ `at @e[...]` 只换执行位置、**不换执行者** —— @s 仍是玩家，所以
#     `facing entity @s feet` 的朝向 = "从上一个点指向玩家"，`^ ^ ^1.4` 就落在连线上。
#   ★ `distance=0..` 只是给选择器一个位置基准（把搜索锁在当前维度，裸 @e 会跨维度）。
execute unless entity @e[tag=zx.rt_last,distance=0..,limit=1] run return 0
execute at @e[tag=zx.rt_last,distance=0..,limit=1] facing entity @s feet positioned ^ ^ ^1.4 run function sweetdream:equipment/armor/rain_trace/sow_now

# ⑤ 递归：剩下的距离继续铺（dot_spawn 已在 ④ 里把 rt_l 推进到刚撒的那只身上）
function sweetdream:equipment/armor/rain_trace/fill
