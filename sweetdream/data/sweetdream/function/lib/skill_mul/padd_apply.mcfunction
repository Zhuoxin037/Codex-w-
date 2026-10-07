# ============================================================
# sweetdream:lib/skill_mul/padd_apply —— 把"加算池"折进面板的三条通道倍率
# ------------------------------------------------------------
# 【谁调用它】lib/skill_mul/scan —— 排在所有 scan_mul(它们只往池子里写百分比)
#   之后、折风声之前。
# 【做什么】把池子 zx:work add 里那几条百分比**先相加、再对 smul_mm/atk/oth 各乘一次**:
#     smul_<c> × (1 + add.<c>)
#   —— 面板要显示的是"真实会生效的乘区", 所以必须和伤害侧同一种算术。
#   ★ 旧写法是每个 scan_mul 各自把 smul_* 乘一次 —— 那等于把"加算"显示成了乘法:
#     共振 +10%/阵 与漫步 +30% 同时生效时面板会显示 ×1.43, 而实伤是 ×1.40
#     (2026-10-06 改; 详见 lib/dmg_add_apply 头注释)。
# 【和伤害侧的差别: 这里**不判通道**】
#   伤害侧只乘"本次技能真正用到的那条通道"(读快照 zx:work ch); 面板没有"本次技能",
#   它的三行本来就是"三条通道各自会被乘多少", 所以三条各乘各的, 互不影响。
# 【定点】百分比 ×100 读成整数; smul_* 也 ×100; 乘完再 ÷100 写回。
#   #p == 0 时 #k == 100 -> ×100÷100 是精确恒等, 所以不必逐个加守卫。
# ============================================================

# --- 最大魔力值 ---
scoreboard players set #p zx.meta 0
execute store result score #p zx.meta run data get storage zx:work add.mm 100
scoreboard players set #k zx.meta 100
scoreboard players operation #k zx.meta += #p zx.meta
scoreboard players set #m zx.meta 0
execute store result score #m zx.meta run data get storage zx:work pl.smul_mm 100
scoreboard players operation #m zx.meta *= #k zx.meta
scoreboard players operation #m zx.meta /= #100 zx.meta
execute store result storage zx:work pl.smul_mm double 0.01 run scoreboard players get #m zx.meta

# --- 基础攻击力 ---
scoreboard players set #p zx.meta 0
execute store result score #p zx.meta run data get storage zx:work add.atk 100
scoreboard players set #k zx.meta 100
scoreboard players operation #k zx.meta += #p zx.meta
scoreboard players set #m zx.meta 0
execute store result score #m zx.meta run data get storage zx:work pl.smul_atk 100
scoreboard players operation #m zx.meta *= #k zx.meta
scoreboard players operation #m zx.meta /= #100 zx.meta
execute store result storage zx:work pl.smul_atk double 0.01 run scoreboard players get #m zx.meta

# --- 其他 ---
scoreboard players set #p zx.meta 0
execute store result score #p zx.meta run data get storage zx:work add.oth 100
scoreboard players set #k zx.meta 100
scoreboard players operation #k zx.meta += #p zx.meta
scoreboard players set #m zx.meta 0
execute store result score #m zx.meta run data get storage zx:work pl.smul_oth 100
scoreboard players operation #m zx.meta *= #k zx.meta
scoreboard players operation #m zx.meta /= #100 zx.meta
execute store result storage zx:work pl.smul_oth double 0.01 run scoreboard players get #m zx.meta
