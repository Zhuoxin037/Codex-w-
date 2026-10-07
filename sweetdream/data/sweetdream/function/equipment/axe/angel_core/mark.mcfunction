# ============================================================
# sweetdream:equipment/axe/angel_core/mark —— 给"这一只"(@s)附加「圣痕」
# ------------------------------------------------------------
# 【执行者】被打标的那只生物(hit_go 用 `execute as @e[tag=zx.ac_t] ...` 逐只送进来)
# 【★ 用原生标签, 不走 tag/mark ★】tag/mark_one 只认 渊海/流火/夜火/噬心/白昼梦
#   五种(那是头顶图标系统的白名单);「圣痕」只在机制里用, 不需要图标, 所以直接
#   `tag @s add zx.status.shenghen` 就行 —— 传别的名字给 tag/mark 会被静默拒绝。
# 【常态特效不在这里画】只在获得那一刻闪一下的话"常态"就没了 ——
#   持续的粒子交给 status/aura 每秒统一画(见那个文件)。
# 【★ 有寿命 ★】圣痕 15 秒后自动消失(见 status/decay_shenghen)。施加时把计时设满 15;
#   以后要改时长, 这里和 status/decay_shenghen 的注释一起改(同一套"施加=满值"约定)。
# ============================================================

tag @s add zx.status.shenghen
scoreboard players set @s zx.sh_t 15
execute at @s run particle minecraft:end_rod ~ ~1.2 ~ 0.3 0.4 0.3 0.02 8 normal
execute at @s run particle minecraft:enchanted_hit ~ ~1.2 ~ 0.3 0.4 0.3 0.02 6 normal
