# ============================================================
# test:internal/summon_named_stand —— 备份盔甲架(自愈 + 跟随)
# ------------------------------------------------------------
# 【宏参数】test:work a {uuid}
# 【调用】function test:internal/summon_named_stand with storage test:work a
# 【规则】
#   ① 找得到 -> 挪到脚边(保持加载) + 丢失计数清零
#   ② 找不到 -> 丢失计数 +1
#   ③ 连续丢失满 40 tick(约 2 秒)才真的补建一个
# 【为什么不能"一丢就建"】
#   刚进世界那一两 tick, 服务端还在异步加载区块, 旧架子还没被算进实体列表
#   —— 选择器看不到它。如果这时候立刻补建, 每登录一次就会多一个,
#   多几个取决于加载快慢, 表现就是"进一次游戏多一个盔甲架"。
#   加一道"连续丢失"的门槛, 就能把这种瞬时误判过滤掉;
#   而架子真的被摧毁时, 2 秒后照样会长回来。
# 【想调快/调慢】改下面 matches 后面的 40(单位 tick, 20 = 1 秒):
#   调小 = 重生更快但更容易被登录瞬间误判; 调大 = 更保险但重生更慢。
# 【为什么别用 ~ -80 ~ 把它藏到地下】
#   世界最低点是 -64(下界是 0), 低于它会被虚空销毁, 而 Invulnerable
#   挡不住虚空伤害。一旦掉出去, 自愈逻辑就会每 tick 重造一个 -> 实体爆炸。
#   想让它不碍眼, 在 NBT 里加 Invisible:1b(看不见但还在), 别往下塞。
# 【字段】CustomName 显示你的 UUID; Tags 用来选中它; Invulnerable 免伤。
# ============================================================

# ① 找得到: 挪到脚边 + 丢失计数清零
$execute if entity @e[tag=test_stand_$(uuid)] run tp @e[tag=test_stand_$(uuid)] ~ ~ ~
$execute if entity @e[tag=test_stand_$(uuid)] run scoreboard players set #stand_miss test.meta 0

# ② 找不到: 计数 +1(先别急着建)
$execute unless entity @e[tag=test_stand_$(uuid)] run scoreboard players add #stand_miss test.meta 1

# ③ 连续丢失满 40 tick 才补建, 建完把计数归零
$execute unless entity @e[tag=test_stand_$(uuid)] if score #stand_miss test.meta matches 40.. run summon armor_stand ~ ~ ~ {CustomName:"$(uuid)",CustomNameVisible:1b,Tags:["test_stand_$(uuid)"],Invulnerable:1b}
$execute unless entity @e[tag=test_stand_$(uuid)] if score #stand_miss test.meta matches 40.. run scoreboard players set #stand_miss test.meta 0
