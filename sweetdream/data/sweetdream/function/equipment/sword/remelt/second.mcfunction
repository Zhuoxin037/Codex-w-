# ============================================================
# sweetdream:equipment/sword/remelt/second —— 热熔的每秒入口
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/second
# 【备份公共输入口】状态心跳里会写 manacore:in arg, 见 lib/in_bak。
# 【★ 每行都要 distance=0.. ★】裸 @e 会**跨维度**搜索 —— 三行都写裸 @e 的话每秒会扣 3 点,
#   融甲只撑 1/3 时间(文档写 10 秒, 实际 3.3 秒)。2026-10-06 修。
# ============================================================

function sweetdream:lib/in_bak

# ① 熔解状态倒计时(只筛状态还开着的人)
execute as @a[scores={zx.rm_on=1..}] run function sweetdream:equipment/sword/remelt/state_tick

# ② 融甲倒计时 + 到点还原
execute in minecraft:overworld as @e[distance=0..,tag=zx.rm_melt] run scoreboard players remove @s zx.rm_t 1
execute in minecraft:the_nether as @e[distance=0..,tag=zx.rm_melt] run scoreboard players remove @s zx.rm_t 1
execute in minecraft:the_end as @e[distance=0..,tag=zx.rm_melt] run scoreboard players remove @s zx.rm_t 1
execute in minecraft:overworld as @e[distance=0..,tag=zx.rm_melt,scores={zx.rm_t=..0}] run function sweetdream:equipment/sword/remelt/melt_end
execute in minecraft:the_nether as @e[distance=0..,tag=zx.rm_melt,scores={zx.rm_t=..0}] run function sweetdream:equipment/sword/remelt/melt_end
execute in minecraft:the_end as @e[distance=0..,tag=zx.rm_melt,scores={zx.rm_t=..0}] run function sweetdream:equipment/sword/remelt/melt_end

function sweetdream:lib/in_restore
