# ============================================================
# sweetdream:equipment/armor/needle_sleep/hit —— 针眠: 命中给目标点「噬心」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/needle_sleep_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +100。自身法杖普攻或攻击命中了未附有「噬心」的
#   生物后，若魔力足够，则消耗 60 魔力并使其附加「噬心」。该效果 10 秒内最多触发一次。
# 【★ "法杖普攻或攻击" 就是同一条进度 ★】本包的法杖普攻也走原版攻击判定
#   (player_hurt_entity + is_player_attack 的伤害类型) —— 和剑/斧的近战命中同一个触发源,
#   不需要另开一条"法杖专用"进度(全包先例: 刺纹 / 燧帽 / 烟履 都只用这一条)。
# 【★ 附加是"附着"不是"消耗" ★】走 tag/mark（不走 mark_consume）。
# 【★ "若魔力足够" 交给 api/mana/consume 判 ★】见燧帽 hit 的同款注释。
# 【★ 本件同时是"缝心"套装「绯结」的积攒来源 ★】附加成功后如果穿齐缝心两件,
#   就顺手积攒 1 层「绯结」—— 积攒逻辑写在 crimson_seam/knit_add, 由这里调用。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/needle_sleep_hit

# ---- 满蓄力闸（全包统一口径：平A 没蓄满力这一发不触发；见 lib/atk_charge 头部） ----
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿针眠就没这事（头盔）
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["needle_sleep"]}] run return 0

# ② 10 秒节流（账本存"下次可触发刻"）
scoreboard players set #ns_due zx.meta 0
execute store result score #ns_due zx.meta run scoreboard players get @s zx.ns_cd
execute if score #ns_due zx.meta > #now manacore.meta run return 0

# ③ 定位命中的那一只
function sweetdream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function sweetdream:equipment/armor/needle_sleep/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
