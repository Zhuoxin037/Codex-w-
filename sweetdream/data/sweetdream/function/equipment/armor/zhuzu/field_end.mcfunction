# ============================================================
# sweetdream:equipment/armor/zhuzu/field_end —— 领域自然到期
# ------------------------------------------------------------
# 【执行者】marker
# 【做什么】把归属玩家的 zx.zz_on 清掉，然后 kill 自己
# 【为什么不靠玩家侧 close】领域到期时玩家可能正站着不动（这正是它的用法），
#   close 只在移动时跑。所以到期必须自己摘标记。
# 【★ 找不到玩家也没关系】on_hurt 里"冷却一过就无条件清 zx.zz_on"是兜底，
#   玩家下线/切维度都不会把状态卡死。
# ============================================================
scoreboard players set #zz_me zx.meta 0
scoreboard players operation #zz_me zx.meta = @s zx.zz_own
execute in minecraft:overworld as @a[distance=0..] if score @s zx.zz_me = #zz_me zx.meta run scoreboard players set @s zx.zz_on 0
execute in minecraft:the_nether as @a[distance=0..] if score @s zx.zz_me = #zz_me zx.meta run scoreboard players set @s zx.zz_on 0
execute in minecraft:the_end as @a[distance=0..] if score @s zx.zz_me = #zz_me zx.meta run scoreboard players set @s zx.zz_on 0
execute at @s run particle minecraft:smoke ~ ~0.1 ~ 2.0 0.1 2.0 0.01 24 normal
execute at @s run playsound minecraft:block.stone.break player @a ~ ~ ~ 0.6 0.8
kill @s
