# ============================================================
# sweetdream:equipment/bow/dragon_tongue/ol_burst —— 【超限】箭数 > 20 的收尾一段
# ------------------------------------------------------------
# 【谁调用它】dragon_tongue/fire ⑥.5(执行者 = 射手; 只在超限 + 箭数 > 20 时)
# 【文案】「若本次箭数量超过 20 个则在结束后额外对范围内的生物造成一次相当于
#   自身当前魔力值 x X x0.01 的伤害，并使其附加「流火」。」
# 【入参】zx:work dt {dmg, u0..u3} + 标签 zx.dt_v(被射中那只 = 圆心)
# 【★ "范围内的生物"是多大 ★】原文的"范围"指的就是上面那次箭雨的落点范围 ——
#   普通 2 格 / 超限 4 格(超限这一支永远是 4 格, 因为本段只在超限时跑)。
# 【★ 伤害直接复用 dt.dmg ★】fire ② 已经算过"当前魔力 × X × 0.01", 与文案是
#   同一个式子; 再算一遍不但浪费, 还会因为 X 已经数过而变化(原则上不该变, 但没必要赌)。
# 【★ 一次选中全部 ★】范围内每只吃同一份伤害、附同一个「流火」 ⇒ 用
#   `@e[tag=zx.dt_bt]` 让 with_from / tag/mark 自己逐个展开, 不写循环。
# 【★ 不排除被射中那只 ★】文案只说"范围内的生物"; 它自己也在 4 格内。
#   若它已被箭雨打死, 选择器自然取不到 —— 不需要额外的判活。
# ============================================================

# ⓪ 圆心(被射中那只)还在吗
execute unless entity @e[tag=zx.dt_v,distance=0..,limit=1] run return 0

# ① 圈范围内全部生物(4 格)
tag @e[tag=zx.dt_bt,distance=0..] remove zx.dt_bt
execute at @e[tag=zx.dt_v,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..4] add zx.dt_bt
execute unless entity @e[tag=zx.dt_bt,distance=0..,limit=1] run return 0

# ② 表现: 收尾的一圈火星向外扫
execute at @e[tag=zx.dt_v,limit=1] run particle minecraft:flame ~ ~1 ~ 3.0 0.4 3.0 0.02 60 normal
execute at @e[tag=zx.dt_v,limit=1] run playsound minecraft:entity.blaze.shoot player @a ~ ~ ~ 0.8 0.8

# ③ 伤害 = 当前魔力 × X × 0.01(与每根箭同一份)
data modify storage zx:work a set value {target:"@e[tag=zx.dt_bt]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work dt.dmg
data modify storage zx:work a.u0 set from storage zx:work dt.u0
data modify storage zx:work a.u1 set from storage zx:work dt.u1
data modify storage zx:work a.u2 set from storage zx:work dt.u2
data modify storage zx:work a.u3 set from storage zx:work dt.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ④ 附加「流火」(附着 -> 通用接口, 会跳过已带有/已死亡的)
data modify storage zx:work ic set value {target:"@e[tag=zx.dt_bt]",mark:"liuhuo"}
function sweetdream:tag/mark with storage zx:work ic

# ⑤ 收尾
tag @e[tag=zx.dt_bt,distance=0..] remove zx.dt_bt
