# ============================================================
# sweetdream:equipment/axe/draught/ol_hit —— 超限·饮鸩第二形态: 每攻击一次
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/draught_hit(player_hurt_entity, 只算平A)
# 【执行者】动手的玩家
# 【文案】"每攻击一次生物则自身受到一次相当于自身最大生命值 ×0.1 的真实伤害，
#   之后使自身基础攻击力 +10%，持续 10 秒且最多触发四次。"
# 【★ 自伤在前、加成在后 ★】文案的顺序就是这样; 而且"代价"必须是真实伤害
#   (type = sweetdream:true_damage, 穿甲), 走 api/damage。
# 【★ +10% 是什么的 10% ★】面板 base_attack(manacore:api/stats/get)的 10%,
#   **取整到至少 1**。存进账本 zx.dg_buf2, 撤除时按同一个数减回去(幂等)。
#   ★ 不读 attribute attack_damage: 那个含手持武器, 不是"基础攻击力"口径。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/draught_hit

# 不在第二形态 -> 收工(先判这一条: 一条计分项判断, 比蓄力工具便宜得多。
#   这个进度对**所有玩家**的每次平A都会触发, 绝大多数人根本没在第二形态里)
execute unless score @s zx.dg_mode matches 2 run return 0

# 满蓄力闸(全包统一口径, 见 lib/atk_charge 头部)
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 还握着超限·饮鸩吗(主副手都算)
scoreboard players set #dg_ok zx.meta 0
execute if items entity @s weapon.mainhand iron_axe[minecraft:custom_data~{zx:["draught"],ol:"draught"}] run scoreboard players set #dg_ok zx.meta 1
execute if items entity @s weapon.offhand iron_axe[minecraft:custom_data~{zx:["draught"],ol:"draught"}] run scoreboard players set #dg_ok zx.meta 1
execute if score #dg_ok zx.meta matches 0 run return 0

# 已经触发 4 次 -> 关掉第二形态(账本留着, 让 ol_expire 正常撤回)
scoreboard players add @s zx.dg_n 0
execute if score @s zx.dg_n matches 4.. run scoreboard players set @s zx.dg_mode 0
execute if score @s zx.dg_n matches 4.. run return 0

# ① 自伤 = 最大生命 ×0.1(真实伤害)
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #dg_mh zx.meta 0
execute store result score #dg_mh zx.meta run data get storage manacore:out r.value 10
data modify storage zx:in arg set value {target:"@s",damage:0.0,type:"sweetdream:true_damage"}
execute store result storage zx:in arg.damage double 0.01 run scoreboard players get #dg_mh zx.meta
function sweetdream:api/damage

# ② 基础攻击力 +10%(取整, 至少 1)
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #dg_cur zx.meta 0
execute store result score #dg_cur zx.meta run data get storage manacore:out r.value
scoreboard players set #dg_add zx.meta 0
scoreboard players operation #dg_add zx.meta = #dg_cur zx.meta
scoreboard players operation #dg_add zx.meta *= #10 zx.meta
scoreboard players operation #dg_add zx.meta /= #100 zx.meta
execute if score #dg_add zx.meta matches ..0 run scoreboard players set #dg_add zx.meta 1

data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #dg_add zx.meta
function manacore:api/stats/add
# ★ 2026-10-23 修: 这一行原来写成 `... @s zx.dg_buf2 zx.meta += #dg_add zx.meta`
#   (多写了一个 zx.meta) ⇒ 整份 ol_hit **加载失败、一条命令都不跑**, 日志里是
#   "Failed to load function ... line 62: 无效的操作"。超限·饮鸩第二形态的
#   "自伤 + 基础攻击力 +10%" 因而**完全没生效**(静默)。正确写法: 目标段只给
#   <玩家> <计分项>, 计分项名只在源段出现一次。
scoreboard players operation @s zx.dg_buf2 += #dg_add zx.meta

# ③ 计时刷新 10 秒 + 次数 +1
scoreboard players set @s zx.dg_on2 10
scoreboard players add @s zx.dg_n 1
execute at @s run particle minecraft:witch ~ ~1 ~ 0.3 0.4 0.3 0.02 8 normal
execute at @s run playsound minecraft:entity.player.hurt player @a ~ ~ ~ 0.5 1.4
tellraw @s [{"text":"饮鸩: 基础攻击力 +","color":"dark_red"},{"score":{"name":"#dg_add","objective":"zx.meta"},"color":"gold"},{"text":" (第 ","color":"dark_red"},{"score":{"name":"@s","objective":"zx.dg_n"},"color":"white"},{"text":" 次 / 共 4 次)","color":"dark_red"}]
