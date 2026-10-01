# @s = 测试生物，参数是手工期望值；验证真实引擎执行后的实体。
function sweetdream:tag/identity
$data modify storage zx:tag owner.expected set value $(expected)
$data modify storage zx:tag owner.count set value $(count)
$data modify storage zx:tag owner.glyphs set value $(glyphs)
$data modify storage zx:tag owner.case set value "$(case)"
function sweetdream:debug/tag_test/check_go with storage zx:tag owner
