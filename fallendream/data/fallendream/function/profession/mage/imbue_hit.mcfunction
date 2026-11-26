# ============================================================
# fallendream:profession/mage/imbue_hit —— 注魔被动（魔导士 · 命中生物后）
# ------------------------------------------------------------
# 【原版】每次攻击到生物后，魔力 > 100 ⇒ 消耗 50 魔力，获得一个法球。
# 【超限】消耗 45；且"自身当前每有一个法球则本次消耗 -6（最多 -30）"
#   ⇒ 实际消耗 = max(45 - 6 × 当前法球数, 15)，最低压到 15。
#   ★ 法球数取 tally 的 #jorbs（= zx.j_orb + zx.j_prop），与「预言」占用法球
#     容量的既有口径一致 —— 玩家看得见的球都算，否则"当前每有一个法球"会
#     漏掉预言那一类。
#   ★ 减免在**扣费前**算完，扣的确实是减后的数（不是先扣 45 再返）。
#   ★ 球满（add_orb 因 #jcap 加不上）时照旧扣费 —— 与原版行为一致，不改。
# ============================================================
execute unless score @s zx.job matches 1 run return 0
execute unless items entity @s weapon.mainhand *[custom_data~{zx:["mana_imbue"]}] run return 0
function fallendream:lib/uuid
execute if score @s zx.j_im_n matches 1.. run function fallendream:profession/mage/imbue_repeat

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #jimb_m zx.meta run data get storage manacore:out r.value 1000
execute unless score #jimb_m zx.meta matches 100001.. run return 0

# 超限判定（★ 被动只认主手 ★）
#   "每次攻击到生物后"是由主手武器打出来的；若主手普通注魔、副手超限注魔，
#   把副手也算进来会给出 45 - 6×球数 的错误折扣。副手那条只属于主动技能
#   （skill.mcfunction 里保留），这里绝不能再判。
scoreboard players set #im_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["mana_imbue"],ol:"mana_imbue"}] run scoreboard players set #im_ol zx.meta 1

# 扣费额：原版 50 / 超限 45 - 6×球数（最多 -30）
scoreboard players set #im_pay zx.meta 50
execute if score #im_ol zx.meta matches 1 run scoreboard players set #im_pay zx.meta 45
execute if score #im_ol zx.meta matches 1 run function fallendream:equipment/sword/mana_imbue/pay_calc

data modify storage manacore:in arg set value {uuid:"",value:50.0}
execute store result storage manacore:in arg.value double 1 run scoreboard players get #im_pay zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:1b} run function fallendream:profession/mage/add_orb
