# ============================================================
# fallendream:equipment/armor/blaze_armor/ol_melee_hit —— 超限·焱：给他 3 秒燃烧 + 一次固定伤害
# ------------------------------------------------------------
# 【宏参数】context {vx_uuid}（由 lib/victim 给出）
# 【执行者】动手的那个玩家   【目标】$(vx_uuid)
# 【文案】"…使受到伤害的生物获得 3 秒燃烧状态并使其受到一次相当于自身基础攻击力的
#   固定伤害。"
# 【★ 3 秒 = 60 tick ★】`Fire` 的单位是 tick（`60s` 里的 s 是 short 后缀，不是秒）。
#   ★ 只能对**生物**写 NBT；玩家写不进去（commands.data.entity.invalid），
#     所以这一条对"平A 打玩家"自然不生效 —— 与包内其它点火实现一致。
# 【★ 固定伤害走 fixed:1b ★】照 chengxing 的写法：fixed 表示"不再进任何乘区"，
#   数值直接读面板 base_attack（"相当于自身基础攻击力"）。
# ============================================================

$execute unless entity $(vx_uuid) run return 0

# ① 3 秒燃烧
$execute as $(vx_uuid) run data merge entity @s {Fire:60s}

# ② 附加「流火」（文案只说"燃烧状态"，没提流火 —— 这里**不加**，保持与原文一致）
#    ★ 与 ④/⑤ 的"5 秒燃烧 + 流火"区分开：那两处原文明确写了「流火」。

# ③ 固定伤害 = 自身基础攻击力
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #ba_d zx.meta 0
execute store result score #ba_d zx.meta run data get storage manacore:out r.value 100
execute unless score #ba_d zx.meta matches 1.. run return 0

$data modify storage zx:work a set value {fixed:1b,target:"$(vx_uuid)",type:"minecraft:player_attack"}
execute store result storage zx:work a.num double 0.01 run scoreboard players get #ba_d zx.meta
function fallendream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function fallendream:internal/attack/submit_extra

# ④ 表现 + 收尾
$execute at $(vx_uuid) run particle minecraft:flame ~ ~1 ~ 0.3 0.4 0.3 0.02 10 normal
$execute at $(vx_uuid) run particle minecraft:lava ~ ~0.6 ~ 0.2 0.3 0.2 0 4 normal
$execute at $(vx_uuid) run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.5 1.2
$tag $(vx_uuid) remove zx.victim
