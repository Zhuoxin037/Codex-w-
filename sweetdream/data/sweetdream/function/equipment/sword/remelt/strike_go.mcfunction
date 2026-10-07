# ============================================================
# sweetdream:equipment/sword/remelt/strike_go —— 结算伤害 + 融甲
# ------------------------------------------------------------
# 【执行者】玩家   【目标】zx.rm_y(带夜火的那些)
# 【数值】基础攻击力 ×2 —— 走"基础攻击力倍率"通道(attack_mul, 基数 = 面板 base_attack)
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.rm_y]",read:"manacore"}
function sweetdream:api/damage

# 护甲值归 0, 持续 10 秒(由 second 倒计时收回)
execute as @e[tag=zx.rm_y] run function sweetdream:equipment/sword/remelt/melt

execute at @e[tag=zx.rm_y] run particle minecraft:soul_fire_flame ~ ~1 ~ 0.4 0.5 0.4 0.03 14 normal
execute at @s run playsound minecraft:block.lava.pop player @a ~ ~ ~ 0.7 1.0
