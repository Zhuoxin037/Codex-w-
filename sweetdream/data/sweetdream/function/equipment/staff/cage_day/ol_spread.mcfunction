# ============================================================
# sweetdream:equipment/staff/cage_day/ol_spread —— 囚昼超限：白昼梦扩散（5 格内全部）
# ------------------------------------------------------------
# 【原文（超限版）】
#   "若选中的生物已附有「白昼梦」，则该次伤害提高 50%（独立乘区），并将其「白昼梦」
#    扩散给 5 格内的生物。扩散到的生物若已经有「白昼梦」则改为时停 3 秒且「白昼梦」
#    的持续时间延长至 25 秒。"
# 【执行上下文】由 skill 用 `at @e[tag=zx.cg_tgt]` 调进来 ⇒
#   @s 仍是**施法者**（at 只换位置）—— lib/timestop 的控制时长倍率要读施法者，必须是它。
# 【★ 顺序不能反 ★】
#   ① 先给"原本就带白昼梦"的挂牌（zx.ol_cgh）+ "原本没有"的挂牌（zx.cg_new），
#   ② 再按牌办事。反过来会串：先把 dream 补给没有的，之后"已有 dream"就分不出新旧了。
# 【★ 临时标签必须收尸 ★】两张牌都在本函数末尾摘掉，且清理半径与查询半径同值。
# ============================================================

tag @e[tag=zx.ol_cgh,distance=0..] remove zx.ol_cgh
tag @e[tag=zx.cg_new,distance=0..] remove zx.cg_new

# ① 挂牌（此刻还没补新的 dream，分得清）
tag @e[type=!#sweetdream:no_damage,distance=0..5,tag=zx.status.dream] add zx.ol_cgh
tag @e[type=!#sweetdream:no_damage,distance=0..5,tag=!zx.status.dream] add zx.cg_new

# ② 原本没有的：补白昼梦 20 秒（mark 满值 15 → 立刻改写 20）
function sweetdream:tag/mark {target:"@e[type=!#sweetdream:no_damage,tag=zx.cg_new,distance=0..5]",mark:"dream"}
scoreboard players set @e[tag=zx.cg_new,distance=0..] zx.tt.dream 20

# ③ 原本就有的：时停 3 秒 + 时长延到 25 秒
#   ★ 60 刻 = 3 秒；lib/timestop 里"多次时停取较长的那次"，叠不坏。
data modify storage zx:work fz.target set value "@e[tag=zx.ol_cgh,distance=0..]"
data modify storage zx:work fz.ticks set value 60
function sweetdream:lib/timestop with storage zx:work fz
scoreboard players set @e[tag=zx.ol_cgh,distance=0..] zx.tt.dream 25

# ④ 表现 + 收尸
execute at @e[tag=zx.cg_new,distance=0..] run particle minecraft:dust{color:[0.95,0.9,0.55],scale:1.2} ~ ~1 ~ 0.4 0.4 0.4 0.02 12 normal
execute at @e[tag=zx.ol_cgh,distance=0..] run particle minecraft:end_rod ~ ~1 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @e[tag=zx.ol_cgh,distance=0..] run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.5 0.6

tag @e[tag=zx.ol_cgh,distance=0..] remove zx.ol_cgh
tag @e[tag=zx.cg_new,distance=0..] remove zx.cg_new
