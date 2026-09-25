# ============================================================
# debug/validate —— 数据完整性自检(以玩家身份执行)
# ------------------------------------------------------------
# 【用法】/function manacore:debug/validate
# 【检查】① 索引与玩家数据是否对得上(会顺手清理脏索引)
#         ② 是否缺少 stats 字段 / 术阵结构是否被破坏
#         ③ 是否出现 current_mana > max_mana
#         ④ 全局: 槽位是否回绕过、#next_slot 是否越界、用掉了多少槽
# 【输出】逐条 tellraw 警告 + 最后的"警告数 N"
# 【定位思路】警告数为 0 说明结构健康; 有警告会直接打印出问题玩家的 UUID,
#   拿着 UUID 去 /function manacore:debug/dump 就能看到细节。
# ============================================================
scoreboard players set #warn manacore.math 0
scoreboard players set #mode manacore.meta 6
function manacore:internal/debug/validate_start
function manacore:internal/debug/validate_globals
execute store result storage manacore:out r.warn int 1 run scoreboard players get #warn manacore.math
tellraw @s [{"text":"[ManaCore] 校验完成, 警告数: ","color":"aqua"},{"score":{"name":"#warn","objective":"manacore.math"}}]
