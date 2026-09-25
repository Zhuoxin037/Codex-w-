# ============================================================
# api/player/self_uuid —— 取"执行者自己"的 UUID(以玩家身份执行)
# ------------------------------------------------------------
# 【为什么需要】命令读不到玩家名字, UUID 也要自己算; 而这个计算只应该在
#   玩家上线时做一次。所以这里走的是"槽位索引反查", 成本极低。
# 【用法】
#   /execute as <玩家> run function manacore:api/player/self_uuid
#   /data get storage manacore:out r.uuid      -> 得到 UUID 文本
# 【出参】manacore:out.uuid(未注册完成时为空字符串)
# 【典型写法】(技能函数里最常用的 4 行)
#   function manacore:api/player/self_uuid
#   data modify storage manacore:in arg.uuid set from storage manacore:out r.uuid
#   ... 填其他参数 ...
#   function manacore:api/skill/cast
# 【前提】玩家需要已经完成注册(进服后约 1 秒)。未注册时 out.uuid 为空,
#   后续接口会安全地什么都不做(因为有 api/player/ensure 兜底)。
# ============================================================

# ① 读出自己的槽位号(分数不存在时会被建成 0, 不会报错)
execute store result storage manacore:work a.i int 1 run scoreboard players add @s manacore.slot 0

# ② 用槽位号在索引里反查 UUID
function manacore:internal/debug/self_uuid with storage manacore:work a

# ③ 输出(未注册时给空串, 方便调用方判断)
execute if data storage manacore:work a.uuid run data modify storage manacore:out r.uuid set from storage manacore:work a.uuid
execute unless data storage manacore:work a.uuid run data modify storage manacore:out r.uuid set value ""
