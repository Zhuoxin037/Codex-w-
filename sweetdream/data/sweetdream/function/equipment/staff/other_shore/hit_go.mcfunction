# ============================================================
# sweetdream:equipment/staff/other_shore/hit_go —— 彼岸普攻的"附加效果"主体
# ------------------------------------------------------------
# 【执行者】发射者(玩家)   【位置】第一只通过节流的目标处(as 不改位置)
# 【入参】zx.os_pass = 本次命中且**过了 8 秒节流**的那批
# 【技能原文】"每次普攻命中后若其未附有「渊海」和「噬心」，则使其附加「渊海」。
#   若其只附有其中一种，则有 25% 的概率使其附加另一种。若其同时附有「渊海」和
#   「噬心」，则额外造成一次相当于自身最大魔力值 ×0.03 的真实伤害。"
# 【★ 先分类再动手 ★】见 classify 头部: 否则刚附上的「渊海」会被"只有渊海"那条
#   再抽一次 25% ⇒ 一发普攻给两个状态。
# ============================================================

# ① 拍快照(在改任何一个状态之前)
execute as @e[tag=zx.os_pass,distance=0..] run function sweetdream:equipment/staff/other_shore/classify

# ② 双状态 -> 额外一段 最大魔力值 ×0.03 真实伤害
execute if entity @e[tag=zx.os_pass,tag=zx.os_both,distance=0..] run function sweetdream:equipment/staff/other_shore/passive_true

# ③ 两个都没有 -> 附「渊海」(一次性, 不抽概率)
function sweetdream:tag/mark {target:"@e[tag=zx.os_pass,tag=zx.os_none,distance=0..]",mark:"yuanhai"}

# ④ 只有「渊海」-> 25% 附「噬心」
execute as @e[tag=zx.os_pass,tag=zx.os_y,distance=0..] run function sweetdream:equipment/staff/other_shore/roll_shixin

# ⑤ 只有「噬心」-> 25% 附「渊海」
execute as @e[tag=zx.os_pass,tag=zx.os_s,distance=0..] run function sweetdream:equipment/staff/other_shore/roll_yuanhai

# ⑥ 收尾: 本轮临时标签(分类标签由下一次 classify 自己清, 只清 pass 就够)
tag @e[tag=zx.os_pass,distance=0..] remove zx.os_pass
