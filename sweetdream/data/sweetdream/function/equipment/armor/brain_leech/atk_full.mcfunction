# ============================================================
# sweetdream:equipment/armor/brain_leech/atk_full —— 「蛊虫」累积分支
# ------------------------------------------------------------
# 【前置】attack 已判定: 戴着超限脑髓蛭 + 魔力满 + 不在消耗模式。
#        #mx = 魔力上限   【执行者】玩家(zx:data self.uuid 已备好)
# 【做什么】
#   ① 「蛊虫」+1(封顶 10)
#   ② 定时攻击力 = max(现值, floor(上限 × 0.02)), 持续 5 秒(= 100 刻)
#   ③ 满了 10 层 -> zx.bl_gm = 1 转入消耗模式
# 【为什么取 max 而不是直接覆盖】同一时刻可能刚吃到更强的 10 秒奖励,
#   这一下"5 秒弱奖励"不该把它的数值压低(只延长/维持)。
# ============================================================

scoreboard players add @s zx.bl_gu 1
execute if score @s zx.bl_gu matches 11.. run scoreboard players set @s zx.bl_gu 10

# 定时加成 = floor(上限 × 0.02)  —— ×2 ÷100
scoreboard players operation #new zx.meta = #mx zx.meta
scoreboard players operation #new zx.meta *= #2 zx.meta
scoreboard players operation #new zx.meta /= #100 zx.meta
execute if score #new zx.meta > @s zx.bl_ta run scoreboard players operation @s zx.bl_ta = #new zx.meta
# 到期时刻 = #now + 100(5 秒)
scoreboard players operation @s zx.bl_te = #now manacore.meta
scoreboard players add @s zx.bl_te 100

# 满 10 层 -> 下次起走消耗分支
execute if score @s zx.bl_gu matches 10 run scoreboard players set @s zx.bl_gm 1
