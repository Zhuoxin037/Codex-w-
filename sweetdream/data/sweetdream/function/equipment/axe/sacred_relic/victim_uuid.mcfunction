# @s = 生物。仅复用核心的纯转换函数, 绝不调用会迁移玩家记录的 uuid/build。
# 转换会用核心 work.a / macro.a, 必须完整备份并恢复。
data modify storage zx:sr backup.work set value {}
data modify storage zx:sr backup.macro set value {}
data modify storage zx:sr backup.work set from storage manacore:work a
data modify storage zx:sr backup.macro set from storage manacore:macro a
data modify storage manacore:work a set value {hex:"",value:0}
data modify storage manacore:work a.value set from entity @s UUID[0]
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8
data modify storage manacore:work a.value set from entity @s UUID[1]
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8
data modify storage manacore:work a.value set from entity @s UUID[2]
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8
data modify storage manacore:work a.value set from entity @s UUID[3]
function manacore:internal/uuid/nibbles
function manacore:internal/uuid/emit8
data modify storage zx:sr watch.h0 set string storage manacore:work a.hex 0 8
data modify storage zx:sr watch.h1 set string storage manacore:work a.hex 8 12
data modify storage zx:sr watch.h2 set string storage manacore:work a.hex 12 16
data modify storage zx:sr watch.h3 set string storage manacore:work a.hex 16 20
data modify storage zx:sr watch.h4 set string storage manacore:work a.hex 20 32
data modify storage manacore:work a set from storage zx:sr backup.work
data modify storage manacore:macro a set from storage zx:sr backup.macro
function sweetdream:equipment/axe/sacred_relic/uuid_join with storage zx:sr watch
