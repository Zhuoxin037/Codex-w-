# ============================================================
# sweetdream:equipment/tool/mana_pump/passive —— 体外魔力泵: 被动(每秒)
# ------------------------------------------------------------
# 【谁调用它】second(挂在 #manacore:event/second 上) -> execute as @a 逐个玩家
# 【文案】最大魔力值 +120。
# 【为什么对全部玩家跑】这是"拿着加、放下减"的差值账本 —— 只筛"拿在副手"的人
#   的话, 换下那一刻没人执行, 加成永远减不回去(照炉心 furnace_core/passive 的定式)。
# 【槽位】副手 = weapon.offhand(判定写法与其它副手件一致)。
# 【★ 别和 armor/intravenous_pump(静脉泵, 胸甲) 搞混 ★】两个名字像、上限也都是 +120,
#   但一个是胸甲一个是副手, 账本也各记各的(zx.ip_mana / zx.mp_mana)。
# ============================================================

# ① 拿 UUID(账本要按玩家记)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 副手拿着吗
scoreboard players set #on zx.meta 0
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["mana_pump"]}] run scoreboard players set #on zx.meta 1

# ③ 想要的上限 = 120(没拿就是 0), 和账本求差后补差
scoreboard players set #want zx.meta 0
execute if score #on zx.meta matches 1 run scoreboard players add #want zx.meta 120
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.mp_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/tool/mana_pump/apply_mana
