# ============================================================
# sweetdream:equipment/armor/rain_trace/dot_spawn —— 在**当前执行位置**生成一个水迹点
# ------------------------------------------------------------
# 【宏参数】zx:rain dot {dmg,u0,u1,u2,u3}      【执行者】玩家
# 【执行位置】= 水迹点要出现的位置（由调用方决定，可能不是玩家所在，见 sow ⑥）
# 【生成物】minecraft:item_display（标签 zx.rt_dot + 临时标记 zx.rt_new）
#   · 外观 = 资源包模型 sweetdream:rain_puddle（一张平铺的水迹贴图）
#   · data.zx.dmg = 释放者基础攻击力 ×2；data.zx.u = 释放者 UUID 四整数
#   · 计时 zx.rt_life = 100 刻（5 秒），由 dot_tick 每刻递减到 0 自毁
#
# 【★ 2026-10-17：从 marker 换成 item_display ★】
#   用户原话："给雨迹的水迹搞个模型贴图吧，不然看不见我也不知道有没有成功。"
#   marker 是纯逻辑实体，客户端什么都不画；item_display 能把一个物品模型
#   贴在地面上，配合 brightness 暗处也看得见。逻辑（判定/计时/伤害）一行都没变，
#   只是换了载体 —— `@e[tag=zx.rt_dot,distance=..1.6]` 照样选得到它。
#
# 【★ 2026-10-18：生成位置从"玩家脚下"改成"当前执行位置" ★】
#   上一版首行是 `execute at @s run summon`。撒点只发生在玩家脚下时看不出问题，
#   但补点（sow ⑥）要用 `positioned ^ ^ ^1.3` 把执行位置摆到"上一点 → 玩家"的
#   连线上；再套一层 `at @s` 就把点拽回玩家身上 ⇒ 补点全堆在一处，路径中间
#   照样空着。现在直接 `summon ~ ~ ~`：位置完全听调用方的。
#
# 【★ 不用 transformation 旋转 ★】
#   item_display 的模型空间里 Y 就是世界 Y —— 模型直接把水迹做成 XZ 平面的薄板
#   （见 models/item/rain_puddle.json 的 up 面），它就天然躺平。
#   反过来"先做竖板再绕 X 轴 -90°"是错的：旋转以模型原点为轴心，
#   结果整块板会下沉半格、还向 -Z 偏移一格，得再拿 translation 反推补偿。
#   translation 只抬高 0.02 格：贴地但不与方块面重合（防 z-fighting）。
#
# 【★ 2026-10-17 第二次修：为什么"完全看不见" ★】
#   item model 的渲染原点恒在 (8,8,8)（16 单位 = 1 格）—— y 写 0 就等于把板
#   沉到实体下方 0.5 格，而实体又是召唤在玩家脚部（方块顶面）⇒ 整块板埋在
#   方块内部，客户端一个像素都不画。必须把 y 写在 **8** 附近才是"贴地"。
#   同批还修了 view_range：display 的视距 = 模型 bbox × view_range，水迹板只有
#   0.0125 格厚、bbox 极小 ⇒ 2.0 实际只画身边两三格，走完 8 格回头看就"没连到
#   终点"。现在拉到 8.0f，整条水带一次性都能看见。
#
# 【view_range】display 实体的剔除距离 ≈ 模型 bbox × view_range。水迹板薄到
#   0.0125 格，默认 1.0 时只画身边一格多 ⇒ 必须显式放大（现 8.0f）。
#   shadow 关掉：否则地面上会跟着出现一排小黑影，比水迹本身还显眼。
#
# 【zx.rt_last：最新水迹点的锚点标签】
#   sow ⑥ 的补点要靠"从上一点朝玩家走 1.3 格"来定位，需要一个**实体**当参照物
#   （坐标计分项没法塞进 positioned）。所以每生成一个点就把 zx.rt_last 挪到它身上
#   —— 全维度只允许有一个（先摘后加）。点 5 秒后自毁，但那时窗口早结束了。
# ============================================================

# 【★ 2026-10-18: transformation 必须写全四个字段 ★】
#   1.21.5 的 Transformation codec 要求 translation / left_rotation / scale /
#   right_rotation **同时存在**。只写 translation+scale 时每条 summon 都抛
#   `Failed to read field (transformation={...})`（实测一次冲刺刷了 20 条，
#   每条都要走异常 + 写日志，白烧性能）。旋转部分给单位四元数 = 不旋转。
$summon minecraft:item_display ~ ~ ~ {Tags:["zx.rt_dot","zx.rt_new"],item:{id:"minecraft:paper",count:1,components:{"minecraft:item_model":"sweetdream:rain_puddle"}},transformation:{translation:[0f,0.02f,0f],left_rotation:[0f,0f,0f,1f],scale:[1f,1f,1f],right_rotation:[0f,0f,0f,1f]},brightness:{sky:15,block:15},view_range:8.0f,shadow_radius:0f,shadow_strength:0f,data:{zx:{dmg:$(dmg),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 设寿命：刚生成的那只在执行位置 1 格内（自己刚 summon 的，不会抓错）
scoreboard players set @e[tag=zx.rt_new,distance=..1,limit=1] zx.rt_life 100

# 【★ 2026-10-18：记账"玩家自己的上一滴" ★】
#   fill 每次都要知道"上一滴在哪"，它读的是玩家计分项 zx.rt_lx/ly/lz。
#   ★ 必须用**这一只实体的真实坐标**，不能用玩家的 Pos —— 补点的时候执行位置
#     根本不在玩家身上（在两点连线上），拿玩家坐标会把整条链往回拽，越补越偏。
#   ★ 必须趁 zx.rt_new 还在身上时读：`zx.rt_dot` 在 `distance=..1` 内仍可能
#     命中相邻的一滴（撞墙、上下坡、贴墙走时点距会被压到 1 格以内），
#     而 rt_new 是**只有这一只**带的临时标签，绝对精确。
#   ★ 三行都套 `if entity`：万一 summon 没成功，`store result` 会把 rt_lx 写成 0
#     ⇒ 下一轮 fill 会把"0,0,0 到玩家"当距离，一次撒 16 个点沿对角线飞出去。
execute if entity @e[tag=zx.rt_new,distance=..1,limit=1] store result score @s zx.rt_lx run data get entity @e[tag=zx.rt_new,distance=..1,limit=1] Pos[0] 100
execute if entity @e[tag=zx.rt_new,distance=..1,limit=1] store result score @s zx.rt_ly run data get entity @e[tag=zx.rt_new,distance=..1,limit=1] Pos[1] 100
execute if entity @e[tag=zx.rt_new,distance=..1,limit=1] store result score @s zx.rt_lz run data get entity @e[tag=zx.rt_new,distance=..1,limit=1] Pos[2] 100

tag @e[tag=zx.rt_new,distance=..1] remove zx.rt_new

# 锚点：把"最新水迹点"挪到刚生成的这一只身上（fill 的定位基准）
tag @e[tag=zx.rt_last,distance=0..] remove zx.rt_last
tag @e[tag=zx.rt_dot,distance=..1,sort=nearest,limit=1] add zx.rt_last
