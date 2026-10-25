# ============================================================
# sweetdream:equipment/sword/yebu/hit —— 曳步（铁剑 · 被动）
# ------------------------------------------------------------
# 【触发】玩家普攻命中（advancement player_hurt_entity，只认 is_player_attack）
# 【机制】命中的目标 缓慢Ⅰ 4 秒；若它此刻已经在缓慢中，则改给 缓慢Ⅱ 3 秒。
#         同一个目标 4 秒内最多被"升级"一次（防止连击把减速永久顶在 Ⅱ 级）。
# 【为什么不查 effect】命令没有"查询生物身上效果"的手段，所以用**到期刻**记账：
#   zx.yb  = 本件给它的缓慢到期刻（0 = 没记过账）
#   zx.ybu = 上次升级的刻 + 80（升级冷却）
#   到期刻天然自愈，不需要每刻递减 —— 不给生物写任何 NBT（坑 199 之后的对齐做法）。
# 【计分项落点】两个都落在 scoreboard.dat，不碰实体 NBT ⇒ 不会把 chunk 标脏
#   （2026-10-20 法球延迟那条坑的同一套结论）。
# ============================================================
advancement revoke @s only sweetdream:equipment/sword/yebu_hit

# 主手或副手持有曳步（铁剑）
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["yebu"]}] unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["yebu"]}] run return 0

# 【超限分流】(2026-10-23 批 K1) 主/副手是"超限·曳步"(ol:"yebu") -> slow 里走 ol_slow 那套
#   ★ 主副手都判、且必须判 ol 的**值**是不是 yebu: 只判 .ol 键在不在的话, 副手拿着
#     别的超限武器时会误走超限分支(照 liuguang/cast ⓪.5 的同一课)。
#   ★ 用 #yb_ol 这个 meta 分数把结论带给 slow(那边执行者已经换成生物了, 没法再看物品)。
scoreboard players set #yb_ol zx.meta 0
execute if items entity @s weapon.mainhand iron_sword[minecraft:custom_data~{zx:["yebu"],ol:"yebu"}] run scoreboard players set #yb_ol zx.meta 1
execute if items entity @s weapon.offhand iron_sword[minecraft:custom_data~{zx:["yebu"],ol:"yebu"}] run scoreboard players set #yb_ol zx.meta 1

# 取本次命中的生物（lib/victim 用 HurtTime 反查，不依赖进度上下文）
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=..16,limit=1] run return 0

execute as @e[tag=zx.victim,distance=..16,limit=1] run function sweetdream:equipment/sword/yebu/slow
tag @e[tag=zx.victim] remove zx.victim
