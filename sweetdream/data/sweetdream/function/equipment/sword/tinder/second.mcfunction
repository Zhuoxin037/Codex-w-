# ============================================================
# sweetdream:equipment/sword/tinder/second —— 火种 · 每秒心跳(手持自动点燃)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a run function ...
# 【技能原文(必须和这里对上)】
#   "手持时，若自身魔力值大于 400 且「火种」为熄灭状态则消耗 350 点魔力值并使
#    「火种」变为燃烧状态。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 手持(主手) + 每秒检查一次。
#   ② 目标范围: 自身。
#   ③ 次数: 每次满足条件点一次(点着之后 td_on=1, 不再重复消耗)。
#   ④ 时长: 永久(直到被攻击熄灭)。
# 【为什么每秒不是每刻】"手持自动点燃"是状态维持, 每秒扫一次足够, 也没必要每刻读魔力。
# ============================================================

# ★ 外观兜底: 先把手持的火种按当前状态刷一遍(拿到剑 / 换到手 / 刚进世界 —— 1 秒内补上模型)
#   状态翻转的当刻另外在 burn / dark 里各调一次, 所以这里只负责"漏网的一秒"。
function sweetdream:equipment/sword/tinder/visual/sync

# 主手必须是火种(手持 = 主手拿着)
execute unless items entity @s weapon.mainhand netherite_sword[custom_data~{zx:["tinder"]}] run return 0

# 已经是燃烧态就不做
execute if score @s zx.td_on matches 1 run return 0

# 读当前魔力, 必须 > 400
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #td_m zx.meta run data get storage manacore:out r.value 1
execute if score #td_m zx.meta matches ..400 run return 0

# 消耗 350 魔力
data modify storage manacore:in arg set value {uuid:"",value:350.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return 0

# 点燃
scoreboard players set @s zx.td_on 1
#   ★ 当刻同步外观(顶部那次 sync 跑在点燃之前, 那时还是熄灭态)
function sweetdream:equipment/sword/tinder/visual/sync
execute at @s run particle minecraft:flame ~ ~1 ~ 0.5 0.6 0.5 0.02 24 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.9 1.0
