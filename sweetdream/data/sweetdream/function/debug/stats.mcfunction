# ============================================================
# sweetdream:debug/stats —— 打印"自己的当前数值与各种倍率"
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/stats
# 【打印什么】
#   魔力 / 面板属性 / 冷却缩减 / 回魔(基础+修正)×倍率 /
#   术阵 数量·上限 / 各装备加成的账本 / 风声与下次技能加成 /
#   当前所有冷却
# 【为什么要拆两层】有些数据是按 UUID 拼路径的(风声加成、储存的加成比例),
#   只能用宏; 所以这一层先拿 UUID, 再把 zx:data self 当宏参数传下去。
# 【它是只读的】不会改任何数据, 随便按。
# ============================================================

tellraw @s [{"text":"========== 自己的数值 ==========","color":"gold"}]

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tellraw @s [{"text":"还没注册完成(uuid 是空的) —— 等一秒再试","color":"red"}]
execute unless data storage zx:data self{ok:1b} run return fail

function sweetdream:debug/stats_macro with storage zx:data self
