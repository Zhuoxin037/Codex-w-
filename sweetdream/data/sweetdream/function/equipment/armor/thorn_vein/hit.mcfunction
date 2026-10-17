# ============================================================
# sweetdream:equipment/armor/thorn_vein/hit —— 刺纹: 残血时给目标挂「噬心」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/thorn_vein_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +60。自身生命值低于最大生命值的 50% 时，攻击
#   命中了未附有「噬心」的生物后则为其附加「噬心」，并获得 3 秒抗性提升Ⅰ。
#   该效果 10 秒内最多触发一次。
# 【★ 顺序: 先判血量再定位目标 ★】文案把"生命值低于 50%"写在最前面, 是整段的闸。
# 【附加是"附着"不是"消耗"】走 tag/mark（不走 mark_consume）—— 走入口会把执行者
#   当成"消耗者", 白给余烬/回潮扣那一串被动。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/thorn_vein_hit

# ---- 满蓄力闸（全包统一口径；见 lib/atk_charge 头部） ----
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿刺纹就没这事（护腿）
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["thorn_vein"]}] run return 0

# ② 10 秒节流（账本存"下次可触发刻"）
scoreboard players set #tv_due zx.meta 0
execute store result score #tv_due zx.meta run scoreboard players get @s zx.thorn_cd
execute if score #tv_due zx.meta > #now manacore.meta run return 0

# ③ 生命值必须低于最大生命值的 50%
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
execute store result score #tv_mh zx.meta run data get storage manacore:out r.value 1000
execute store result score #tv_hp zx.meta run data get entity @s Health 1000
scoreboard players set #tv_half zx.meta 0
scoreboard players operation #tv_half zx.meta = #tv_mh zx.meta
scoreboard players operation #tv_half zx.meta /= #2 zx.meta
execute if score #tv_hp zx.meta >= #tv_half zx.meta run return 0

# ④ 定位刚才这一下平A打的是哪一只；它必须**未**带「噬心」
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0
execute as @e[tag=zx.victim,distance=0..,limit=1] if entity @s[tag=zx.status.shixin] run return 0

# ⑤ 给它附加「噬心」（附着 -> tag/mark）
data modify storage zx:work ic set value {target:"@e[tag=zx.victim,limit=1]",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

# ⑥ 自身获得 3 秒抗性提升Ⅰ
effect give @s minecraft:resistance 3 0 true

# ⑦ 表现 + 记账 + 收尾
execute at @e[tag=zx.victim,limit=1] run particle minecraft:item{item:{id:"minecraft:pointed_dripstone",count:1}} ~ ~1 ~ 0.3 0.4 0.3 0.02 8 normal
execute at @s run playsound minecraft:block.amethyst_cluster.break player @a ~ ~ ~ 0.5 1.5
scoreboard players operation @s zx.thorn_cd = #now manacore.meta
scoreboard players operation @s zx.thorn_cd += #200 zx.meta
tag @e[tag=zx.victim] remove zx.victim
