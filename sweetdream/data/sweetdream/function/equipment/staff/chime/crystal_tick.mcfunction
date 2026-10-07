# ============================================================
# sweetdream:equipment/staff/chime/crystal_tick —— 共鸣水晶: 每 2 秒一发
# ------------------------------------------------------------
# 【谁调用它】chime/second(#now 为偶数秒时; 执行者 = 水晶 marker)
# 【文案】每 2 秒都会对其 6 格内的**一个**生物造成一次相当于自身最大魔力值 ×0.03 的伤害。
# 【"一个"怎么挑】sort=random,limit=1 —— 必须先**冻结成标签**(zx.ch_t)再结算:
#   选择器里带 sort=random 每用一次就重挑一批, 直接写进 target 会让"挑中的"和
#   后面打到的不是同一只。冻成标签后只求值一次, 结算时怎么用都是那一只。
# ============================================================

# ① 清上一轮残留 -> 挑 6 格内随机 1 只 -> 冻结
tag @e[tag=zx.ch_t] remove zx.ch_t
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=..6,sort=random,limit=1] add zx.ch_t

# ② 表现(水晶迸出一道光)
execute at @s run particle minecraft:end_rod ~ ~0.6 ~ 0.3 0.5 0.3 0.04 10 normal

# ③ 挑到了才结算(反查释放者, 见 crystal_set / crystal_go)
execute if entity @e[tag=zx.ch_t,limit=1] run function sweetdream:equipment/staff/chime/crystal_set with entity @s data.zx.ch
