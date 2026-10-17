# @s 仍是生物。只有 mask 改变或新建显示实体时才拼接文字。
# fallback 让非中英文客户端也能使用这套字体；顺序固定、没有空槽。
# ============================================================
# 【剩余 <= 3 秒 -> 换"淡色字形"】(2026-10-06 加)
#   每个标签在自己的 zx.tt.<mark> 上剩余秒数 <= 3 时用淡色字形(U+E005..E009)，
#   否则用普通字形(U+E000..U+E004)。淡色副本由 sweetdream_rp_完整版/tools/make_icons.py
#   与图集一起生成(降不透明度 + 轻微去饱和；形状与字宽完全不变，所以整排不跳动)。
# 【★ 为什么不能用 text_opacity ★】
#   它作用在整个 text_display 上 —— 一行最多 5 个图标，弄淡"刚到 3 秒的那个"
#   会把同排还早的图标一起弄淡。所以只能换字形(一个字形配一份"淡"副本)。
# 【★ 为什么"跨进 <= 3 秒"能触发重渲染 ★】
#   本文件只在 tag/icon_sync 发现掩码变化时才被调用；而掩码里带了"淡出位"
#   (32/64/128/256/512，见 tag/icon_refresh) —— 跨进 <= 3 秒就是一次状态变化。
#   两边的阈值与位值必须一致：check.py 规则 dimflag 盯着。
# 【★ "没分数" != 0 ★】`if score @s zx.tt.x matches ..3` 在这条分数**不存在**时
#   直接失败(不是按 0 算) -> 旧存档里没分数的老标签这一帧不变淡；
#   下一秒 tag/ttl_tick 会兜底补上分数，之后就正常了。
# 【本文件由 .workbuddy/_gen_tag_icons.py 生成】字形是私有区字符，手改容易丢字符；
#   要改结构请改生成器再重跑(make_icons.py 决定 U+E00x 的映射，两边顺序必须一致)。
# ============================================================
data modify storage zx:tag row set value {text:"",font:"sweetdream:icons",extra:[]}
execute if entity @s[tag=zx.status.yuanhai] if score @s zx.tt.yuanhai matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.dim.yuanhai","fallback":""}
execute if entity @s[tag=zx.status.yuanhai] unless score @s zx.tt.yuanhai matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.yuanhai","fallback":""}
execute if entity @s[tag=zx.status.liuhuo] if score @s zx.tt.liuhuo matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.dim.liuhuo","fallback":""}
execute if entity @s[tag=zx.status.liuhuo] unless score @s zx.tt.liuhuo matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.liuhuo","fallback":""}
execute if entity @s[tag=zx.status.yehuo] if score @s zx.tt.yehuo matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.dim.yehuo","fallback":""}
execute if entity @s[tag=zx.status.yehuo] unless score @s zx.tt.yehuo matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.yehuo","fallback":""}
execute if entity @s[tag=zx.status.shixin] if score @s zx.tt.shixin matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.dim.shixin","fallback":""}
execute if entity @s[tag=zx.status.shixin] unless score @s zx.tt.shixin matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.shixin","fallback":""}
execute if entity @s[tag=zx.status.dream] if score @s zx.tt.dream matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.dim.dream","fallback":""}
execute if entity @s[tag=zx.status.dream] unless score @s zx.tt.dream matches ..3 run data modify storage zx:tag row.extra append value {"translate":"sweetdream.icon.dream","fallback":""}
function sweetdream:tag/icon_render_custom
$data modify entity @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] text set from storage zx:tag row
$scoreboard players set @e[type=minecraft:text_display,tag=zx.icon_v2,tag=zx.owner_$(u0)_$(u1)_$(u2)_$(u3),limit=1] zx.icon_mask $(mask)
