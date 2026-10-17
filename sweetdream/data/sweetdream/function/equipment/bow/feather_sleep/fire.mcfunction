# ============================================================
# sweetdream:equipment/bow/feather_sleep/fire —— 「眠羽」结算(宏 {target, shooter, uuid})
# ------------------------------------------------------------
# 【执行者】射手(玩家), 位置/朝向 = 射手自己(@s 就是射手, 因为 apply 用 as/at 送进来)
# 【文案】消耗被命中者的「白昼梦」, 分裂出 2 枚羽箭, 分别追踪命中位置 6 格内最近的
#   其他生物, 对其造成 自身最大魔力值 ×0.08 的伤害 + 3 秒缓慢Ⅱ。
#   若只有一个生物, 则 2 枚合为 1 枚, 伤害改为 ×0.18。
# 【★ 2026-10-15 用户拍板: "只有一个生物"两种都算, 不重复打 ★】
#   · 6 格内**没有其他生物** -> 合 1 枚, 打**被命中者本人**, 0.18
#   · 6 格内**只有 1 个其他生物** -> 合 1 枚, 打**那一个**, 0.18(不拆成两发 0.08)
#   · 6 格内 **>=2 个其他生物** -> 2 枚, 分别打最近的两个, 各 0.08
# 【★ 顺序 ★】① 先消「白昼梦」(走 lib/mark_consume, 让永恒/余烬被动正常生效)
#   -> ② 再圈人/算伤害/结算。圈人在消标签**之后**没问题: 「白昼梦」不影响 6 格内
#   谁是谁, 而"被命中者本人"的存在性只由 zx.fs_v 标签保证。
# 【为什么要 at 被命中者】文案写的是"**命中位置** 6 格内最近的其他生物", 不是射手
#   周围 —— 弩是远程武器, 站远处射时射手离命中点很远, 按射手量会一个都圈不到。
# ============================================================

# ⓪ 受害者还在吗(死掉/被转走 -> 这一发作废, 后面的 at 全依赖它)
execute unless entity @e[tag=zx.fs_v,distance=0..,limit=1] run return 0

# ① 消耗「白昼梦」(统一入口; by = 射手 —— 永恒/余烬都会正常生效)
data modify storage zx:work a set value {target:"@e[tag=zx.fs_v,limit=1]",mark:"dream",by:"@a[tag=zx.fs_pl,limit=1]"}
function sweetdream:lib/mark_consume

# ② 圈"命中位置 6 格内最近的其他生物"(排除被命中者本人)
#    【为什么要先 tag 再挑】后面要"逐个取最近、取走一个就从候选里删掉",
#      直接对 @e[...,sort=nearest,limit=2] 一次性选中再结算也行, 但那样
#      "拿掉一个再取下一个"的语义表达不出来(两枚羽箭必须打**不同**的两只)。
tag @e[tag=zx.fs_t,distance=0..] remove zx.fs_t
execute at @e[tag=zx.fs_v,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..6,tag=!zx.fs_v] add zx.fs_t
scoreboard players set #fs_c zx.meta 0
execute as @e[tag=zx.fs_t,distance=0..] run scoreboard players add #fs_c zx.meta 1

# ③ 挑羽箭的目标(见头注的口径)
tag @e[tag=zx.fs_p1,distance=0..] remove zx.fs_p1
tag @e[tag=zx.fs_p2,distance=0..] remove zx.fs_p2
execute if score #fs_c zx.meta matches 1.. at @e[tag=zx.fs_v,limit=1] run tag @e[tag=zx.fs_t,sort=nearest,limit=1] add zx.fs_p1
tag @e[tag=zx.fs_p1] remove zx.fs_t
execute if score #fs_c zx.meta matches 2.. at @e[tag=zx.fs_v,limit=1] run tag @e[tag=zx.fs_t,sort=nearest,limit=1] add zx.fs_p2
tag @e[tag=zx.fs_p2] remove zx.fs_t

# ④ 这一发每枚羽箭的伤害 = 最大魔力值 ×0.08(两枚) / ×0.18(合一)
#    【走 max_mana_mul 通道】基数由框架取面板 max_mana, 不必自己拼接定点乘法。
execute if score #fs_c zx.meta matches 2.. run data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08}
execute unless score #fs_c zx.meta matches 2.. run data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.18}
data modify storage manacore:in arg.uuid set from storage zx:work fs.uuid
function manacore:api/damage/calc
data modify storage zx:work fs.dmg set value 0.0
data modify storage zx:work fs.dmg set from storage manacore:out r.damage
# 诊断锚 #fs_dbg8 = 每枚羽箭的伤害(×1000); 归零之后才写 —— "从没写过(空白)"和"写过但是 0"
# 在探针里长得不一样, "算出来是 0"是最该被看到的症状。
scoreboard players set #fs_dbg8 zx.meta 0
execute store result score #fs_dbg8 zx.meta run data get storage zx:work fs.dmg 1000
execute store result storage zx:work fs.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work fs.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work fs.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work fs.u3 int 1 run data get entity @s UUID[3]

# ⑤ 逐枚结算(每枚: 羽箭粒子 + 伤害 + 3 秒缓慢Ⅱ)
#    【为什么用 as/at 送进 hit】hit 里所有"自身"都是被羽箭打中的那只。
execute if score #fs_c zx.meta matches 2.. as @e[tag=zx.fs_p1,distance=0..] at @s run function sweetdream:equipment/bow/feather_sleep/hit
execute if score #fs_c zx.meta matches 2.. as @e[tag=zx.fs_p2,distance=0..] at @s run function sweetdream:equipment/bow/feather_sleep/hit
execute if score #fs_c zx.meta matches 1 as @e[tag=zx.fs_p1,distance=0..] at @s run function sweetdream:equipment/bow/feather_sleep/hit
execute if score #fs_c zx.meta matches 0 as @e[tag=zx.fs_v,distance=0..] at @s run function sweetdream:equipment/bow/feather_sleep/hit

# ⑥ 收尾: 清掉本次用过的计数/标的标签(否则会污染下一箭)
tag @e[tag=zx.fs_p1,distance=0..] remove zx.fs_p1
tag @e[tag=zx.fs_p2,distance=0..] remove zx.fs_p2
tag @e[tag=zx.fs_t,distance=0..] remove zx.fs_t
tag @e[tag=zx.fs_v,distance=0..] remove zx.fs_v
