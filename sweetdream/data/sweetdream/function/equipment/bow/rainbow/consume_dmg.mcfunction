# ============================================================
# sweetdream:equipment/bow/rainbow/consume_dmg —— 吞噬伤害: 施加者最大生命值 ×0.1(宏 {target,u0..u3})
# ------------------------------------------------------------
# 【谁调它】consume ②(执行者 = 被打中的那只生物)
# 【怎么算】用 u0..u3 反查施加者 -> 读他的 max_health 面板值 -> ×0.1 -> 打伤害。
#   查不到施加者(离线)就退化成 0 伤害(不报错, 只是没伤害)。
# 【为什么不用目标的 max_health】文案是"使其受到相当于**自身**最大生命值的伤害",
#   武器描述语境里"自身" = 装备者 = 施加者。
# 【量纲】api/stats/get 出参 r.value 是面板原量纲(点), ×0.1 后照常是点。
# ============================================================

# ① 反查施加者的 uuid: 用 u0..u3 拼 nbt 选择器
#    (选择器文本没法存进 storage, 只能宏拼; 这里直接在宏函数里做)
data modify storage zx:work rbd set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work rbd.u0 set from storage zx:work a.u0
data modify storage zx:work rbd.u1 set from storage zx:work a.u1
data modify storage zx:work rbd.u2 set from storage zx:work a.u2
data modify storage zx:work rbd.u3 set from storage zx:work a.u3
function sweetdream:equipment/bow/rainbow/find_owner with storage zx:work rbd

# ② find_owner 会把施加者的 max_health 算进 #rb_mhp(×100 定点)
scoreboard players set #rb_dmg zx.meta 0
scoreboard players operation #rb_dmg zx.meta = #rb_mhp zx.meta
scoreboard players set #10 zx.meta 10
scoreboard players operation #rb_dmg zx.meta /= #10 zx.meta
execute if score #rb_dmg zx.meta matches ..0 run return 0

# ③ 打伤害
execute store result storage zx:work a.damage double 0.01 run scoreboard players get #rb_dmg zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
