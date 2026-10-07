# ============================================================
# sweetdream:equipment/staff/delusion/skill_b —— 惑梦分支 B(锁定者没在时停里)
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑧ 步(执行者 = 施法玩家)
# 【内容】使锁定者 3 格内的全部生物时停 2 秒(无伤害)。
# ============================================================

# ① 圈目标: 以锁定者为中心 3 格(它自己距离 0, 也在圈内 —— "其 3 格内")
tag @e[tag=zx.dl_area] remove zx.dl_area
execute at @e[tag=zx.dl_lock,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.dl_area

# ② 时停 2 秒(40 tick)
data modify storage zx:work fz set value {target:"@e[tag=zx.dl_area]",ticks:40}
function sweetdream:lib/timestop with storage zx:work fz
