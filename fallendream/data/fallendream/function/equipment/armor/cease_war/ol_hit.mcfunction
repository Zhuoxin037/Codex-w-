# ============================================================
# fallendream:equipment/armor/cease_war/ol_hit —— 止战(超限·转化态)：扣目标护甲/韧性
# ------------------------------------------------------------
# 【宏参数】context {vx_uuid}（lib/victim 给出的"刚被打的那一只"）
# 【执行者】动手的那个玩家
# 【文案(逐字)】"…普通近战命中生物后使其护甲值及护甲韧性 -20% 且自身基础攻击力 +5%，
#   可以叠加三次，持续至余勇效果结束。"
# 【★ 持续到余勇结束 ★】两边都不用倒计时：
#   · 目标这边：`zx.cw_deb_end` 记成**玩家的余勇结束刻**（player_tick 每刻拿它和 #now 比），
#     到点由 lib/second 的三维度扫描把两个 modifier 摘掉。
#   · 自身这边：+5% 的账本在 cease_war/end 退还（end 的调用点已经覆盖"到期 / 换职业 /
#     死亡 / 摘胸甲"四路）。
# 【★ modifier 重挂 ★】同一个 id 重复 add 会失败并截断函数 ⇒ 先按"目标身上有没有标记"
#   决定要不要 remove，再 add。
# ============================================================

$execute unless entity $(vx_uuid) run return 0

# ① 目标身上旧的 -20% 先摘（重入时同一 id 不能直接 add）
$execute as $(vx_uuid) if entity @s[tag=zx.cw_deb] run attribute @s minecraft:armor modifier remove fallendream:cw_deb
$execute as $(vx_uuid) if entity @s[tag=zx.cw_deb] run attribute @s minecraft:armor_toughness modifier remove fallendream:cw_deb_t

# ② 挂新的 -20%（add_multiplied_total = 把当前总值 ×0.8）
$execute as $(vx_uuid) run attribute @s minecraft:armor modifier add fallendream:cw_deb -0.2 add_multiplied_total
$execute as $(vx_uuid) run attribute @s minecraft:armor_toughness modifier add fallendream:cw_deb_t -0.2 add_multiplied_total
$tag $(vx_uuid) add zx.cw_deb

# ③ 记"跟着这一次余勇一起结束"
$scoreboard players operation $(vx_uuid) zx.cw_deb_end = @s zx.s2_cw_end

# ④ 自身基础攻击力 +5%（最多 3 层）
function fallendream:equipment/armor/cease_war/stack

# ⑤ 表现
$execute at $(vx_uuid) run particle minecraft:enchanted_hit ~ ~1 ~ 0.3 0.4 0.3 0.05 8 normal
$execute at $(vx_uuid) run playsound minecraft:item.shield.break player @a ~ ~ ~ 0.5 1.3
$tag $(vx_uuid) remove zx.victim
