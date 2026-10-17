# ============================================================
# sweetdream:equipment/armor/rain_trace/dot_spawn —— 在**玩家脚下**生成一个水迹点
# ------------------------------------------------------------
# 【宏参数】zx:rain dot {dmg,u0,u1,u2,u3}      【执行者】玩家
# 【生成物】minecraft:item_display（标签 zx.rt_dot + 临时标记 zx.rt_new）
#   · 外观 = 资源包模型 sweetdream:rain_puddle（一张平铺的水洼贴图）
#   · data.zx.dmg = 释放者基础攻击力 ×2；data.zx.u = 释放者 UUID 四整数
#   · 计时 zx.rt_life = 100 刻（5 秒），由 dot_tick 每刻递减到 0 自毁
#
# 【★ 2026-10-17：从 marker 换成 item_display ★】
#   用户原话："给雨迹的水迹搞个模型贴图吧，不然看不见我也不知道有没有成功。"
#   marker 是纯逻辑实体，客户端什么都不画；item_display 能把一个物品模型
#   贴在地面上，配合 brightness 暗处也看得见。逻辑（判定/计时/伤害）一行都没变，
#   只是换了载体 —— `@e[tag=zx.rt_dot,distance=..1.6]` 照样选得到它。
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
# 【为什么用 `at @s` 而不是 positioned 字面量坐标】
#   旧版把坐标取整格、用宏拼进 `positioned $(x) $(y) $(z)`（因为 positioned 只吃字面量）。
#   现在逐刻就地撒点，直接用执行者自己的位置最准 —— 顺带省掉"取整格"那套宏，
#   也避免"两个点取整到同一格"的重叠。
#
# 【view_range】display 实体的剔除距离 ≈ 模型 bbox × view_range。水迹板薄到
#   0.0125 格，默认 1.0 时只画身边一格多 ⇒ 必须显式放大（现 8.0f）。
#   shadow 关掉：否则地面上会跟着出现一排小黑影，比水迹本身还显眼。
# ============================================================

$execute at @s run summon minecraft:item_display ~ ~ ~ {Tags:["zx.rt_dot","zx.rt_new"],item:{id:"minecraft:paper",count:1,components:{"minecraft:item_model":"sweetdream:rain_puddle"}},transformation:{translation:[0f,0.02f,0f],scale:[1f,1f,1f]},brightness:{sky:15,block:15},view_range:8.0f,shadow_radius:0f,shadow_strength:0f,data:{zx:{dmg:$(dmg),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# 设寿命：刚生成的那只在脚下 1 格内（自己刚 summon 的，不会抓错）
execute at @s run scoreboard players set @e[tag=zx.rt_new,distance=..1,limit=1] zx.rt_life 100
execute at @s run tag @e[tag=zx.rt_new,distance=..1] remove zx.rt_new
