# ============================================================
# sweetdream:equipment/bow/arc/ol_tick_go —— 超限·电弧: 放电锚每秒一跳(宏叶子)
# ------------------------------------------------------------
# 【执行者/位置】放电锚(marker); 【宏参数】见 ol_spawn(d2 / u0..u3 / a0..a3 / b0..b3)
#   ★ 这些参数名在锚的 data.zx 里必须是**独立键**(ol_spawn 逐键写) —— 宏参数只能
#     取键, 不能取列表下标(`$(a0)` 不会去读列表 a); 写成列表 ⇒ 整段静默作废(坑 129)。
# 【每秒三件事】
#   ① 两端有一个不在了(死了 / 换了维度) => 计时直接归零, 走收尾
#   ② 计时还 >0 => 以 A 的身份跳一次(3 格宽电线 + 沿途与两端 1 格内伤害; **闪电与
#      音效都在 ol_fire 里**, 只有这一跳真的配上了才召唤 —— 原文"则…并召唤闪电")
#   ③ 计时 -1; 归零 => ol_end_go 收尾(移除双方「电刺」+ kill 自己)
# 【★ 为什么"先跳再减"】计时从 3 起, 减到 0 之前正好跳 3 次(= 原文的"持续 3 秒")。
# 【★ 回查端点靠 UUID】`@e[nbt={UUID:[I;a0,a1,a2,a3]}]` —— 只在锚所在维度找,
#   和放电本身同维度(两端都被 at 过, 不会跨维度)。
# ============================================================

$execute unless entity @e[nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]}] run scoreboard players set @s zx.arc_wt 0
$execute unless entity @e[nbt={UUID:[I;$(b0),$(b1),$(b2),$(b3)]}] run scoreboard players set @s zx.arc_wt 0

$execute if score @s zx.arc_wt matches 1.. as @e[nbt={UUID:[I;$(a0),$(a1),$(a2),$(a3)]}] at @s run function sweetdream:equipment/bow/arc/ol_fire with storage zx:work aw

scoreboard players remove @s zx.arc_wt 1
execute if score @s zx.arc_wt matches ..0 run function sweetdream:equipment/bow/arc/ol_end_go with storage zx:work aw
