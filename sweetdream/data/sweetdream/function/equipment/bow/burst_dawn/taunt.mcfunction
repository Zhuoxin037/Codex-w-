# ============================================================
# sweetdream:equipment/bow/burst_dawn/taunt —— 「转移索敌至魂灵之影」(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work bdt {u0,u1,u2,u3} = 主人 UUID 的 4 个 32 位整数
#   (由 shade_tick 从影自己的 data.zx.bd.u* 抄过来)
# 【执行者】魂灵之影, 位置 = 它自己; 由 shade_tick 每秒调一次
# 【文案】「若生物索敌为自身，则会转移索敌至「魂灵之影」。」
# 【怎么做】
#   ① 先给主人打一个临时标签 zx.bd_owner(判据要用"目标是不是我主人")
#   ② 12 格内的生物逐个过一遍 taunt_one: 它的索敌 == 主人 ? -> 打 zx.bd_t
#   ③ 让被挑出来的挨一下**影**的打(0.01 点) —— 原版 HurtByTargetGoal 的优先级
#      高于"最近的玩家", 所以它们会立刻把仇恨切到影身上 = 索敌转移完成。
# 【★ 为什么用"挨一下打"而不是直接改写 NBT ★】
#   生物的当前索敌目标存在 Brain 的记忆里(1.21 起), 那个记忆的 NBT 结构不是
#   稳定接口; 而"被谁打了就记恨谁"是原版**公开且稳定**的 AI 行为 —— 用命令
#   让它真的挨一下影的打, 仇恨就自然转过去了, 不需要碰任何内部字段。
# 【★ 为什么用 0.01 点 ★】只为触发 AI, 不是真要伤害; 0.01 在护甲减免后仍然
#   > 0(不会被引擎当成 0 而跳过 setLastHurtBy)。
# 【★ 还有两条天然加成 ★】
#   · 铁傀儡本来就在僵尸 / 骷髅的原版索敌名单里 —— 附近的怪本来就会来找它;
#   · 影每 3 秒的那一下(shade_strike)自带 `by <影>` 归属, 挨打的那只会记恨影。
# ============================================================

tag @a[tag=zx.bd_owner] remove zx.bd_owner
$tag @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] add zx.bd_owner
execute unless entity @a[tag=zx.bd_owner] run return 0

tag @e[tag=zx.bd_t,distance=0..] remove zx.bd_t
execute as @e[type=!#sweetdream:no_damage,tag=!zx.bd_shade,distance=..12] run function sweetdream:equipment/bow/burst_dawn/taunt_one

execute as @e[tag=zx.bd_t,distance=0..] at @s run damage @s 0.01 minecraft:generic by @e[tag=zx.bd_shade,distance=..12,limit=1,sort=nearest]
tag @e[tag=zx.bd_t,distance=0..] remove zx.bd_t
