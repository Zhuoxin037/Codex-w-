# ============================================================
# sweetdream:lib/skill_mul/apply —— 把算好的倍率写进口径表指的那几条通道
# ------------------------------------------------------------
# 【宏参数】zx:work sm {id, v}   【执行者】玩家本人
#   id = 主手装备 id(custom_data.zx[0]);  v = 倍率(double, 1.25 = ×1.25)
# 【出参】只改 zx:work pl.smul_mm / smul_atk / smul_oth
# 【★ 每行都必须带 $ ★】这个文件里出现了 $(id), 只要有一行漏了 $,
#   那行的 $(id) 会当字面量处理(静默失效); 反过来"有 $ 没变量"会让
#   整个函数作废。所以下面每一行都统一带 $。
# 【不在表里】直接返回 —— 面板上它就三条都是 ×1.0(和"没有倍率类加成"同义)。
# ============================================================

$execute unless data storage zx:config wchan."$(id)" run return 0
$execute if data storage zx:config wchan."$(id)"{mm:1b} run data modify storage zx:work pl.smul_mm set from storage zx:work sm.v
$execute if data storage zx:config wchan."$(id)"{atk:1b} run data modify storage zx:work pl.smul_atk set from storage zx:work sm.v
$execute if data storage zx:config wchan."$(id)"{oth:1b} run data modify storage zx:work pl.smul_oth set from storage zx:work sm.v
