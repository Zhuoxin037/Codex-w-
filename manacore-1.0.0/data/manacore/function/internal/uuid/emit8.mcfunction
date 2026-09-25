# ------------------------------------------------------------
# internal/uuid/emit8 —— 把 work a.nib0..nib7 依次拼到 work a.hex 末尾
# 【流程】每拼一个字符: 刷新 prefix -> 取半字节值 -> 调 append
# 【注意】prefix 必须每次重新读, 因为 append 会更新 work a.hex。
# ------------------------------------------------------------
data modify storage manacore:macro a.prefix set from storage manacore:work a.hex
execute store result storage manacore:macro a.n int 1 run data get storage manacore:work a.nib0
function manacore:internal/uuid/append with storage manacore:macro a
data modify storage manacore:macro a.prefix set from storage manacore:work a.hex
execute store result storage manacore:macro a.n int 1 run data get storage manacore:work a.nib1
function manacore:internal/uuid/append with storage manacore:macro a
data modify storage manacore:macro a.prefix set from storage manacore:work a.hex
execute store result storage manacore:macro a.n int 1 run data get storage manacore:work a.nib2
function manacore:internal/uuid/append with storage manacore:macro a
data modify storage manacore:macro a.prefix set from storage manacore:work a.hex
execute store result storage manacore:macro a.n int 1 run data get storage manacore:work a.nib3
function manacore:internal/uuid/append with storage manacore:macro a
data modify storage manacore:macro a.prefix set from storage manacore:work a.hex
execute store result storage manacore:macro a.n int 1 run data get storage manacore:work a.nib4
function manacore:internal/uuid/append with storage manacore:macro a
data modify storage manacore:macro a.prefix set from storage manacore:work a.hex
execute store result storage manacore:macro a.n int 1 run data get storage manacore:work a.nib5
function manacore:internal/uuid/append with storage manacore:macro a
data modify storage manacore:macro a.prefix set from storage manacore:work a.hex
execute store result storage manacore:macro a.n int 1 run data get storage manacore:work a.nib6
function manacore:internal/uuid/append with storage manacore:macro a
data modify storage manacore:macro a.prefix set from storage manacore:work a.hex
execute store result storage manacore:macro a.n int 1 run data get storage manacore:work a.nib7
function manacore:internal/uuid/append with storage manacore:macro a
