# ============================================================
# sweetdream:equipment/armor/smoke_step/hit —— 烟履: 砍"已烧着"的目标换魔力与迅捷
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/smoke_step_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +40。普通近战命中了原本附有「流火」的生物后，
#   为自身回复 10 魔力，并获得 2 秒迅捷Ⅰ。该效果 3 秒内最多触发一次。
# 【★ 与燧帽互为反面 ★】燧帽挑"**未**带流火"的，本件挑"**原本附有**流火"的 ——
#   加不加 tag=zx.status.liuhuo 就是这两件的全部区别（同套装里的"点火 / 收割"分工）。
# 【★ 文案没有"仍存活" ★】所以这里**不**依赖"目标还活着"；不过 lib/victim 靠
#   生物身上的 last_hurt_by_player + HurtTime 定位，目标被打死就定位不到 ——
#   实际表现仍是"打死了不触发"。这属于定位手段的天然边界，不是我们额外加的限制。
# 【回复魔力走 api/mana/add ★不是 consume★】这是**给**魔力，没有"够不够"的问题。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/smoke_step_hit

# ---- 满蓄力闸（全包统一口径：平A 没蓄满力这一发不触发；见 lib/atk_charge 头部） ----
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿烟履就没这事（靴子）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["smoke_step"]}] run return 0

# ② 3 秒节流（账本存"下次可触发刻"）
scoreboard players set #ss_due zx.meta 0
execute store result score #ss_due zx.meta run scoreboard players get @s zx.ss_cd
execute if score #ss_due zx.meta > #now manacore.meta run return 0

# ③ 定位命中的那一只
function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/armor/smoke_step/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
