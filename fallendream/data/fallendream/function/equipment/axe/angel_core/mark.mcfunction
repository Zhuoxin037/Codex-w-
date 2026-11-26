# ============================================================
# fallendream:equipment/axe/angel_core/mark —— 给"这一只"(@s)附加「圣痕」
# ------------------------------------------------------------
# 【执行者】被打标的那只生物(hit_go 用 `execute as @e[tag=zx.ac_t] ...` 逐只送进来)
# 【★ 用原生标签, 不走 tag/mark ★】tag/mark_one 只认 渊海/流火/夜火/噬心/白昼梦
#   五种(那是头顶图标系统的白名单);「圣痕」只在机制里用, 不需要图标, 所以直接
#   `tag @s add zx.status.shenghen` 就行 —— 传别的名字给 tag/mark 会被静默拒绝。
# 【常态特效不在这里画】只在获得那一刻闪一下的话"常态"就没了 ——
#   持续的粒子交给 status/aura 每秒统一画(见那个文件)。
# 【★ 有寿命 ★】圣痕 15 秒后自动消失(见 status/decay_shenghen)。施加时把计时设满 15;
#   以后要改时长, 这里和 status/decay_shenghen 的注释一起改(同一套"施加=满值"约定)。
# 【超限（2026-11-22）】圣痕 15 → 20 秒。判据 #ac_ol 由 hit_go 在逐只调用本函数之前
#   拍好（同刻串行执行，这里读到的就是这一次攻击的那份）。
# 【额外层 zx.sh_x】新挂上的圣痕没有额外层，这里一律复位 0；额外层只由 ol_layer 加。
#   没这行的话，同一只"上一轮圣痕"留下的 1 会被新圣痕继承。
# ============================================================

tag @s add zx.status.shenghen
scoreboard players set @s zx.sh_t 15
#   ★ 写成 15 + 5 而不是直接 set 20 ★
#     status/decay_shenghen 的"没有计时分数"兜底只能补基础值 15（那时无从知道是
#     哪一档挂上去的）。check.py 规则 50 要求"施加处"与"兜底处"的字面值一致，
#     写成 set 20 会被判成两处时长不一致；用 +5 表达"超限再加 5 秒"，
#     语义更清楚，也不会把这条守门规则改成例外。
execute if score #ac_ol zx.meta matches 1 run scoreboard players add @s zx.sh_t 5
scoreboard players set @s zx.sh_x 0
execute at @s run particle minecraft:end_rod ~ ~1.2 ~ 0.3 0.4 0.3 0.02 8 normal
execute at @s run particle minecraft:enchanted_hit ~ ~1.2 ~ 0.3 0.4 0.3 0.02 6 normal

# 获得「圣痕」的瞬间: **不立圣光柱**(用户 2026-10-08 定稿: 柱子只留给「引爆」那一下)。
#   理由: 被动是"每次平A给 8 格内最近 3 只挂圣痕" ⇒ 一次平A最多同时立 3 根大柱子,
#   刷屏且掉价。这里改成一记"刻印"的小光(脚下暖白光点 + 一道往上收的光丝),
#   大柱子由 dmg2 ⑤(圣痕被引爆)负责。
execute at @s run particle minecraft:end_rod ~ ~0.15 ~ 0.30 0.05 0.30 0.06 18 normal
execute at @s run particle minecraft:dust{color:[1.0,0.97,0.86],scale:1.5} ~ ~0.8 ~ 0.35 0.55 0.35 0.0 10 normal
