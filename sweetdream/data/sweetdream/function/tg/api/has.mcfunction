# ============================================================
# sweetdream:tg/api/has —— 主手物品是否**同时含**给定的一组标签
# ------------------------------------------------------------
# 【入参】storage zx:work q{snbt:"[\"dash\",\"attract\"]"}   (SNBT 列表**字符串**)
#           ★ snbt 存的是"文本", 本函数用宏把这段文本原样展开进谓词。
#             写 ["dash"] 这种单标签也可以; 空列表 [] 恒真(谓词退化成"含任意").
# 【出参】storage zx:out ok = 1b / 0b
# 【用法(地图判"手上是不是位移+吸引")】
#     data modify storage zx:work q set value {snbt:"[\"dash\",\"attract\"]"}
#     function sweetdream:tg/api/has with storage zx:work q
#     execute if data storage zx:out{ok:1b} run ...
# 【为什么是"同时含"(all)】谓词的列表匹配 = 包含语义(不要求顺序/长度)。
#   要"任意一个(any)"就分多次调用(或用 `tg/api/ids` 拼)。
# ============================================================
data modify storage zx:out ok set value 0b
$execute if items entity @s weapon.mainhand *[minecraft:custom_data~{tags:$(snbt)}] run data modify storage zx:out ok set value 1b
