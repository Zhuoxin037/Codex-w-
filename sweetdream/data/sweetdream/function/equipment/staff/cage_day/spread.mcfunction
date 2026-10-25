# ============================================================
# sweetdream:equipment/staff/cage_day/spread —— 二次命中：白昼梦扩散给另外三个
# ------------------------------------------------------------
# 范围 = 目标 5 格内、排除本体（tag=!zx.cg_tgt）、最近的 3 个。
# 时长同样是 8 秒（mark 满值 15 → 立刻改写）。
# ============================================================
function sweetdream:tag/mark {target:"@e[type=!#sweetdream:no_damage,distance=0.1..5,sort=nearest,limit=3,tag=!zx.cg_tgt]",mark:"dream"}
scoreboard players set @e[type=!#sweetdream:no_damage,distance=0.1..5,sort=nearest,limit=3,tag=!zx.cg_tgt] zx.tt.dream 8

execute at @e[type=!#sweetdream:no_damage,distance=0.1..5,sort=nearest,limit=3,tag=!zx.cg_tgt] run particle minecraft:dust{color:[0.95,0.9,0.55],scale:1.2} ~ ~1 ~ 0.4 0.4 0.4 0.02 12 normal
execute at @e[type=!#sweetdream:no_damage,distance=0.1..5,sort=nearest,limit=3,tag=!zx.cg_tgt] run particle minecraft:end_rod ~ ~1 ~ 0.3 0.3 0.3 0.02 6 normal
