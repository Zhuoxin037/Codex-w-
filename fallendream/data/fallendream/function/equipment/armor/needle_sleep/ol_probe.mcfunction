# ============================================================
# fallendream:equipment/armor/needle_sleep/ol_probe —— 超限·针眠：反查本次伤害的施法者
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one ①.5g(目标带「噬心」且这一下不是敌方伤害)
# 【执行者】**被打的那一只**（@s = 目标）
# 【入参】storage zx:work nsu {u0..u3} —— 由 one 从 zx:work ob 抄出来的攻击者 UUID
#   ★★ 本文件**不许**直接读 zx:work ob ★★
#     check 规则: ob 是"每批伤害的不可变基准", 只给 with_from / one / stg_mul 三个
#     文件碰; 别的函数一读, 基准就可能被范围伤害的中途改写污染, 表现为"只对某类目标
#     生效"加成随机串到下一条命上。所以抄一份到 nsu, 这里只读 nsu。
# 【为什么要反查】"对附有噬心的生物造成伤害后冷却 -1 秒"是**施法者**身上的事,
#   而伤害结算跑在目标上下文里, 只能靠 UUID 找回去。
# 【★ 用 lib/u_by, 不用 @a[nbt=…] ★】后者要序列化每个玩家的整份 NBT(≈10ms/次);
#   u_by 只比 4 个计分项, 零 NBT(见 lib/u_by 文件头的 spark 采样)。
# ============================================================

data modify storage zx:work ub set from storage zx:work nsu
function fallendream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function fallendream:equipment/armor/needle_sleep/ol_cut
