# ============================================================
# sweetdream:lib/u_by —— 用「计分项 UUID」反查玩家, 打 zx.ub 标签（零 NBT）
# ------------------------------------------------------------
# 【入参】storage zx:work ub{u0,u1,u2,u3}（4 个 32 位 int, 与实体 UUID 同源）
# 【产物】玩家标签 zx.ub（至多一个; 找不到就一个都不打）
# 【执行者】任意（不改 @s 身份, 只动标签与 #ub_* 计分项）
# ------------------------------------------------------------
# 【★ 为什么要有这个函数（2026-10-23 第五次卡顿修复）★】
#   包里反查玩家一律写 `@a[nbt={UUID:[I;$(u0),...]}]`。2026-10-20 那次 spark 采样
#   （见 internal/damage/who 的头注释）已经量出来:
#     · 服务端 74.87% 的忙时落在 Entity.saveWithoutId;
#     · **一次玩家 NBT 序列化 ≈ 10 ms**（本包装备 lore / custom_data 极大, 序列化要
#       走完整个背包的 DataComponents codec）。
#   那次只把 internal/damage/deal 一条链换成了计分项比较, **其余调用点没动** ——
#   于是"一次技能命中"仍然要付:
#     · internal/damage/one 的受击侧钩子（候潮 / 潮线 / 焦衣 / 燧行 / 缝心 / 绯缝 /
#       殓丝 / 圣骸 / 缚烬）≈ 20 次
#     · + 升痕 stg_mul 4 次、calc_as_owner 3 次
#   半径 6 的天穹打 10 只、每只 3 层升痕 ⇒ 30 次命中 × 20+ 次反查 × 10 ms
#   = **一次落地几秒钟的顿帧**（表现: 人先卡住, 停几秒伤害才哗一下全出来）。
#   换成计分项比较后: 每个玩家 4 次整数比较, **零 NBT**。
# ------------------------------------------------------------
# 【★ 为什么计分项就够 ★】manacore:internal/uuid/collect_self 已把每个玩家的 UUID
#   缓存进 manacore.u0..u3（每人一生读一次）。这里直接比这 4 个数。
# 【★ 玩家标签为什么不心疼 ★】玩家 tag 存在 playerdata, 不参与 chunk 存盘 ——
#   与"每刻给生物 add/remove tag ⇒ chunk 每刻变脏"那条完全是两回事（RULES 卡顿条目）。
# 【★ 与 internal/damage/who 的关系 ★】who 用 zx:work who + 标签 zx.d_by, 只服务
#   deal 那一条链（它有自己的嵌套重入约定）。本函数是**通用版**: 节点 zx:work ub、
#   标签 zx.ub, 两者互不干扰, 嵌套调用谁也不会踩到对方。
# 【★ 调用方怎么写 ★】宏函数里在这行**之前**先灌一次入参, 再用 @a[tag=zx.ub]:
#     $data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
#     function sweetdream:lib/u_by
#     execute as @a[tag=zx.ub,limit=1] run ...
#   ★ 每条用到它的命令**前面都要重新灌一次**: 中间任何嵌套调用都可能改写 ub。
# ============================================================

# ① 先摘干净: 上一次的结果绝不能残留（只摘带着的那个, 不做全量遍历）
tag @a[tag=zx.ub] remove zx.ub

# ② 入参不全 = 查不到（环境伤害 / 离线来源走这条）
execute unless data storage zx:work ub.u0 run return 0

# ③ 4 个 int 搬进计分项（读的是 storage, 零实体 NBT）
execute store result score #ub_0 zx.meta run data get storage zx:work ub.u0
execute store result score #ub_1 zx.meta run data get storage zx:work ub.u1
execute store result score #ub_2 zx.meta run data get storage zx:work ub.u2
execute store result score #ub_3 zx.meta run data get storage zx:work ub.u3

# ④ 逐人比 4 个数（没缓存过 UUID 的玩家自然不命中, 不需要特判）
execute as @a if score @s manacore.u0 = #ub_0 zx.meta if score @s manacore.u1 = #ub_1 zx.meta if score @s manacore.u2 = #ub_2 zx.meta if score @s manacore.u3 = #ub_3 zx.meta run tag @s add zx.ub
