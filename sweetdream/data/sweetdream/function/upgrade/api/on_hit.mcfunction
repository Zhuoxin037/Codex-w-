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
# 【★ "每次攻击" = 一次平A算一次(命中几只都一样) ★】玩家 2026-10-07 定稿的措辞口径:
#   文案写「每次攻击(后)」-> 按**攻击次数**算; 文案写「攻击到生物」-> 才按**命中数**算。
#   升级石·魔力增殖的文案是"每次攻击都会为自身恢复 5 魔力值" ⇒ 一次算一次
#   (实现 = 下面按游戏刻去重那两行)。
# ============================================================

advancement revoke @s only sweetdream:upgrade/attack

# 【★ 同一刻只算一次 ★】进度是 `player_hurt_entity` —— **每命中一个生物触发一次**。
#   横扫打 3 只 => 这个函数同一刻跑 3 遍 => 回魔也来 3 遍(α 打 3 只 = 回 15 魔力)。
#   按**游戏刻**去重(照 brain_leech/attack 的既定做法, 用框架时钟 #now):
#   · 没分数的玩家 `if score ... = #now` 直接判失败 => 第一次照样放行。
#   · 先判后写戳; 本函数没有别的门控(任意主手武器都可能有升级), 所以放在最前。
execute if score @s zx.up_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.up_lt = #now manacore.meta

# 【通用工具 · 平A 蓄力判定(2026-10-10)】算"这一发平A的蓄力", 出参 #atk_full / #atk_pct,
#   用法与口径见 lib/atk_charge 的文件头。
#   ★ 必须放在上面那条"每刻只算一次"的去重**之后** —— 一记横扫打多只时,
#     第 2 只的 gap 会变成 0(工具自己写了记录), 排前面就会读到假的"未蓄满"。
#   ★ 现在**没有任何武器读 #atk_full**, 所以对玩法零影响; 只是把数值算出来备用 + 供自测。
function sweetdream:lib/atk_charge

function sweetdream:upgrade/api/bonus_held

# 【★ 效果开关要在 bonus_held 之后立刻读出来 ★】zx:out 是全包共用的出口节点,
#   下面 hit_percent / hit_gain 还会调别的接口; 晚一步读就可能读到别人的结果。
#   (存进 zx.meta 的临时量同理 —— #up_tc / #up_boil 只在本函数里用, 不会被那两个改)
scoreboard players set #up_tc zx.meta 0
execute store result score #up_tc zx.meta run data get storage zx:out r.tc
scoreboard players set #up_boil zx.meta 0
execute store result score #up_boil zx.meta run data get storage zx:out r.boil
scoreboard players set #up_mk zx.meta 0

scoreboard players set #up_gain zx.meta 0
scoreboard players set #up_t zx.meta 0
execute store result score #up_t zx.meta run data get storage zx:out r.mh
scoreboard players operation #up_gain zx.meta += #up_t zx.meta

# 百分比那一档(1.5 = 1.5%)要按当前最大魔力现算
scoreboard players set #up_pct zx.meta 0
execute store result score #up_pct zx.meta run data get storage zx:out r.mhp 100
execute if score #up_pct zx.meta matches 1.. run function sweetdream:upgrade/api/hit_percent

execute if score #up_gain zx.meta matches 1.. run function sweetdream:upgrade/api/hit_gain

# ④ 火炬 / 沸腾(2026-10-08): 两条都要作用到"被打的那一只"身上, 所以先定位目标。
#   ★ 沿用本函数最上面那条"每刻只算一次"的去重 —— 两者的文案都是「每次攻击」,
#     即一次平A一次(不是按命中数), 所以这里不需要再加第二层去重。
#   ★ lib/victim 只在真要用时才调: 装了这两颗石头的人毕竟是少数。
#   ★ 两个开关共用一个入口(只定位一次目标), 且只在真装了这两颗石头时才跑。
execute if score #up_tc zx.meta matches 1.. run scoreboard players set #up_mk zx.meta 1
execute if score #up_boil zx.meta matches 1.. run scoreboard players set #up_mk zx.meta 1
execute if score #up_mk zx.meta matches 1 run function sweetdream:upgrade/api/hit_mark
