# ============================================================
# fallendream:equipment/armor/thorn_vein/hit —— 刺纹: 残血时给目标挂「噬心」
# ------------------------------------------------------------
# 【谁调用它】进度 fallendream:equipment/armor/thorn_vein_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字 · 基础)】自身魔力值上限 +60。自身生命值低于最大生命值的 50% 时，
#   攻击命中了未附有「噬心」的生物后则为其附加「噬心」，并获得 3 秒抗性提升Ⅰ。
#   该效果 10 秒内最多触发一次。
# 【文案(lore 逐字 · 超限)】自身魔力值上限 +160。自身生命值低于最大生命值的 50% 时，
#   攻击命中了未附有「噬心」的生物后则为其附加「噬心」，并获得 6 秒抗性提升二。
#   该效果 8 秒内最多触发一次。若自身生命值低于最大生命值的 30%，则额外使其 3 格内的
#   其他 2 个生物获得「噬心」，且自身恢复 1% 魔力值，效果冷却时间缩短至 6 秒。
# 【★ 顺序: 先判血量再判节流 ★】
#   基础版原来把节流排在血量前, 那是因为 CD 是个定值。超限档的 CD 按血量分三档
#   (基础 10 秒 / 超限 8 秒 / 超限低血 6 秒), 所以必须先算出"低血没低血"再定这一次的闸。
# 【附加是"附着"不是"消耗"】走 tag/mark（不走 mark_consume）—— 走入口会把执行者
#   当成"消耗者", 白给余烬/回潮扣那一串被动。
# ============================================================

advancement revoke @s only fallendream:equipment/armor/thorn_vein_hit

# ---- 满蓄力闸（全包统一口径；见 lib/atk_charge 头部） ----
function fallendream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿刺纹就没这事（护腿）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["thorn_vein"]}] run return 0

# ①.5 档位快照: 这一次是基础还是超限(抗性秒数/等级、扩散、CD 都要分档)
#   插在这里而不是后面, 是因为"档位"只跟身上那件有关, 与血量/目标无关。
scoreboard players set @s zx.tv_ol 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["thorn_vein"],ol:"thorn_vein"}] run scoreboard players set @s zx.tv_ol 1

# ② 读面板最大生命 + 当前生命（都 ×1000 定点, 免得小数比大小翻车）
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #tv_mh zx.meta 0
execute store result score #tv_mh zx.meta run data get storage manacore:out r.value 1000
scoreboard players set #tv_hp zx.meta 0
execute store result score #tv_hp zx.meta run data get entity @s Health 1000
scoreboard players set #tv_half zx.meta 0
scoreboard players operation #tv_half zx.meta = #tv_mh zx.meta
scoreboard players operation #tv_half zx.meta /= #2 zx.meta

# ③ 生命值必须低于最大生命值的 50%
execute if score #tv_hp zx.meta >= #tv_half zx.meta run return 0

# ③.5 超限档低血(<30%)判定 —— 决定"扩不扩散"和"CD 是 8 秒还是 6 秒"
#   ★ 全程用 scores 累加/比较, 不用 return: 低血与否只落一个 0/1, 后面还要接着跑。
#   ★ 30% 用"先 ÷10 再 ×3", 直接 ×3÷10 在 #tv_mh 很大时会溢出。
scoreboard players set @s zx.tv_low 0
scoreboard players set #tv_30 zx.meta 0
scoreboard players operation #tv_30 zx.meta = #tv_mh zx.meta
scoreboard players operation #tv_30 zx.meta /= #10 zx.meta
scoreboard players operation #tv_30 zx.meta *= #3 zx.meta
execute if score @s zx.tv_ol matches 1 if score #tv_hp zx.meta < #tv_30 zx.meta run scoreboard players set @s zx.tv_low 1

# ④ 节流（账本存"下次可触发刻"）: 基础 10 秒 / 超限 8 秒 / 超限低血 6 秒
#   ★ 先 `store result` 读账本前把 #tv_due 清 0: 玩家没这个分数时 get 会失败,
#     store result 不执行, 残留上一次的值就会误判。
scoreboard players set #tv_gap zx.meta 200
execute if score @s zx.tv_ol matches 1 run scoreboard players set #tv_gap zx.meta 160
execute if score @s zx.tv_low matches 1 run scoreboard players set #tv_gap zx.meta 120
scoreboard players set #tv_due zx.meta 0
execute store result score #tv_due zx.meta run scoreboard players get @s zx.thorn_cd
execute if score #tv_due zx.meta > #now manacore.meta run return 0

# ⑤ 定位刚才这一下平A打的是哪一只；它必须**未**带「噬心」
function fallendream:lib/victim
execute unless data storage zx:victim context.vx_uuid run return 0
data modify storage zx:work vx_frames append value {context:{}}
data modify storage zx:work vx_frames[-1].context set from storage zx:victim context
function fallendream:equipment/armor/thorn_vein/hit/victim_body with storage zx:work vx_frames[-1].context
data modify storage zx:victim context set from storage zx:work vx_frames[-1].context
data remove storage zx:work vx_frames[-1]
