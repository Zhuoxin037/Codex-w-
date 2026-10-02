# ============================================================
# sweetdream:equipment/bow/cold_crow/snap_prep —— 决定"这一发"用哪份快照
# ------------------------------------------------------------
# 【宏参数】zx:work cc {uuid, arrow}
#   uuid  : 射手 uuid(拼数据键用)
#   arrow : 这一箭的选择器字符串; 找不到就是匹配不到的选择器, 会自动跳过
# 【执行者】不要求特定实体(全程只用 storage 和显式选择器)
# 【产出】zx:work cc.snap {ok,tier,dmg,u0..u3} —— fire 只认这一份
# 【★ 两步, 后一步覆盖前一步 ★】
#   ① 先把"射手最近一发"(zx:data cc."<uuid>")铺进去 —— 这是老路径, 也是兜底。
#      (射手名下没有这份数据时, 这几行 `set from` 会失败, 值保持初始的 0;
#       不会报错, 也不会把 snap 弄坏。)
#   ② 如果这一箭自己带着快照, 就用**它**整个覆盖掉 —— 逐箭数据永远优先。
# 【为什么非要这样写】把"兜底"和"优先项"都收敛到同一个地方, fire 就只需要
#   从一个固定路径读数, 不用写两套分支。
# ============================================================

data modify storage zx:work cc.snap set value {ok:0b,tier:0,dmg:0.0,u0:0,u1:0,u2:0,u3:0}
$data modify storage zx:work cc.snap.tier set from storage zx:data cc."$(uuid)".tier
$data modify storage zx:work cc.snap.dmg set from storage zx:data cc."$(uuid)".dmg
$data modify storage zx:work cc.snap.u0 set from storage zx:data cc."$(uuid)".u0
$data modify storage zx:work cc.snap.u1 set from storage zx:data cc."$(uuid)".u1
$data modify storage zx:work cc.snap.u2 set from storage zx:data cc."$(uuid)".u2
$data modify storage zx:work cc.snap.u3 set from storage zx:data cc."$(uuid)".u3

$execute if entity $(arrow) if data entity $(arrow) data.zx.cc{ok:1b} run data modify storage zx:work cc.snap set from entity $(arrow) data.zx.cc
