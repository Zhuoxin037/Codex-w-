# ============================================================
# sweetdream:equipment/tool/bitter_cold/thaw_victim —— 给刚解冻的那只生物上 debuff
# ------------------------------------------------------------
# 【执行者】刚解除冻结的那只生物
# 【三件事】5 秒缓慢Ⅲ + 5 秒虚弱Ⅲ + 附加「渊海」
# 【顺序】先两条原版效果, 再走公共接口附「渊海」——
#   「渊海」自己会立刻给 2 秒缓慢Ⅱ (见 tag/mark_one), 所以缓慢会被刷成Ⅱ?
#   ★ 不会: 两条 effect 都给 5 秒, 之后「渊海」给的是 2 秒Ⅱ —— 原版规则是
#     "更长的时长覆盖、强度取更高那一档", 5 秒Ⅲ 不会被 2 秒Ⅱ 顶掉。
# 【amplifier】缓慢Ⅲ = 2 / 虚弱Ⅲ = 2 (0-based)。
# ============================================================

effect give @s minecraft:slowness 5 2 true
effect give @s minecraft:weakness 5 2 true
function sweetdream:tag/mark {target:"@s",mark:"yuanhai"}
