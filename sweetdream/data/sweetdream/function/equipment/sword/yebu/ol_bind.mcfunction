# ============================================================
# sweetdream:equipment/sword/yebu/ol_bind —— 超限·曳步: 基础移速 -50%, 5 秒(每生物仅一次)
# ------------------------------------------------------------
# 【谁调用它】yebu/ol_stack 末尾(缓慢Ⅲ 叠到 >10 秒的那一下), 执行者 = 被命中的生物
# 【为什么用属性而不是药水】文案写的是"基础移动速度 -50%" —— 原版缓慢 Ⅳ 是 -60%、
#   Ⅲ 是 -45%, 拿不到正好 50%; add_multiplied_base -0.5 = 基础移速 ×0.5, 才是原文。
#   同一个生物身上已经有缓慢 Ⅲ(原版效果), 两者叠加时属性那条照常再乘一次, 这是有意的。
# 【★ 时长怎么收 ★】属性修饰符是**实体数据**, 不加清理就是永久 -50%。
#   记 zx.yb_be = now + 100(5 秒), 由 ol_bind_sweep 每秒判到点 -> ol_bind_end 摘掉。
#   不用 schedule: 同一只生物被叠两次时会变成"两批各自解绑、互相打断"(和 lib/freeze
#   头注释里那条同一个理由), 写结束时刻就好比较。
# 【每生物仅一次】zx.ybm = 1 之后永不复位 —— 这是文案里的"每个生物仅一次", 不是
#   "每次叠满一次"; 所以不能在下一次 Ⅰ 时清它。
# ============================================================
scoreboard players set @s zx.ybm 1
scoreboard players operation @s zx.yb_be = #now manacore.meta
scoreboard players add @s zx.yb_be 100

# 同 id 已存在时 add 会失败(无副作用, 值不变) —— 5 秒内不会被叠第二次(有 ybm 门), 不必先摘
# ★ 例外: 正在被 lib/freeze 冻住的生物**不挂**这条(2026-10-23 批 K1) ★
#   lib/freeze 挂的是 `sweetdream:freeze -1.0 add_multiplied_base`, 两条一叠就是
#   1 - 1 - 0.5 = **-0.5** 的负移速 —— 属性可以变负, 冻结期间反而会往反方向抖。
#   冻住的生物本来就走不动, 这 50% 对它没有意义, 所以直接跳过; zx.ybm 照样置 1
#   (文案的"每生物仅一次"是按"吃过没吃过"算, 不是按"属性挂没挂上"算)。
#   副手拿曳步 + 主手拿永霜这种组合真的能出现, 所以这条不是假想。
execute unless entity @s[tag=zx.freeze] run attribute @s minecraft:movement_speed modifier add sweetdream:yb_bind -0.5 add_multiplied_base
tag @s add zx.yb_bind

execute at @s run particle minecraft:dust{color:[0.35,0.42,0.55],scale:1.4} ~ ~0.5 ~ 0.6 0.6 0.6 0.01 18 normal
execute at @s run particle minecraft:cloud ~ ~0.2 ~ 0.4 0.1 0.4 0.01 10 normal
execute at @s run playsound minecraft:block.powder_snow.step player @a ~ ~ ~ 0.6 0.7
