# ============================================================
# internal/session/tick_self —— 在线玩家每秒心跳 + 续期注册(以 @s 执行)
# ------------------------------------------------------------
# 【设计目标】完全不用"实体身份选择器"。
#   原方案用 @s[nbt={UUID:[I;u0,u1,u2,u3]}] 判断"这个实体是不是这个人",
#   但那需要把数值放进宏占位符, 属于加载期高风险写法。
#   现在改用"每秒心跳秒号":
#     · 玩家上线/重载后, 自己的 manacore.beat 分数一定小于 #sec
#       -> 触发一次完整注册(重算 UUID, 保证身份正确)
#     · 注册完成后把 @s 的 beat 与 index."<槽位>".beat 都写成当前 #sec
#     · 遍历索引时, 谁的 beat 小于 #sec 就判定为已离线
#   同一套标记同时解决"是否需要注册"和"是否还在线"两个问题。
# 【#sec】由 core/second 每秒 +1 的秒计数器(objective: manacore.meta)。
# 【以 @s 执行】由 core/second 用 execute as @a 调用。
# ============================================================

# ① 本秒还没注册(新上线 / reload 之后) -> 走完整注册流程
execute unless score @s manacore.beat >= #sec manacore.meta run function manacore:core/player/join

# ② 打心跳: 计分板侧(自己的会话标记)
scoreboard players operation @s manacore.beat = #sec manacore.meta

# ③ 打心跳: 索引侧(供离线检测读取)
scoreboard players add @s manacore.slot 0
execute store result storage manacore:work a.i int 1 run scoreboard players get @s manacore.slot
function manacore:internal/session/beat with storage manacore:work a
