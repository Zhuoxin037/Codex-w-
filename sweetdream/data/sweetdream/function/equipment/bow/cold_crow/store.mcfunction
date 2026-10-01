# ============================================================
# sweetdream:equipment/bow/cold_crow/store —— 把"这一发"挂在射手名下(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work cc {uuid,tier,dmg,u0,u1,u2,u3}
# 【执行者】射手(玩家)
# 【存哪】zx:data cc."<uuid>" —— 一个玩家一份, 多人同时射也互不影响。
#   · tier 这一发是第几层
#   · dmg  这一发算好的伤害
#   · u0..u3 射手 UUID 的四个整数(打伤害时用来拼 by <射手>, 击杀才算玩家的)
# 【为什么要先存】箭打中生物是"之后某一刻"才知道的(靠弩上的附魔「霜矢」回调,
#   见 hook_victim), 而数值在射击那一刻就算好了 —— 先存下来, 到时候照着用。
# ============================================================

$data modify storage zx:data cc."$(uuid)" set value {tier:0,dmg:0.0,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:data cc."$(uuid)".tier set value $(tier)
$data modify storage zx:data cc."$(uuid)".dmg set value $(dmg)
$data modify storage zx:data cc."$(uuid)".u0 set value $(u0)
$data modify storage zx:data cc."$(uuid)".u1 set value $(u1)
$data modify storage zx:data cc."$(uuid)".u2 set value $(u2)
$data modify storage zx:data cc."$(uuid)".u3 set value $(u3)
