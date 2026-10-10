# ============================================================
# internal/session/tick_self —— 在线玩家每秒心跳(以 @s 执行)
# ------------------------------------------------------------
# 【★ F01 修(2026-10-10)】原写法是:
#     execute unless score @s manacore.beat >= #sec run function core/player/join
#   而 #sec 在 core/second 里**每秒 +1** ⇒ 注册完的下一秒 beat 又落后于 #sec
#   ⇒ **每个在线玩家每秒都重走一遍完整注册**(重算 UUID 约 700 条命令 + 重发
#   player_join)。这与 core/player/join 自己写的"只在玩家上线时跑一次"直接矛盾。
# 【新判据(两条互相独立, 任一成立才注册)】
#   ① @s manacore.gen < #gen   —— 本"注册代"还没注册过: 首次上线 / /reload 之后
#      (#gen 只在 core/boot 里 +1, 与秒号解耦, 所以不会每秒漂移)
#   ② 索引里的槽位不是自己      —— 重连后槽位被回收 / 被别人占用
#   两条都不成立 = 已有效注册 ⇒ 只更新心跳, 不做任何注册动作。
# 【为什么 ② 不能只看"槽位在不在"】槽位回收后会分给别人, 光判存在性会拿错 UUID,
#   所以必须逐 u0..u3 比身份(见 internal/session/verify)。
# 【成本】稳定态 = 每人每秒 4 条 data get + 1 次宏判定 ≈ 7 条命令(原来 ~700+)。
# 【以 @s 执行】由 core/second 用 execute as @a 调用。
# ============================================================

# ① 抄自己的身份(UUID 四个 int)与槽位号(分数不存在时 add 0 会建成分数, 不报错)
#   ★★ O02(2026-10-11, spark 剖析): `data get entity @s UUID[n]` 一次 = 把整个玩家
#   (54 格背包+组件+lore)完整序列化成 NBT —— 原来每人每秒 4 次, 纯为读自己 UUID。
#   UUID 是**终身不变**的 ⇒ 缓存进计分项 manacore.u0..u3(每人各一份, 首次读一次),
#   之后每秒只读计分板(免费)。存在性判定用全值域 matches(不存在的分数 matches
#   恒假 ⇒ unless 成立), 不能用 `add @s x 0` 建分(UUID 的 int 可能恰好是 0/负数,
#   add 建出来的 0 会把真值顶掉)。
execute unless score @s manacore.u0 matches -2147483648..2147483647 run function manacore:internal/uuid/collect_self
data modify storage manacore:work id set value {u0:0,u1:0,u2:0,u3:0,slot:0,i:0,ok:0b}
execute store result storage manacore:work id.u0 int 1 run scoreboard players get @s manacore.u0
execute store result storage manacore:work id.u1 int 1 run scoreboard players get @s manacore.u1
execute store result storage manacore:work id.u2 int 1 run scoreboard players get @s manacore.u2
execute store result storage manacore:work id.u3 int 1 run scoreboard players get @s manacore.u3
scoreboard players add @s manacore.slot 0
execute store result storage manacore:work id.slot int 1 run scoreboard players get @s manacore.slot
execute store result storage manacore:work id.i int 1 run scoreboard players get @s manacore.slot

# ② 判"索引里这个槽位还记不记得我"
function manacore:internal/session/verify with storage manacore:work id

# ③ 需要注册(首次上线 / 加载代际变化 / 槽位已被回收或占用) -> 走完整注册
execute unless score @s manacore.gen >= #gen manacore.meta run function manacore:core/player/join
execute unless data storage manacore:work id{ok:1b} run function manacore:core/player/join

# ④ 已有效注册 -> 只把心跳写进索引(离线检测靠它; 槽位不是自己时不写, 免得篡改别人的记录)
execute if data storage manacore:work id{ok:1b} run function manacore:internal/session/beat with storage manacore:work id

# ⑤ 心跳(计分板侧, 供自诊观察; 不参与任何判定)
scoreboard players operation @s manacore.beat = #sec manacore.meta
