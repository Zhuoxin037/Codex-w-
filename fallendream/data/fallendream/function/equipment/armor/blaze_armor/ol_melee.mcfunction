# ============================================================
# fallendream:equipment/armor/blaze_armor/ol_melee —— 超限·焱：下一次普通近战
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/armor/blaze_armor_ol_hit（player_hurt_entity, 只认平A）
# 【执行者】动手的那个玩家
# 【文案(逐字)】"…自身的下一次普通近战也将使受到伤害的生物获得 3 秒燃烧状态并使其
#   受到一次相当于自身基础攻击力的固定伤害。"
# 【★ 一次性 ★】zx.ba_nx 是"待发"标记（由 hurt ⑥ 在"已燃烧"档挂上），
#   本文件**先清标记再打** —— 否则同一次平A的多段结算会重复触发。
# 【★ 满蓄力闸 ★】与包里所有平A被动一致：没蓄满这一发不算（见 lib/atk_charge 头）。
# 【★ 受害者怎么找 ★】lib/victim（last_hurt_by_player + HurtTime 收窄），同归息。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/blaze_armor_ol_hit

# ① 穿着门控 + 待发标记
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["blaze_armor"],ol:"blaze_armor"}] run return 0
execute unless score @s zx.ba_nx matches 1 run return 0

# ② 满蓄力
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ③ 先消费标记（一次性），再定位目标
scoreboard players set @s zx.ba_nx 0
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0

data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/armor/blaze_armor/ol_melee_hit with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
