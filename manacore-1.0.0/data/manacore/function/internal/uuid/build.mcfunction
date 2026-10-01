# ============================================================
# internal/uuid/build —— 整数 -> 玩家键(uuid)
# ------------------------------------------------------------
# 【输入】manacore:work a.u0 .. a.u3(玩家 UUID 的 4 个 32 位整数)
# 【输出】manacore:work a.hex(32 位十六进制) 与 a.uuid(直接用 hex 当键)
# 【★ 为什么不再拼连字符 ★】上一版用"宏拼 8-4-4-4-12"的写法, 实测那一步没生效
#   (探针显示 hex 和切段都对、最终 uuid 却是空)。而 uuid 这个串在本包里只当
#   **存储键**用, 不需要连字符 —— 那就直接拿 32 位 hex 当键, 少一层宏少一个坑。
# 【老数据怎么办】老键是残缺的 8 位(= hex 前 8 位), 单独由 migrate 迁过来。
# 【性能】只在玩家上线时跑一次。
# ============================================================
data modify storage manacore:work a.hex set value ""

data modify storage manacore:work a.value set from storage manacore:work a.u0
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8
data modify storage manacore:work a.value set from storage manacore:work a.u1
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8
data modify storage manacore:work a.value set from storage manacore:work a.u2
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8
data modify storage manacore:work a.value set from storage manacore:work a.u3
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8

# 键 = 32 位 hex(不用宏、不拼连字符)
execute if data storage manacore:work a.hex run data modify storage manacore:work a.uuid set from storage manacore:work a.hex

# 老键(前 8 位)迁移: 先切出 h0, 再交给 migrate 宏
execute if data storage manacore:work a.hex run data modify storage manacore:work a.h0 set string storage manacore:work a.hex 0 8
execute if data storage manacore:work a.h0 run function manacore:internal/uuid/migrate with storage manacore:work a