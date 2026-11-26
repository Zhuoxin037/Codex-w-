$data modify storage zx:sweep current set from storage zx:sweep casts."$(u0)_$(u1)_$(u2)_$(u3)"
# 【老施法记录兜底】hand 这个字段是 2026-10-03 加副手支持时才有的。
#   存档里可能还留着没有它的记录(正常情况 /reload 时 sweep/load 会把这些
#   施法取消掉, 但别指望这个)。缺字段会让下游的宏函数因为"变量没提供"
#   整支不跑 —— 所以在读出来的地方就地补一个默认值。
#   必须先 `if data current` 再判: 否则记录根本不存在时, 这句会顺手把
#   current 建出来, 让调用方"施法记录是否存在"的判断全部失效。
execute if data storage zx:sweep current unless data storage zx:sweep current.hand run data modify storage zx:sweep current.hand set value "weapon.mainhand"
