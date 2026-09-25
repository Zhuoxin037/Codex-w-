# ============================================================
# sweetdream:internal/effect/go —— 给目标施加状态效果
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {target,effect,duration,amplifier,hide}
#   effect    : 效果 ID, 例如 minecraft:instant_damage
#   duration  : 秒数, 想永久就填 infinite
#   amplifier : 等级, 0 = I 级, 1 = II 级 ...
#   hide      : 是否隐藏粒子, 字符串 "true" / "false"
# 【对应命令】effect give <目标> <效果> <秒> <等级> <隐藏粒子>
# 【拿它当伤害手段】effect give <目标> minecraft:instant_damage 1 0
#   瞬时伤害是原版"绕过部分减伤"的经典打法, 和 /damage 各有适用场景。
# ============================================================

$execute if entity $(target) run effect give $(target) $(effect) $(duration) $(amplifier) $(hide)
data modify storage zx:out r.applied set value 1b
