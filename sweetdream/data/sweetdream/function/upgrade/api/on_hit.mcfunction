# ============================================================
# sweetdream:upgrade/api/on_hit —— 攻击命中后, 按主手武器的升级回魔
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:upgrade/attack(player_hurt_entity), 以动手的玩家身份
# 【★ 只有平A算 ★】那条进度带着条件 `damage.type.tags = minecraft:is_player_attack`
#   (原版标签 = player_attack + mace_smash, 即"玩家近战")。
#   所以**技能伤害不算**: 本包所有技能伤害都是 sweetdream:skill 类型
#   (api/damage 的默认类型, 见 core/load 的 zx:config damage_type),
#   类型对不上 -> 进度不授予 -> 这个函数根本不会被调用, 谈不上回魔。
#   不写这个条件的话会出现"放个技能顺带回满魔力"(2026-10-04 玩家反馈, 已修)。
#   ⚠️ 想让别的"攻击命中"效果也只看平A(幻昼 mirage_attack / 焚舟 immolate_hurt),
#      照抄那条条件即可 —— 那两条目前**仍然会被技能伤害触发**。
# 【怎么算】主手武器上的升级给 mh(固定值) + mhp(最大魔力的百分比), 两者相加。
#   没升级的武器读出来都是 0, 所以空手/拿别的东西不会平白回魔。
# 【为什么不挑"被打的是谁"】回魔只和"我手里这把"有关, 和打到谁无关 ——
#   只有需要作用到目标身上的效果(附加标签之类)才要定位生物, 见 mirage/attack。
# ============================================================

advancement revoke @s only sweetdream:upgrade/attack

function sweetdream:upgrade/api/bonus_held

scoreboard players set #up_gain zx.meta 0
scoreboard players set #up_t zx.meta 0
execute store result score #up_t zx.meta run data get storage zx:out r.mh
scoreboard players operation #up_gain zx.meta += #up_t zx.meta

# 百分比那一档(1.5 = 1.5%)要按当前最大魔力现算
scoreboard players set #up_pct zx.meta 0
execute store result score #up_pct zx.meta run data get storage zx:out r.mhp 100
execute if score #up_pct zx.meta matches 1.. run function sweetdream:upgrade/api/hit_percent

execute if score #up_gain zx.meta matches 1.. run function sweetdream:upgrade/api/hit_gain
