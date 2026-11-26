# ============================================================
# fallendream:equipment/armor/breath_hold/second —— 「屏息」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家(lib/fm/read 之后: zx.fm_c / zx.fm_u 已是本秒读数)
# 【基础版】魔力上限 +60(armor_mana 登记)。每 1 个空闲术阵位 → 每秒回 2 点；
#   术阵位全满时改为每秒回 1 点。
# 【超限版】魔力上限 +140(armor_mana 登记)。每 1 个空闲术阵位 → 每秒回
#   0.5% 最大魔力，且自身最大魔力 +2%；术阵位全满时改为每秒回 5 点，
#   且自身技能伤害 +12%(伤害那条在 hook_calc，本文件只管回魔与上限)。
# 【★ 上限用"差值账本"维护(zx.bh_addm，×1000 定点)★】
#   面板只有一个 max_mana，没有加成层 ⇒ 直接乘/加会越滚越大。每秒重算目标值
#   再补差值；基准 = 当前上限 − 账本 ⇒ 那 2% 不会被算进自己的 2% 里。
# 【★ 摘头盔必须退账 ★】老版本"没穿就 return 0"，基础版没有上限效果所以没事；
#   超限这 2%/位是**加在上限上的实数**，不退就是"穿过一次永久 +X"。
# ============================================================

# ---- ⓪ 档位: 0 = 没穿 / 1 = 基础 / 2 = 超限 ----
scoreboard players set #bh_ol zx.meta 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["breath_hold"]}] run scoreboard players set #bh_ol zx.meta 1
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["breath_hold"],ol:"breath_hold"}] run scoreboard players set #bh_ol zx.meta 2

# ---- ① 空闲术阵位 = 上限 − 占用 ----
scoreboard players operation #bh_free zx.meta = @s zx.fm_c
scoreboard players operation #bh_free zx.meta -= @s zx.fm_u

# ---- ② 超限: 维护「最大魔力 +2% × 空闲位」----
#   #bh_want 默认 0 ⇒ 没穿 / 基础版 / 全满 时会自动把账本退干净
scoreboard players set #bh_want zx.meta 0
execute if score #bh_ol zx.meta matches 2 if score #bh_free zx.meta matches 1.. run function fallendream:equipment/armor/breath_hold/pct_want
function fallendream:equipment/armor/breath_hold/apply_pct

# ---- ③ 回魔(#bh_re 单位 = 1/1000 点)----
scoreboard players set #bh_re zx.meta 0
#   基础: 空闲 ×2 点(→ ×2000) / 全满 1 点(= 1000)
execute if score #bh_ol zx.meta matches 1 if score #bh_free zx.meta matches 1.. run scoreboard players operation #bh_re zx.meta = #bh_free zx.meta
execute if score #bh_ol zx.meta matches 1 if score #bh_free zx.meta matches 1.. run scoreboard players operation #bh_re zx.meta *= #2 zx.meta
execute if score #bh_ol zx.meta matches 1 if score #bh_free zx.meta matches 1.. run scoreboard players operation #bh_re zx.meta *= #1000 zx.meta
execute if score #bh_ol zx.meta matches 1 if score #bh_free zx.meta matches ..0 run scoreboard players set #bh_re zx.meta 1000
#   超限: 空闲 ×0.5% 上限 / 全满 5 点(= 5000)
execute if score #bh_ol zx.meta matches 2 if score #bh_free zx.meta matches 1.. run function fallendream:equipment/armor/breath_hold/regen_ol
execute if score #bh_ol zx.meta matches 2 if score #bh_free zx.meta matches ..0 run scoreboard players set #bh_re zx.meta 5000

execute if score #bh_re zx.meta matches 1.. run function fallendream:equipment/armor/breath_hold/regen
