# ============================================================
# sweetdream:lib/freeze —— 把一批生物"冻住"指定 tick 数(冷冻)
# ------------------------------------------------------------
# 【宏参数】zx:work fz {target, ticks}
# 【用的是什么】原版的**冻结计数器 TicksFrozen** —— 粉雪里那套机制, 不是自创的:
#   · 它 >= 140 就是"完全冻结": 生物会发抖/结霜(原版外观),
#     而且原版的连带逻辑照常生效 —— 比如骷髅冻够 300 tick 会变成流浪者
#   · 它每 tick 会自己 -2, 所以只写一次撑不满你要的时长:
#     core/tick 里每 tick 帮被冻住的生物续一次(见 lib/freeze_hold)
# 【为什么不再用 NoAI】NoAI 是"完全不动 + 不出招 + 连动作都定格", 那是**时停**
#   (见 lib/timestop)。两套效果现在分开, 同一个生物可以只被冻(还能转身/攻击),
#   也可以被时停(完全定格), 标签分别是 zx.freeze / zx.stop。
# 【但 TicksFrozen 本身不限制移动速度】所以这里顺手把移动速度的属性乘区调到 -100%
#   —— 真的走不动, 但还能转身、还能攻击。这就是"冷冻"和"时停"的手感区别。
#   ⚠️ 用属性 id sweetdream:freeze 加减, 同一只生物重复冻只加一次(见下面的 unless),
#      解冻时由 lib/unfreeze_one 摘掉 —— 不摘的话它会永远走不动。
# 【怎么记时长】用框架自己的时钟 #now(每 tick +1) 加上 ticks, 存到生物自己的
#   zx.fz_end 上; 解冻由 lib/freeze_hold 每刻判(到点当场解)、unfreeze_sweep 每秒兜底。
#   为什么不用 schedule: 同一只生物被冻两次时, schedule 会变成"两批各自解冻、
#   互相打断"; 写结束时间戳则好比较。
# 【★★ 重入语义 = "只延长、不缩短"(2026-10-09 修) ★★】
#   同一只生物被冻两次是常事: 别的武器先冻 10 秒, 永霜再冻 3 秒。
#   旧写法是 `zx.fz_end = #now` 再 `+= ticks` —— 那是**重置**, 后一次更短就把
#   前一次**截短**(10 秒 -> 3 秒), 玩家看到的是"我明明冻了 10 秒怎么 3 秒就解了"。
#   现在改成和 **lib/timestop 同一语义**: 已经在冻里的话, 只有"结束时刻更晚"才往后推。
#   (时停那边一直是对的, 它的注释里写的"和冷冻那边的直觉一致"就是指这条 ——
#    冷冻这边当年漏了, 现在补齐。)
# ============================================================

# ① 本次的结束时刻 = now + ticks(先算到临时量, 第 ③ 步好比较)
scoreboard players operation #fz_end zx.meta = #now manacore.meta
#   ⚠️ 宏函数里**只有行首带 $ 的行**才会替换 $(ticks)。这行不加 $ 的话,
#      Minecraft 会原样看到 "players add #fz_end zx.meta $(ticks)" 并报错。
$scoreboard players add #fz_end zx.meta $(ticks)

# ② 控制时长倍率(受控时间加成, 单一真源 lib/ctrl_mul/pct, 2026-10-06 改; 说明见 lib/timestop)。
#   以前这里写死 `ticks × #20 ÷ #100`, 与 lib/timestop 各写一份 -> 现在统一读 pct。
#   ★ 必须并进 #fz_end(而不是像旧版那样事后去改 @s zx.fz_end): 下面 ③ 比的是
#     "本次结束时刻", 加成加在事后会被"取较长"这一步比较掉。
#   ★ 判据必须交给 ctrl_mul/pct: 本函数的 @s 是调用者(玩家), 目标在 $(target) 里。
#   ★ 负加成(未来的"控制时长 -X%")也走得通: 只看 #fz_x 是否为 0。
$data modify storage zx:work cm.target set value "$(target)"
function sweetdream:lib/ctrl_mul/pct with storage zx:work cm
$scoreboard players set #fz_x zx.meta $(ticks)
scoreboard players operation #fz_x zx.meta *= #cm_add zx.meta
scoreboard players operation #fz_x zx.meta /= #100 zx.meta
execute if score #cm_add zx.meta matches 1.. if score #fz_x zx.meta matches ..0 run scoreboard players set #fz_x zx.meta 1
execute unless score #fz_x zx.meta matches 0 run scoreboard players operation #fz_end zx.meta += #fz_x zx.meta

# ③ 写入结束时刻(**取较长**):
#    ③-a 还没在冻里的 -> 直接写
#    ③-b 已经在冻里、但计时被外力清掉了(分数不存在) -> 也直接写, 否则它永远解不开
#        ★ "分数不存在"的判据 = "自己不等于自己"(和 unfreeze_dim 的时停兜底同一招)
#    ③-c 已经在冻里且计时还在 -> 只有结束时刻更晚才往后推
$execute as $(target) unless entity @s[tag=zx.freeze] run scoreboard players operation @s zx.fz_end = #fz_end zx.meta
$execute as $(target) if entity @s[tag=zx.freeze] unless score @s zx.fz_end = @s zx.fz_end run scoreboard players operation @s zx.fz_end = #fz_end zx.meta
$execute as $(target) if entity @s[tag=zx.freeze] if score #fz_end zx.meta > @s zx.fz_end run scoreboard players operation @s zx.fz_end = #fz_end zx.meta

# ④ 定格外观 + 打标签(每次都要做: TicksFrozen 会自己衰减, 标签万一被外力摘了能补回来)
$execute as $(target) run data modify entity @s TicksFrozen set value 140
$execute as $(target) unless entity @s[tag=zx.freeze] run attribute @s minecraft:movement_speed modifier add sweetdream:freeze -1.0 add_multiplied_base
$execute as $(target) run tag @s add zx.freeze
