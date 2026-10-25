# ============================================================
# sweetdream:equipment/axe/frost_carve/ol_ice —— 冻住"攻击者及其 3 格内"
# ------------------------------------------------------------
# 【谁调用它】ol_hurt(已经 `execute at <攻击者>` 过来)   【执行者】受害者玩家
# 【位置】攻击者所在处 —— 这一步必须由调用方用 `at` 定好, 因为 lib/freeze 的
#   $(target) 是"相对执行位置"求值的字符串, 换个位置就冻错一片。
# 【★ 为什么先给自己打 zx.frc_self 再排除 ★】
#   近战被砍时攻击者离自己往往不到 3 格, `@e[...distance=..3]` 会把**自己**也圈进来
#   -> 冻自己 2 秒(移速 -100%)。文案写的是"攻击自己的生物及其 3 格内的全部生物",
#   自己不是"攻击自己的生物", 所以必须排掉。
#   选择器不能写两个否定 type, 用临时标签最稳(玩家 tag 不参与区块存盘, 摘掉即可)。
# ============================================================

# ① 排掉自己
tag @s add zx.frc_self

# ② 攻击者 3 格内全部生物(含攻击者本人), 冰冻 2 秒 = 40 刻
data modify storage zx:work fz set value {target:"",ticks:40}
data modify storage zx:work fz.target set value "@e[type=!#sweetdream:no_damage,distance=..3,tag=!zx.frc_self]"
function sweetdream:lib/freeze with storage zx:work fz

# ③ 收尾
tag @s remove zx.frc_self

# ④ 表现
particle minecraft:snowflake ~ ~1 ~ 1.6 0.6 1.6 0.08 30 normal
playsound minecraft:block.glass.break player @a ~ ~ ~ 0.7 1.5
