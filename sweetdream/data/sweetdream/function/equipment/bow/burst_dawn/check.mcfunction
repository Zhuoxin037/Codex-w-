# ============================================================
# sweetdream:equipment/bow/burst_dawn/check —— 每秒: 影是不是都散了?
# ------------------------------------------------------------
# 【谁调它】lib/second: execute as @a[scores={zx.bd_on=1..}] at @s run ...
# 【执行者】射手(玩家); 只对"技能进行中"(zx.bd_on=1)的玩家跑, 没放技能时开销为零
# 【为什么要有这一层】ammo 只在"自己吃掉最后一只"时收尾; 影还可能**被怪打死**
#   或**自然到期**, 那两条路没有人在场宣布结束。每秒扫一次就能把三种途径都兜住
#   (坑 107: 玩家级单标量存不了"还有几只", 所以这里是**当场数实体**)。
# 【换维度 / 下线】计数带 `at @s` 的位置基准, 只数玩家**当前所在维度**的影 ——
#   换维度后数到 0, 技能就地收尾, 符合直觉。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work bdc.uu set from storage zx:data self.uuid
function sweetdream:equipment/bow/burst_dawn/check_one with storage zx:work bdc
