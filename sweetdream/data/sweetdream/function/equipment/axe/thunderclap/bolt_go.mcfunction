# ============================================================
# sweetdream:equipment/axe/thunderclap/bolt_go —— 威霆: 术阵内落雷结算(执行者 = 术阵 marker)
# ------------------------------------------------------------
# 【谁调用它】thunderclap/bolt(③)
# 【技能原文】"在该术阵内的生物每受到一次攻击则立即有 X 道闪电对其造成伤害，每道闪电的
#   伤害为自身最大魔力值 ×0.1。生物每受到 10 次雷击则损失自身 10% 最大生命值。"
# 【一次攻击 = X 道闪电】X 道同刻闪电在数值上等价于**一发总量 X×最大魔力×0.1** 的伤害;
#   表现上用一段电光表示(不召唤真闪电实体 —— 真闪电会点火、还会被雷鸣的扫描接管, 副作用大)。
#   但"雷击次数"仍按 **X 次**记(逐被击者累计 zx.tc_bc), 所以"每 10 次"照常触发。
# 【伤害归属】用 marker 上的 uuid 文本算数值、四整数带 by(施法者不在场也算他的)。
# ============================================================

# X(本次几道雷)
scoreboard players set #tc_x zx.meta 0
execute store result score #tc_x zx.meta run data get entity @s data.zx.n

# 伤害总量 = 最大魔力 × (X×0.1) —— 走 max_mana_mul 通道
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from entity @s data.zx.uu
execute store result storage manacore:in arg.max_mana_mul double 0.1 run scoreboard players get #tc_x zx.meta
function manacore:api/damage/calc

data modify storage zx:work a.num set from storage manacore:out r.damage
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[tag=zx.victim,distance=0..]"
data modify storage zx:work a.type set value "minecraft:player_attack"
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# 逐被击者累计雷击数; 每跨过 10 的倍数则损失 10% 最大生命(maxloss)
scoreboard players set #tc_o zx.meta 0
scoreboard players set #tc_n2 zx.meta 0
execute store result score #tc_o zx.meta run scoreboard players get @e[tag=zx.victim,distance=0..,limit=1] zx.tc_bc
scoreboard players operation #tc_n2 zx.meta = #tc_o zx.meta
scoreboard players operation #tc_n2 zx.meta += #tc_x zx.meta
execute store result score @e[tag=zx.victim,distance=0..,limit=1] zx.tc_bc run scoreboard players get #tc_n2 zx.meta
scoreboard players operation #tc_o zx.meta /= #10 zx.meta
scoreboard players operation #tc_n2 zx.meta /= #10 zx.meta
scoreboard players operation #tc_n2 zx.meta -= #tc_o zx.meta
execute if score #tc_n2 zx.meta matches 1.. run function sweetdream:equipment/axe/thunderclap/maxloss

# 表现: 一段电光 + 雷声
execute at @e[tag=zx.victim,distance=0..,limit=1] run particle minecraft:electric_spark ~ ~1 ~ 0.5 0.8 0.5 0.2 40 normal
execute at @e[tag=zx.victim,distance=0..,limit=1] run playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.8 1.3

# ★★ 真闪电: X 道依次落下(2026-10-07 用户定: "真召唤闪电实体") ★★
#   【为什么这样排】玩家要的是"看得见一道一道劈下来" —— 所以:
#     ① 在被击者处放一个"落雷排期" marker, 上面记 还剩几道(zx.tc_bs) + 下一道的角度(zx.tc_ang);
#     ② core/tick 每刻扫这个 marker -> bolt_fx 劈**一道**真闪电, 然后角度 +30°、剩余 -1;
#     ③ 剩余归 0 时 bolt_fx 自己 kill 掉 marker(不用额外的清理)。
#     每道之间隔 1 刻(0.05 秒), X 道 ≈ X/20 秒内劈完 —— 视觉上就是连续落雷。
#   【为什么角度要变】闪电竖直落下, 若每道都在同一点就完全重叠、看着只像一道;
#     每道错开 30°(半径 1 格)就能一眼看出"好几道"。
#   【★ 必须带 zx.th_seen ★】tool/thunder/strike 每刻扫"新出现的 lightning_bolt";
#     不带这个标签的话, 自己召唤的闪电会被它当成"新雷击" -> 触发雷鸣的二次连锁
#     (不带 seen 的连锁会无限劈下去)。带上了它就完全跳过(zx.th_seen 是它的去重戳)。
#   【副作用(已知, 同「雷鸣」)】真闪电会照常造成原版雷击伤害并可点燃地面 —— 
#     「雷鸣」的第二道闪电也是 summon 真闪电, 同一性质; 这里不做额外处理。
execute at @e[tag=zx.victim,distance=0..,limit=1] run summon minecraft:marker ~ ~ ~ {Tags:["zx.tc_strike","zx.tc_new"]}
execute as @e[tag=zx.tc_new,distance=0..,limit=1] run scoreboard players set @s zx.tc_ang 0
execute as @e[tag=zx.tc_new,distance=0..,limit=1] run scoreboard players operation @s zx.tc_bs = #tc_x zx.meta
tag @e[tag=zx.tc_new,distance=0..] remove zx.tc_new
