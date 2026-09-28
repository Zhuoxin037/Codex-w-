# ============================================================
# sweetdream:tag/icon_spawn —— 生成图标显示实体
# ------------------------------------------------------------
# 【宏参数】zx:work ic {id, key}   【执行者】被标记的生物
# 【用什么】minecraft:text_display —— 专门显示文字/图标的实体, 没有碰撞箱。
# 【显示的就是"图标"】text 里用的是**翻译键** sweetdream.icon.xxx,
#   真正的图标字符和贴图都在资源包里(sweetdream_rp):
#     font/icons.json  把 U+E000..U+E004 指向 icons.png 的 5 格
#     lang/*.json      把 sweetdream.icon.xxx 映射到对应字符
#   这样数据包文本里一个私用字符都不用写, 干净很多。
# 【几个字段的意思】
#   billboard:"center"  永远正对玩家(图标始终可读)
#   see_through:1b      被方块挡住也能看到(想要"藏起来"就改 0b)
#   background:0 / default_background:0b   去掉文字默认的深色底框
#   transformation.scale 图标大小(现在是 0.4; 嫌大嫌小改这个数)
# 【★ 为什么没有 teleport_duration ★】
#   上一版写了 teleport_duration:20(1 秒插值), 结果图标永远在慢慢"追"生物 ——
#   看着就是"吊在它身后", 很违和。现在改成每 tick 直接摆位置 + 不插值, 精确贴合。
# 【为什么给图标也写 zx.icon_id】只是方便调试/排查(回收已经不靠它了)。
# ============================================================

$execute at @s anchored eyes run summon minecraft:text_display ~ ~1.0 ~ {Tags:["zx.icon","zx.icon_$(id)"],billboard:"center",see_through:1b,shadow:1b,background:0,default_background:0b,transformation:{translation:[0.0f,0.0f,0.0f],scale:[0.4f,0.4f,0.4f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]},text:{translate:"$(key)",font:"sweetdream:icons"}}
$scoreboard players set @e[tag=zx.icon_$(id),limit=1] zx.icon_id $(id)
