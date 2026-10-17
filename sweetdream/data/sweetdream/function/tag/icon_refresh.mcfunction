# 状态 -> 位掩码 -> 一个图标行。没有改变的文字不重复发送到客户端。
# ------------------------------------------------------------
# 【掩码是"两段拼起来"的】(2026-10-06 加淡出位)
#   位 0..4 = 五个标签在不在(渊海1 流火2 夜火4 噬心8 白昼梦16)
#   位 5..9 = 该标签**剩余 ≤3 秒**(渊海32 流火64 夜火128 噬心256 白昼梦512)
#   两段合起来当"文字指纹": icon_sync 只在掩码变化时才重渲染 —— 于是
#   "某个标签跨进 ≤3 秒"(要换成淡色字形)也会被当成一次变化, 自动重渲染。
#   ★ 淡出位一定与"在不在"一起出现, 所以 `matches 1..`(= 有图标) / `matches 0`
#     (= 没图标) 这两处判据不受影响。
#   ★ "没分数" ≠ 0: `if score @s zx.tt.x matches ..3` 在**没有这条分数**时直接失败
#     (不是按 0 算) -> 旧存档里没分数的老标签这一帧不会变淡; 下一秒 tag/ttl_tick 会
#     兜底补上分数, 之后就正常了。
execute unless entity @s[tag=zx.tags_v2] run function sweetdream:tag/migrate
function sweetdream:tag/identity
scoreboard players set #tag_mask zx.meta 0
execute if entity @s[tag=zx.status.yuanhai] run scoreboard players add #tag_mask zx.meta 1
execute if entity @s[tag=zx.status.liuhuo] run scoreboard players add #tag_mask zx.meta 2
execute if entity @s[tag=zx.status.yehuo] run scoreboard players add #tag_mask zx.meta 4
execute if entity @s[tag=zx.status.shixin] run scoreboard players add #tag_mask zx.meta 8
execute if entity @s[tag=zx.status.dream] run scoreboard players add #tag_mask zx.meta 16
# 淡出位: 剩余 ≤3 秒 -> icon_render 会用淡色字形(U+E005..E009)
execute if entity @s[tag=zx.status.yuanhai] if score @s zx.tt.yuanhai matches ..3 run scoreboard players add #tag_mask zx.meta 32
execute if entity @s[tag=zx.status.liuhuo] if score @s zx.tt.liuhuo matches ..3 run scoreboard players add #tag_mask zx.meta 64
execute if entity @s[tag=zx.status.yehuo] if score @s zx.tt.yehuo matches ..3 run scoreboard players add #tag_mask zx.meta 128
execute if entity @s[tag=zx.status.shixin] if score @s zx.tt.shixin matches ..3 run scoreboard players add #tag_mask zx.meta 256
execute if entity @s[tag=zx.status.dream] if score @s zx.tt.dream matches ..3 run scoreboard players add #tag_mask zx.meta 512
# 并入专属状态位，公共标签消失时仍保留其他有效状态。
function sweetdream:tag/custom_mask
scoreboard players operation #tag_mask zx.meta += #tag_extra zx.meta
# 正在死亡的生物不继续显示；不能以仍存在实体就认定它还活着。
execute if data entity @s {Health:0.0f} run scoreboard players set #tag_mask zx.meta 0
execute store result storage zx:tag owner.mask int 1 run scoreboard players get #tag_mask zx.meta
execute if score #tag_mask zx.meta matches 1.. run tag @s add zx.tagged
execute if score #tag_mask zx.meta matches 1.. run function sweetdream:tag/icon_sync with storage zx:tag owner
execute if score #tag_mask zx.meta matches 0 run function sweetdream:tag/icon_kill with storage zx:tag owner
execute if score #tag_mask zx.meta matches 0 run tag @s remove zx.tagged
