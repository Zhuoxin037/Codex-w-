# ============================================================
# test:internal/summon_named_stand —— 按 UUID 命名的盔甲架(查重 + 召唤)
# ------------------------------------------------------------
# 【宏参数】test:work a {uuid}
# 【调用】function test:internal/summon_named_stand with storage test:work a
# 【这一行同时做了两件事】
#   execute unless entity @e[tag=test_stand_<uuid>]
#       —— 已经有一个属于自己的盔甲架了就跳过, 不会越召越多
#   run summon armor_stand ~ ~ ~ {...}
#       —— 在原地召唤, 各字段含义:
#          CustomName        : 名字。1.20.5+ 的 SNBT 里, 不以 { 或 [ 开头的
#                              字符串按"字面文本"处理, 所以直接写就行
#          CustomNameVisible : 1b = 名字一直显示
#          Tags              : 把 UUID 也写进标签。之后查重、选中它都靠这个,
#                              比用 CustomName 去匹配又快又稳
#          Invulnerable      : 1b = 免伤(打不掉)
# 【想隐藏本体】在 NBT 里再加 Invisible:1b 即可。
# 【宏规则】只有含 $(变量) 的行才能以 $ 开头; 没有变量的行加了 $ 会报
#          "Macro without variables", 整个函数作废。
# 【注意】本函数是宏函数, 必须用 "with storage ..." 调用。
#   直接 /function test:internal/summon_named_stand 会因为拿不到参数而失败。
# 【如果名字显示成 json 原文】说明你这个版本的 SNBT 按字面文本处理字符串,
#   那就把下面那行换成再下面注释里的 JSON 写法。
# ============================================================

$execute unless entity @e[tag=test_stand_$(uuid)] run summon armor_stand ~ ~ ~ {CustomName:"$(uuid)",CustomNameVisible:1b,Tags:["test_stand_$(uuid)"],Invulnerable:1b}

# 备用(JSON 组件写法): 上面那行如果名字显示不对, 就启用这一行、注释掉上面那行
# $execute unless entity @e[tag=test_stand_$(uuid)] run summon armor_stand ~ ~ ~ {CustomName:'{"text":"$(uuid)"}',CustomNameVisible:1b,Tags:["test_stand_$(uuid)"],Invulnerable:1b}
