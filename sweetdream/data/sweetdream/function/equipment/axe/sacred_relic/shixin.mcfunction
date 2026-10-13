# ============================================================
# sweetdream:equipment/axe/sacred_relic/shixin —— 「噬心」: 追加死者最大生命 5% 真伤
# ------------------------------------------------------------
# 【谁调用它】sacred_relic/strike ⑤(遗骸 NBT 上带 data.zx.sx 时)
# 【执行者】遗骸(marker)  【位置】遗骸处
# 【伤害】死者**死亡瞬间的最大生命** ×5% —— 走真实伤害(sweetdream:true_damage, 无视护甲)。
# 【★ 为什么用 storage 缩放而不是计分板乘法 ★】直接
#   `execute store result storage … double 0.05 run data get entity @s data.zx.hp`
#   一步就把 hp × 0.05 写成 double, 不必再引常量假玩家(少一个坑)。
# 【★ u0..u3 自己填一遍, 不蹭 strike 的残留 ★】上一发 with_from 可能动过 zx:work a;
#   这里从头把"归属 = 释放者"重填, 保证击杀仍算释放者。
# ============================================================

execute unless data entity @s data.zx.hp run return 0

execute store result storage zx:work a.num double 0.00005 run data get entity @s data.zx.hp 1000
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[tag=zx.sr_t,distance=0..]"
data modify storage zx:work a.type set value "sweetdream:true_damage"
data modify storage zx:work a.u0 set value 0
data modify storage zx:work a.u1 set value 0
data modify storage zx:work a.u2 set value 0
data modify storage zx:work a.u3 set value 0
execute as @a[tag=zx.sr_caster,limit=1] run data modify storage zx:work a.u0 set from entity @s UUID[0]
execute as @a[tag=zx.sr_caster,limit=1] run data modify storage zx:work a.u1 set from entity @s UUID[1]
execute as @a[tag=zx.sr_caster,limit=1] run data modify storage zx:work a.u2 set from entity @s UUID[2]
execute as @a[tag=zx.sr_caster,limit=1] run data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# 表现: 一圈暗紫的噬心辉光(与本包「噬心」标签同色)
execute at @e[tag=zx.sr_t,distance=0..,limit=1] run particle minecraft:dust{color:[0.35,0.10,0.45],scale:1.2} ~ ~0.6 ~ 0.5 0.5 0.5 0 16 normal
