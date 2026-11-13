# ============================================================
# sweetdream:equipment/sword/remelt/convert —— 20% 把「流火」转成「夜火」
# ------------------------------------------------------------
# 【执行者】动手的玩家
# 【★ 这里刻意不写 return ★】中途 return 会把 zx.victim 留下来, 下一次事件就会
#   把上一只当成本次的目标。用"条件都写在 execute 上"的写法, 最后统一清标签。
# 【20% 怎么来】随机源 lib/rnd 取模 5, 命中 0 就是 1/5 = 20%(和幻昼铺白昼梦同一套)。
# 【★ 2026-10-04 修的 bug ★】旧写法每一步都带 `if entity @e[...,tag=zx.status.liuhuo]`,
#   而第一步就把流火摘了 -> 后面"附夜火"那几行条件不再成立 -> **流火直接变没、夜火没上**
#   (玩家反馈)。改成: 先把这一只钉进 zx.rm_c, 之后摘/加都只看这个标签。
# ============================================================

function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/sword/remelt/convert/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
