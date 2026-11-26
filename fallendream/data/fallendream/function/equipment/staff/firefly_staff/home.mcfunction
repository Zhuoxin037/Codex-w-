# ============================================================
# fallendream:equipment/staff/firefly_staff/home —— 超限：没打到东西的萤火回身边绕着飞
# ------------------------------------------------------------
# 【执行者】飞满 16 格没命中的那只萤火
# 【文案】"释放完后飞行 16 格没有命中的萤火会返回至自身周围并持续围绕在自身 2 格，
#   持续 8 秒。碰触到生物后消失并对其造成相当于自身当前魔力值 x0.04 的伤害，
#   之后使其附加「流火」。"
# ⇒ 转 zx.ff_home 状态(见 home_tick), 8 秒 = 160 刻。
#   环绕期间碰到的生物按"返回萤火"口径结算(explode 里读 #ff_home: ×0.04 + 流火),
#   与常规萤火的 ×0.045 区分开 —— 原文这两处写的数值不同, 分别照做。
# ============================================================

tag @s remove zx.ff_fly
tag @s remove zx.ff_homing
tag @s remove zx.ff_track
data remove entity @s data.target
tag @s add zx.ff_home
scoreboard players set @s zx.ff_home_age 160
