# ============================================================
# sweetdream:upgrade/api/hit_mark —— 火炬 / 沸腾 的公共入口(先定位被打的那只)
# ------------------------------------------------------------
# 【为什么单独一层】两条都要"作用到被打的那一只身上", 而定位目标(lib/victim)
#   要扫全维度的实体 —— 各调一遍就是扫两遍。合成一个入口只扫一次。
# 【前置】调用方(on_hit)已经把 #up_tc / #up_boil 读出来了。
# 【★ 用完必须清 zx.victim ★】不清的话下一次事件会把上一只当成本次的目标
#   (remelt/convert 顶部那段注释记的就是这个坑)。
# 【★ 这里刻意不写 return ★】中途 return 会跳过最后那句清标签, 于是一路留脏。
#   全部用"条件挂在 execute 上"的写法, 最后统一清。
# ============================================================

function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:upgrade/api/hit_mark/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
