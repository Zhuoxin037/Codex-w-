# ============================================================
# sweetdream:equipment/armor/brain_leech/atk_consume —— 「蛊虫」消耗分支
# ------------------------------------------------------------
# 【前置】attack 已判定: 戴着超限脑髓蛭 + zx.bl_gm >= 1(已满过 10 层)。
#        #mx = 魔力上限   【执行者】玩家(zx:data self.uuid 已备好)
#        ★ 这条**不要求魔力满**(文案括注: "该效果在魔力值未满时也生效")。
# 【做什么】
#   ① 「蛊虫」-1
#   ② 定时攻击力 = max(现值, floor(上限 × 0.05)), 持续 10 秒(= 200 刻)
#   ③ 掉到 0 层 -> 退出消耗模式(之后重新累积)
# 【为什么是"消耗到 0 再重新累积"】玩家 2026-10-07 定稿口径。
# ============================================================

scoreboard players remove @s zx.bl_gu 1
execute if score @s zx.bl_gu matches ..-1 run scoreboard players set @s zx.bl_gu 0

# 定时加成 = floor(上限 × 0.05)  —— ×5 ÷100
scoreboard players operation #new zx.meta = #mx zx.meta
scoreboard players operation #new zx.meta *= #5 zx.meta
scoreboard players operation #new zx.meta /= #100 zx.meta
execute if score #new zx.meta > @s zx.bl_ta run scoreboard players operation @s zx.bl_ta = #new zx.meta
# 到期时刻 = #now + 200(10 秒)
scoreboard players operation @s zx.bl_te = #now manacore.meta
scoreboard players add @s zx.bl_te 200

# 见底 -> 退出消耗模式
execute if score @s zx.bl_gu matches 0 run scoreboard players set @s zx.bl_gm 0
