# ============================================================
# sweetdream:internal/damage/who —— 用「计分项 UUID」反查归属玩家, 打 zx.d_by
# ------------------------------------------------------------
# 【入参】storage zx:work who{u0,u1,u2,u3}（4 个 32 位 int, 与实体 UUID 同源）
# 【产物】玩家标签 zx.d_by（至多一个）
# 【执行者】任意（不改 @s 身份, 只动标签与 #dby_* 计分项）
# ------------------------------------------------------------
# 【★ 为什么要有这个函数（2026-10-20 第四次卡顿修复, spark 实测）★】
#   包内原来反查玩家一律写 `@a[nbt={UUID:[I;u0,u1,u2,u3]}]`。
#   spark 30 秒采样（spark.lucko.me/resVm2N3e8）的结论:
#     · 服务端 74.87% 的"忙时"落在 Entity.saveWithoutId(class_1297.method_5647);
#     · 其中 60.8% 是 `data` 命令触发的全量实体 NBT 序列化,
#       14.1% 是选择器里的 `nbt={...}` 谓词触发的同一件事;
#     · 换算下来 **一次玩家 NBT 序列化 ≈ 10 ms**（591 tick / 忙 23.08 s）。
#   为什么这么贵: 本包装备的 lore 与 custom_data 极大, 序列化要**走完整个背包**
#   的 DataComponents codec（栈上可见 PlayerInventory → ItemStack.CODEC.encode）。
#   internal/damage/deal 一次命中要反查 7 遍 ⇒ **单次命中 ~70 ms 的顿帧**。
#   换成计分项比较后: 每个玩家 4 次整数比较, 零 NBT。
# ------------------------------------------------------------
# 【★ 为什么计分项就够 ★】
#   manacore:internal/uuid/collect_self 已经把每个玩家的 UUID 缓存进
#   manacore.u0..u3（每人一生读一次, 见 manacore 的 O02 条目）。
#   这里直接比这 4 个数, 不需要再碰实体 NBT。
# 【★ 玩家标签为什么不心疼 ★】
#   玩家 tag 存在 playerdata, 不参与 chunk 存盘 —— 与"每刻给生物 add/remove
#   tag ⇒ chunk 每刻变脏"那条完全是两回事（见 RULES 的卡顿条目）。
#   而且这里一次伤害只摘一次、打一次。
# 【★ 找不到人 = 无归属伤害 ★】入参不全 / 玩家 UUID 还没缓存 / 攻击者已离线
#   —— 三种情况都不打标签, 调用方按"无归属"处理（照常打得出来, 只是不算击杀）。
# ============================================================

# ① 先摘干净: 上一次的归属绝不能残留（只摘带着的那个, 不做全量遍历）
tag @a[tag=zx.d_by] remove zx.d_by

# ② 入参不全 = 无归属（环境伤害 / 离线来源走这条）
execute unless data storage zx:work who.u0 run return 0

# ③ 4 个 int 搬进计分项（读的是 storage, 零实体 NBT）
execute store result score #dby_0 zx.meta run data get storage zx:work who.u0
execute store result score #dby_1 zx.meta run data get storage zx:work who.u1
execute store result score #dby_2 zx.meta run data get storage zx:work who.u2
execute store result score #dby_3 zx.meta run data get storage zx:work who.u3

# ④ 逐人比 4 个数（没缓存过 UUID 的玩家自然不命中, 不需要特判）
execute as @a if score @s manacore.u0 = #dby_0 zx.meta if score @s manacore.u1 = #dby_1 zx.meta if score @s manacore.u2 = #dby_2 zx.meta if score @s manacore.u3 = #dby_3 zx.meta run tag @s add zx.d_by
