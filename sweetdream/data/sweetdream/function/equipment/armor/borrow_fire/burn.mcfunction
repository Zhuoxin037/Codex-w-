# ============================================================
# sweetdream:equipment/armor/borrow_fire/burn —— 结算"剩余燃烧时间 ×5"的真伤并熄灭
# ------------------------------------------------------------
# 【执行者】被平A打中的那只(还在烧)   【宏参数】$(u0)..$(u3) = 施法者
# 【★ "剩余燃烧时间"按什么单位 ★】NBT 的 `Fire` 存的是**刻**; 文案说的是"时间",
#   玩家读的是秒 ⇒ 秒 = Fire ÷ 20, 伤害 = 秒 × 5 ⇒ ×1000 定点 = Fire × 250。
#   ★ 一次乘完(×250)而不是"先 ÷20 再 ×5": 先除会把 19 刻(0.95 秒)抹成 0
#     —— 定点数的老规矩: 除法放到最后, 否则常态丢精度。
# 【★ 熄灭用 {Fire:0s} ★】别写 {Fire:-20s}: 那只是"免疫火焰 1 秒"的另一种写法,
#   值本身仍然是负数, 反而让它继续烧(blaze_armor/hurt 踩过)。
# ============================================================

scoreboard players operation #bf_d zx.meta = #bf_f zx.meta
scoreboard players set #bf_cap zx.meta 2147483647
scoreboard players operation #bf_cap zx.meta /= #250 zx.meta
execute if score #bf_d zx.meta > #bf_cap zx.meta run scoreboard players operation #bf_d zx.meta = #bf_cap zx.meta
scoreboard players operation #bf_d zx.meta *= #250 zx.meta

$data modify storage zx:work a set value {target:"@s",damage:0.0,type:"sweetdream:true_damage",u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
execute store result storage zx:work a.damage double 0.001 run scoreboard players get #bf_d zx.meta
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

data merge entity @s {Fire:0s}
execute at @s run particle minecraft:flame ~ ~0.8 ~ 0.3 0.4 0.3 0.02 10 normal
