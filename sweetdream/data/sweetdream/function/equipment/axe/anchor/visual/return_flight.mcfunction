# ============================================================
# sweetdream:.../anchor/visual/return_flight —— 飞锚回手: 每刻朝玩家飞(宏 {u0..u3})
# ------------------------------------------------------------
# 【★ 2026-10-23 卡顿修复 ★】
#   原来这里每刻 4 次 `@a[nbt={UUID:[I;$(u0),...]}]` + 3 次
#   `data ... set from entity <玩家> Pos[n]` —— 玩家 NBT 序列化 ≈10 ms 一次
#   (本包装备 lore/custom_data 极大, 序列化要走完整个背包; 见 lib/u_by 头注释),
#   回手段 11 刻 ⇒ 一发沉锚仅这一段就 ~0.5 秒。
#   现在: ① 反查走 lib/u_by(计分项比较, 零 NBT) -> @a[tag=zx.ub];
#          ② 朝向交给 `facing entity ... feet`, 不再读 Pos。
# ============================================================

$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,distance=0..,limit=1] run return run kill @s

# ① 已经贴上玩家(0.8 格内) -> 停在手边那个固定姿态, 收工
execute if entity @a[tag=zx.ub,distance=..0.8,limit=1] at @a[tag=zx.ub,distance=0..,limit=1] rotated ~ 0 positioned ^0.35 ^0.35 ^0.55 run return run tp @s ~ ~ ~ ~ 0

# ② 朝玩家飞(每刻 1.0 格) —— facing entity, 零 NBT
execute at @s facing entity @a[tag=zx.ub,distance=0..,limit=1] feet positioned ^ ^ ^1.0 run tp @s ~ ~ ~ ~ 0
