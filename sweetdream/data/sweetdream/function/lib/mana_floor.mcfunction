# ============================================================
# sweetdream:lib/mana_floor —— 魔力上限的"下限保护"
# ------------------------------------------------------------
# 【执行者】玩家(由 lib/second 在每秒最后逐个 as @a 调进来)
# 【为什么要有这一份】框架基础的 max_mana 只有 100, 而脑髓蛭 -120、
#   脊骨共生 -180 加起来是 -300 —— 只穿这一套就会算出 -200 的上限。
#   负上限的后果: 当前魔力被夹到 0(放不出任何技能)、"魔力满"永远成立、
#   攻击/护甲/血量加成变成负数。所以必须托一个底。
# 【为什么是"全局托底"而不是每件自己夹】
#   每件自己夹的话, 脱下**别的**装备导致上限掉下去时, 那一件会反过来
#   补上限(它的账本只盯着自己的 -120), 越补越乱。放在最后统一兜底最稳。
# 【为什么用账本】补正是"加"进面板的, 到时必须按这本账减回去, 否则
#   玩家能靠穿脱白嫖上限。zx.floor_mana 记的就是"现在垫了多少"。
# 【释放时的守卫】回收补正不能把上限压到下限以下 —— 只有真的有富余才回收,
#   所以不会出现"垫高 → 收回 → 再垫高"的抖动。
# 【想改下限】改下面 #floor 那一行(现在托到 20)。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
scoreboard players add @s zx.floor_mana 0

# ① 读当前魔力上限
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #mx zx.meta run data get storage manacore:out r.max

# ② 目标补正量: 低于下限就补到下限, 否则 0(并把垫过的收回来)
scoreboard players set #floor zx.meta 20
scoreboard players set #want zx.meta 0
execute if score #mx zx.meta matches ..19 run scoreboard players operation #want zx.meta = #floor zx.meta
execute if score #mx zx.meta matches ..19 run scoreboard players operation #want zx.meta -= #mx zx.meta

scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.floor_mana

# ③ 守卫: 补完之后不能低于下限
scoreboard players set #test zx.meta 0
scoreboard players operation #test zx.meta = #mx zx.meta
scoreboard players operation #test zx.meta += #diff zx.meta
execute if score #test zx.meta < #floor zx.meta run scoreboard players operation #diff zx.meta = #floor zx.meta
execute if score #test zx.meta < #floor zx.meta run scoreboard players operation #diff zx.meta -= #mx zx.meta

execute unless score #diff zx.meta matches 0 run function sweetdream:lib/mana_floor_apply
