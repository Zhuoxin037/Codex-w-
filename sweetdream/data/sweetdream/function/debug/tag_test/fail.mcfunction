# 失败详情同时写入存储和单人聊天，便于复查。
scoreboard players add #tag_fail zx.meta 1
$data modify storage zx:tag_test failures append value "$(case)"
$tellraw @a {text:"[标签自检 FAIL] $(case)",color:"red"}
