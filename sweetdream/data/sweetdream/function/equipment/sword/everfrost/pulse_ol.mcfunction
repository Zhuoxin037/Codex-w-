# ============================================================
# sweetdream:equipment/sword/everfrost/pulse_ol —— 超限·永霜的持续段(**每 tick** 调用)
# ------------------------------------------------------------
# 【原文(逐字)】
#   "冰冻自身 5 格范围内的全部生物 3 秒，之后每秒对被冰冻的生物造成一次相当于
#    其最大生命值 ×0.03 的真实伤害（最多 10 秒），并在结束后对被冰冻的生物造成
#    相当于自身当前魔力值 ×0.15 的伤害。"
# 【★ 口径(用户 2026-10-08 明确, 按这个实现 ★】
#   ① 释放: 冻 3 秒 —— **同时**立刻开始持续伤害计时(**不是**冻完 3 秒才开始)。
#   ② 冻结期间: **每秒**对"**此刻仍然被冻着的**"目标打一次 其最大生命 ×0.03 真伤。
#   ③ 追加冻结: 别的武器把它接着冻(lib/freeze 会往后推 zx.fz_end), 伤害就跟着延长
#      —— 所以结束时刻**不能**在施法时定死, 必须每刻看目标的真实冰冻状态。
#   ④ 结束: 目标**解冻的那一刻**(或到 10 秒硬上限)对它结算一次 当前魔力 ×0.15。
#      ★ **逐目标结算**: A 先解冻就先吃最后一下, B 还冻着就继续吃每秒那下。
#      这就是为什么不能"打满 10 次一次性收尾" —— 那样不同目标无法在不同时刻结束。
# 【时间线示例(0 秒施法, 第 2 秒另一把武器追加 4 秒冰冻)】
#   0s 冻住并开始追踪 -> 1s 第 1 次 ×0.03 -> 2s 第 2 次(同时被续冻)
#   -> 3~6s 仍冻着, 每秒继续 -> 6s 解冻 -> 对它结算 ×0.15, 结束追踪
# 【★★ 挂在每 tick 上的三个"必须自己记"的东西 ★★】
#   pn  = 下一拍的绝对时刻(**节拍**) —— 不然 10 次伤害会在 10 刻里全打完
#   p   = 已经打了几拍(上限 10)
#   cap = 施法后 200 tick(10 秒)的硬上限
# 【"还冻着"怎么判(所有武器共用, 见 lib/freeze)】
#   带 zx.freeze **且** zx.fz_end > #now —— 别的武器续冻会往后推 zx.fz_end,
#   这里自然就看得到, 不用额外通路。
# 【执行者】玩家   【入参】storage zx:work ef.uuid
# ============================================================

# ① 记录还在吗(理论上在, hit_due 已判过)
$execute unless data storage zx:data ef."$(uuid)" run return 0

# ② 到硬上限了吗? 打满 10 拍 / 超过 10 秒 -> 剩下的**全部**收尾(整批 finish_ol)
$execute store result score #ef_p zx.meta run data get storage zx:data ef."$(uuid)".p
$execute store result score #ef_cap zx.meta run data get storage zx:data ef."$(uuid)".cap
scoreboard players set #ef_fin zx.meta 0
execute if score #ef_p zx.meta matches 10.. run scoreboard players set #ef_fin zx.meta 1
execute if score #now manacore.meta > #ef_cap zx.meta run scoreboard players set #ef_fin zx.meta 1
execute if score #ef_fin zx.meta matches 1 run function sweetdream:equipment/sword/everfrost/finish_ol with storage zx:work ef
execute if score #ef_fin zx.meta matches 1 run return 0

# ③ 【每刻都查】有没有目标已经解冻了? 解冻的**就地**结算最后一下
#    ★ 用 zx.ef_fin 临时标签做中转: 伤害仍以**施法者**(@s = 玩家)的身份打出去,
#      这样击杀归属还是玩家的(api/damage 只认 @s 是不是玩家, 见 api/damage ⑤)。
#    ★ tag=!zx.ef_fin 是为了"本拍已经判过的不重复判"(下面 ⑥ 才统一摘)。
$execute as @e[tag=zx.ef_$(uuid),tag=!zx.ef_fin,distance=0..] unless entity @s[tag=zx.freeze] run tag @s add zx.ef_fin
$execute as @e[tag=zx.ef_$(uuid),tag=zx.freeze,tag=!zx.ef_fin,distance=0..] unless score @s zx.fz_end > #now manacore.meta run tag @s add zx.ef_fin
execute if entity @e[tag=zx.ef_fin,distance=0..] run function sweetdream:equipment/sword/everfrost/finish_one with storage zx:work ef

# ④ 这一批已经没人了(全死了 / 全收完尾 / 跑没影) -> 删记录、摘"等结算"标签、收工
$execute unless entity @e[tag=zx.ef_$(uuid),distance=0..] run data remove storage zx:data ef."$(uuid)"
$execute unless data storage zx:data ef."$(uuid)" run tag @s remove zx.ef_casting
$execute unless data storage zx:data ef."$(uuid)" run return 0

# ⑤ 到没到下一拍?(★ 自记节拍: 本函数是每 tick 进来的, 不能靠调用频率当"每秒" ★)
$execute store result score #ef_pn zx.meta run data get storage zx:data ef."$(uuid)".pn
execute if score #now manacore.meta < #ef_pn zx.meta run return 0

# ⑥ 这一拍: **只对此刻仍然被冻着的**目标各打一次"其最大生命 ×0.03"真实伤害
$execute as @e[type=!#sweetdream:no_damage,tag=zx.ef_$(uuid),tag=zx.freeze,distance=0..] at @s if score @s zx.fz_end > #now manacore.meta run function sweetdream:equipment/sword/everfrost/pct_hit

# ⑦ 计数 +1 写回记录
scoreboard players add #ef_p zx.meta 1
$execute store result storage zx:data ef."$(uuid)".p int 1 run scoreboard players get #ef_p zx.meta

# ⑧ 【下一拍 = 现在 + 20 tick(1 秒)】★ 没有这一句就变成每刻一拍 ★
#    (用"现在 +20"而不是"上一拍 +20": 卡顿漏了几刻时也能保证两拍之间隔满 1 秒,
#     不会一口气把欠的几拍补回来。)
scoreboard players operation #ef_pn zx.meta = #now manacore.meta
scoreboard players add #ef_pn zx.meta 20
$execute store result storage zx:data ef."$(uuid)".pn int 1 run scoreboard players get #ef_pn zx.meta

# ⑨ 表现(整批一小片霜)
$execute at @e[tag=zx.ef_$(uuid),distance=0..] run playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.4 1.8
