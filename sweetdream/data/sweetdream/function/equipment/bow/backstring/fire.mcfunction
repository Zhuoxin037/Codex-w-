# ============================================================
# sweetdream:equipment/bow/backstring/fire —— 「退弦」结算(宏 {target, shooter, uuid})
# ------------------------------------------------------------
# 【执行者】射手(玩家), 位置/朝向 = 射手自己(@s 就是射手, apply 用 as/at 送进来)
# 【技能原文(lore 逐字, 按它逐句实现)】✦ 主动技能 / ✦ 弦满 两段
#   (耗蓝那句不在 lore 正文里 —— 写在主动技能段的拼色行「魔力 30」; 扣费在 shot)
#   「箭矢命中后，自身向后位移 2 格并获得 2 秒迅捷Ⅱ。」
#   「每累计 3 次射击，第 3 发额外造成 12 点伤害。」
# 【★ 位移方向 ★】沿**视线反方向**退, 即 `^ ^ ^-2`(术语口径: 击退 = 背离参照;
#   这里是"背离准星", 所以是负的前向)。撞墙(目标格不是可替换方块)就不动 ——
#   文案说"位移 2 格", 撞墙即停是合理结果, 不该硬塞进方块里。
#   ★ 判两格(脚 + 头): 玩家高 2 格, 只判脚下会把头卡进方块。
# 【为什么位移放在命中回调而不是射击时】文案是"箭矢**命中后**自身向后位移" ——
#   射空不该后撤。
# 【保底 12 点为什么不过 calc】文案写的是"12 点伤害"(固定值 flat, 不吃倍率),
#   所以直接用 api/damage 打数值, 不走 manacore 的三通道。
# ============================================================

# ① 后撤 2 格(撞墙即停)
execute at @s positioned ^ ^ ^-2 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~
execute at @s run particle minecraft:small_gust ~ ~1.0 ~ 0.3 0.3 0.3 0.03 8 normal

# ② 2 秒迅捷Ⅱ(amplifier 0-based: Ⅱ = 1; true = 不显示粒子)
effect give @s minecraft:speed 2 1 true

# ③ 弦满: 这一发带保底伤害 -> 打 12 点固定值, 打完清掉标志
#   【为什么用 distance=0..】裸 @e 会跨维度搜到别的维度里残留的同名标签(坑 55);
#     distance=0.. 在这里兼任"锁在射手所在维度"(命中那只必然与射手同维度)。
execute if score @s zx.bs_ready matches 1 run data modify storage zx:in arg set value {target:"@e[tag=zx.bs_v,distance=0..,limit=1]",damage:12.0}
execute if score @s zx.bs_ready matches 1 run function sweetdream:api/damage
execute if score @s zx.bs_ready matches 1 run particle minecraft:crit ~ ~1 ~ 0.4 0.4 0.4 0.05 10 normal
execute if score @s zx.bs_ready matches 1 run scoreboard players set @s zx.bs_ready 0

# ④ 收尾: 清掉本次用过的临时标签(否则会污染下一箭)
tag @e[tag=zx.bs_v,distance=0..] remove zx.bs_v
