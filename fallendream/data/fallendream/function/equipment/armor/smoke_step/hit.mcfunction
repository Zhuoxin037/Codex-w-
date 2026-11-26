# ============================================================
# fallendream:equipment/armor/smoke_step/hit —— 烟履: 砍"已烧着"的目标换魔力与迅捷
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/armor/smoke_step_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字 · 基础)】自身魔力值上限 +40。普通近战命中了原本附有「流火」的生物后，
#   为自身回复 10 魔力，并获得 2 秒迅捷Ⅰ。该效果 3 秒内最多触发一次。
# 【文案(lore 逐字 · 超限)】自身魔力值上限 +120。普通近战命中了原本附有「流火」的生物后，
#   为自身恢复 15 点魔力值及 1% 魔力值，并获得 3 秒迅捷Ⅱ。该效果 3 秒内最多触发一次。
#   在本件给予的迅捷持续期间累计移动 4 格后，在 3 秒内下一次普通近战命中附有「流火」
#   的生物后可额外触发一次上述效果。
# 【★ 与燧帽互为反面 ★】燧帽挑"**未**带流火"的，本件挑"**原本附有**流火"的 ——
#   加不加 tag=zx.status.liuhuo 就是这两件的全部区别（同套装里的"点火 / 收割"分工）。
# 【★ 文案没有"仍存活" ★】所以这里**不**依赖"目标还活着"；不过 lib/victim 靠
#   生物身上的 last_hurt_by_player + HurtTime 定位，目标被打死就定位不到 ——
#   实际表现仍是"打死了不触发"。这属于定位手段的天然边界，不是我们额外加的限制。
# 【回复魔力走 api/mana/add ★不是 consume★】这是**给**魔力，没有"够不够"的问题。
# 【★ 超限的"额外触发一次"怎么放行 ★】
#   · 移动累计在 smoke_step/move_tick（batch21/player_tick 每刻扫，只在迅捷窗口内）。
#   · 攒够 4 格 → zx.ss_extra = #now+60（"3 秒内"）。这里做闸时：
#     节流没到但 ss_extra 还在 → 放行，并记 @s zx.ss_use=1（由 victim_body 消费掉）。
#     节流本来就没到点(能正常触发)时**不**消费 ss_extra —— 那一次机会留着。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/smoke_step_hit

# ---- 满蓄力闸（全包统一口径：平A 没蓄满力这一发不触发；见 lib/atk_charge 头部） ----
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿烟履就没这事（靴子）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["smoke_step"]}] run return 0

# ② 节流闸: 3 秒（两档同）；超限多一条"攒够移动换来的额外一次"
scoreboard players set @s zx.ss_use 0
scoreboard players set #ss_gate zx.meta 0
scoreboard players set #ss_due zx.meta 0
execute store result score #ss_due zx.meta run scoreboard players get @s zx.ss_cd
execute unless score #ss_due zx.meta > #now manacore.meta run scoreboard players set #ss_gate zx.meta 1
execute if score #ss_gate zx.meta matches 0 if score @s zx.ss_extra > #now manacore.meta run scoreboard players set @s zx.ss_use 1
execute if score #ss_gate zx.meta matches 0 unless score @s zx.ss_use matches 1 run return 0

# ③ 定位命中的那一只
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/armor/smoke_step/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
