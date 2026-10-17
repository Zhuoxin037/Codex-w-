# ============================================================
# sweetdream:equipment/axe/death_bell/bell_once —— 敲一次钟
# ------------------------------------------------------------
# 【谁调用它】dom_one ⑦⑧(连调两次)   【执行者】施法者   【位置】他所在处
# 【做什么】对已钉好的名单 zx.dbl_bell 全体:
#   ① 打一次 最大魔力值 ×0.08(值已由 dom_one ⑥ 算好, 两次钟声同价)
#   ② 每命中一只就给 #dbl_n +1 —— 这是"影响生物数"的唯一口径
#      (用户 2026-10-17 拍板: 两次钟声的命中次数合计; 同一只被打两次算 2)
#   ③ 3 秒虚弱Ⅱ(= amplifier 1, Ⅰ 才是 0)
#   ④ 表现
# 【为什么名单不再挑一次】"释放两次钟声"= 对着同一批人敲两下, 不是每敲一次重新挑一批。
# ============================================================

# ① 伤害
data modify storage zx:in arg set value {target:"@e[tag=zx.dbl_bell,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage zx:work dbl.dmg2
execute at @s run function sweetdream:api/damage

# ② 命中计数(每个目标各 +1; 名单空则一次也不执行)
execute as @e[tag=zx.dbl_bell,distance=0..] run scoreboard players add #dbl_n zx.meta 1

# ③ 3 秒虚弱Ⅱ
execute as @e[tag=zx.dbl_bell,distance=0..] run effect give @s minecraft:weakness 3 1 true

# ④ 表现: 钟声的余音
execute at @e[tag=zx.dbl_bell,distance=0..,limit=1] run playsound minecraft:block.bell.resonate player @a ~ ~ ~ 0.9 0.7
particle minecraft:soul ~ ~1 ~ 1.2 0.6 1.2 0.01 10 normal
