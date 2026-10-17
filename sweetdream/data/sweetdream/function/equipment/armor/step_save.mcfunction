# ============================================================
# sweetdream:equipment/armor/step_save —— 把"刚放的那个技能"存进按玩家的槽位
# ------------------------------------------------------------
# 【宏参数】zx:step ctx {u0,u1,u2,u3} = 施放者 UUID 的四个整数
# 【写入】zx:step casts."<u0>_<u1>_<u2>_<u3>" = zx:step node {skill,uuid,x,y,z}
# 【为什么用四整数拼键】UUID 文本里有 "-"，做 NBT 键要转义；四整数拼串是
#   sweep/casts 已经验证过的写法（equipment/sword/sickle_dreams/sweep/save）。
# 【为什么不用玩家计分项】记录里有技能 id 字符串，计分项只能存数字。
# ============================================================

$data modify storage zx:step casts."$(u0)_$(u1)_$(u2)_$(u3)" set from storage zx:step node
