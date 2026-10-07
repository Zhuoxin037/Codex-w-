# ============================================================
# sweetdream:equipment/staff/final_revelation/tick —— 光柱的一秒
# ------------------------------------------------------------
# 【谁调用它】second 里 `execute as @a[scores={zx.fr_t=1..}] at @s`
#   (执行者 = 施法玩家, 位置 = 玩家)
# 【一秒干四件事】扫范围 -> 伤害(最大魔力 ×0.1) -> 缓慢Ⅲ 3 秒 -> 倒计时
# 【★ 粒子/表现不在这里 ★】2026-10-06 用户要求"一直持续的光束", 每秒铺一次
#   粒子看不出来(粒子寿命 < 1 秒) ⇒ 表现层挪到 equipment/staff/final_revelation/beam,
#   由 core/tick **每刻**驱动。本文件只管"每秒一次的结算"。
# 【伤害口径】最大魔力 ×0.1 → max_mana_mul 通道(基数由框架按 uuid 取)。
#   每秒对**范围内全部**生物各打一次(不是只打一只), 与文案"范围内的生物每秒
#   受到一次"一致 —— 所以这里用范围选择器一次结算, 不必逐个循环。
# 【★ 归属】@s 是玩家本人, 所以 api/damage 会带上 uuid = 击杀记玩家头上。
# 【倒计时放最后】先干活再扣: 扣到 0 的这一刻**也照常吃了一次伤害**,
#   然后由 end 收尾(主动释放才有 ×0.2), 正好是"持续 6 秒" = 6 次伤害。
# ============================================================

# ① 拿 uuid(执行者 = 施法玩家)
function sweetdream:lib/uuid

# ② 扫出范围内生物(打上 zx.fr_in)
function sweetdream:equipment/staff/final_revelation/scan

# ③ 伤害: 最大魔力 ×0.1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.fr_in,distance=0..]",damage:0.0,read:"manacore"}
function sweetdream:api/damage

# ④ 缓慢Ⅲ 3 秒(每秒续)
execute as @e[tag=zx.fr_in,distance=0..] run effect give @s minecraft:slowness 3 2 true

# ⑤ 光柱表现: 见 equipment/staff/final_revelation/beam(挂 core/tick 每刻铺)。
#    ★ 曾经在这里每秒铺一次(5 个采样点 × end_rod) —— 20 fps 里只有 1 帧有粒子,
#      用户原话"啥都没有"。别搬回来。
#    ★ 2026-10-07 用户又报"光柱不跟着我" —— 根因同样是几何: 光束与摄像机共线
#      ⇒ 第一人称看不见, 只看得见残影。修法 = beam 里整体 ^-0.35 偏到视线下方,
#      详见 beam 文件头坑 69。**扫描/伤害(scan)不要跟着偏**, 判定必须留准星轴上。

# ⑥ 倒计时(放到最后: 先干活再扣)
scoreboard players remove @s zx.fr_t 1
execute if score @s zx.fr_t matches ..0 run function sweetdream:equipment/staff/final_revelation/end
