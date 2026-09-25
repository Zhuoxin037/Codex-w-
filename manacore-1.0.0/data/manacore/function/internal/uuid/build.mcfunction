# ============================================================
# internal/uuid/build —— 整数 -> 标准 UUID 文本
# ------------------------------------------------------------
# 【输入】manacore:work a.u0 .. a.u3(玩家 UUID 的 4 个 32 位整数)
# 【输出】manacore:work a.hex(32 位十六进制) 与 a.uuid(标准 8-4-4-4-12)
# 【流程】对每个整数: 设 a.value -> nibbles 拆 8 个半字节 -> emit8 拼进 hex
# 【为什么不用位运算】见 nibbles 的注释: 计分板不支持 >> / & 。
# 【性能】只在玩家上线时跑一次, 约 1000 条命令, 完全可以接受。
# ============================================================
data modify storage manacore:work a.hex set value ""

# 第 1 个整数
data modify storage manacore:work a.value set from storage manacore:work a.u0
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8

# 第 2 个整数
data modify storage manacore:work a.value set from storage manacore:work a.u1
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8

# 第 3 个整数
data modify storage manacore:work a.value set from storage manacore:work a.u2
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8

# 第 4 个整数
data modify storage manacore:work a.value set from storage manacore:work a.u3
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8

# 按 8-4-4-4-12 插入连字符
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid set string storage manacore:work a.hex 0 8
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid append value "-"
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid append string storage manacore:work a.hex 8 12
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid append value "-"
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid append string storage manacore:work a.hex 12 16
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid append value "-"
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid append string storage manacore:work a.hex 16 20
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid append value "-"
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid append string storage manacore:work a.hex 20 32
