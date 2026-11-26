# ============================================================
# fallendream:equipment/armor/pivot/second —— 「枢」术阵位上限 +1（每秒对账）
# ------------------------------------------------------------
# 【执行者】玩家（lib/second 用 as @a 送进来）
# 【文案】自身魔力值上限 +120（在 armor_mana/passive 统一登记）。自身术阵位上限 +1。
# 【★ 为什么改 stats.formation_limit ★】前置包 formation/create 就是按它判满没满
#   （见 manacore internal/formation/create.mcfunction）⇒ 这是唯一正确的入口。
#   **不要**直接改 formations 数组（那是占用，不是上限）。
# 【★ 差值账本 zx.pv_lim ★】0 = 没加 / 1 = 已加 1。重登后玩家记录还在，靠它避免重复叠加。
# ============================================================

execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run function fallendream:equipment/armor/pivot/off
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"]}] run return 0

execute unless score @s zx.pv_lim matches 1 run function fallendream:equipment/armor/pivot/sync_limit

# ============================================================
# ---- 超限(2026-11-22): 满血 12 秒 → 自己的「阵成」 ----
# ------------------------------------------------------------
# 【文案】「自身保持满血量 12 秒后，进入「阵成」（可以和套装和承的「阵成」叠加），
#   冷却 12 秒。」
# 【★ 用独立的 zx.pv_zc / zx.pv_cd, 不和套装的 zx.br_zc 共用一个账 ★】
#   文案明写"可以叠加" —— 共用一个分数就只能取最长的那个, 叠不起来。
# 【★ 满血判据照抄静脉泵 ★】Health 是浮点, 取整用 scale 1; 上限走 attribute get,
#   被"上限钳制"过的玩家(#nr_clamp)改用 lib/max_health_score。
# 【★ 阵成时长】文案没写, 按套装同款 8 秒(160 刻)。★ 口径待用户确认 ★
# ============================================================
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"],ol:"pivot"}] run scoreboard players set @s zx.pv_hp 0
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"],ol:"pivot"}] run scoreboard players set @s zx.pv_zc 0
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["pivot"],ol:"pivot"}] run return 0

execute store result score #pv_hp zx.meta run data get entity @s Health 1
execute store result score #pv_max zx.meta run attribute @s minecraft:max_health get
execute if entity @s[tag=zx.nr_clamp] run function fallendream:lib/max_health_score
execute if entity @s[tag=zx.nr_clamp] run scoreboard players operation #pv_max zx.meta = #max_hp zx.meta
execute if entity @s[tag=zx.nr_clamp] run scoreboard players operation #pv_max zx.meta /= #1000 zx.meta

scoreboard players set #pv_full zx.meta 0
execute if score #pv_max zx.meta matches 1.. if score #pv_hp zx.meta >= #pv_max zx.meta run scoreboard players set #pv_full zx.meta 1

execute if score #pv_full zx.meta matches 0 run scoreboard players set @s zx.pv_hp 0
execute if score #pv_full zx.meta matches 1 run scoreboard players add @s zx.pv_hp 1

# 满 12 秒: 冷却没走完 -> 只是把计时压回 12(不重复提示); 冷却好了 -> 进入阵成
execute if score @s zx.pv_hp matches 12.. if score @s zx.pv_cd > #now manacore.meta run scoreboard players set @s zx.pv_hp 12
execute if score @s zx.pv_hp matches 12.. unless score @s zx.pv_cd > #now manacore.meta run function fallendream:equipment/armor/pivot/zc
