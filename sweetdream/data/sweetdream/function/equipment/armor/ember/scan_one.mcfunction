# ============================================================
# sweetdream:equipment/armor/ember/scan_one —— 余烬·燃烧边沿检测(高频版)
# ------------------------------------------------------------
# 【谁调用它】core/tick 每 5 刻一次(见那里 #em_t 的取模分频), 只对带
#   zx.em_on 的玩家跑(zx.em_on 由 second_one 每秒维护)。
# 【执行者】玩家   【执行位置】玩家脚下
# 【★ 为什么从"每秒"挪到"每 5 刻" ★】(2026-10-12 用户: "每次燃烧结束都不能
#   及时上流火/夜火" —— 拍板"更密集的周期")
#   原实现挂在 #manacore:event/second(20 刻一次) 做**边沿检测**: 火熄灭的
#   那一刻不结算, 要等下一次心跳才被"上一轮有标记、这一轮 Fire=0"发现
#   ⇒ 延迟 0~1 秒、平均 0.5 秒。改成 5 刻一次后延迟 0~0.25 秒、平均 0.125 秒。
#   【留在每秒的】①认装备 ②魔力上限 +240 差值账本 —— 它们是账本不是手感,
#     高频跑纯属浪费(见 second_one 顶部)。
# 【边沿检测三步】zx.em_burn = "上一次扫描时还在燃烧"的标记:
#   ④ 对带标记的目标读 Fire, =0 才算"刚刚熄灭" -> burned_out 结算;
#   ⑤ 清掉本轮范围内的标记;
#   ⑥ 给当前还在燃烧的重新打标记, 供下一次扫描做边沿。
#   不扫描/不清除远处目标的标记: 多人同时穿余烬时, 远处标记可能还需要
#   另一个玩家处理, 全局清掉会漏触发。
# 【⚠️ 两个固有边界(提速也改不掉, 只是窗口从 20 刻缩到 5 刻)】
#   · 范围只 9 格(以玩家为中心; 用 hit_scan_exclude 排除, 不用 no_damage ——
#     no_damage 会把盔甲架/训练人偶也排掉, 结果"人偶明明在烧却看不到")。
#   · 一次燃烧若**整个**落在两次扫描之间(不足 5 刻, 例如刚点着就被水浇灭),
#     从没被 watch 抓到过 Fire>=1 ⇒ 余烬一次都不会触发。
#     ★ 焚舟点火那条路径不受影响: immolate/ignite 当场就给目标打 zx.em_burn。
# ============================================================

# ⓪ 扫描次数锚 —— 每进一次就 +1(不管有没有看到燃烧的东西)。
#   排查"余烬还是不触发"时先看它: **不涨** = 高频扫描压根没跑(检查
#   zx.em_on 标签 / core/tick 那段分频); **在涨** = 扫描正常, 问题在别的环节。
#   debug/ember_immolate 会把它打出来。
scoreboard players add @s zx.em_scan 1

# ④ 旧标记里, 已经不再燃烧的 -> 流火/夜火
scoreboard players set #em_conv zx.meta 0
execute as @e[type=!#sweetdream:hit_scan_exclude,tag=zx.em_burn,distance=..9] at @s run function sweetdream:equipment/armor/ember/burned_out
scoreboard players operation @s zx.em_conv += #em_conv zx.meta

# ⑤ 清掉本轮范围内的旧标记(远处不清, 见顶部注释)
tag @e[type=!#sweetdream:hit_scan_exclude,tag=zx.em_burn,distance=..9] remove zx.em_burn

# ⑥ 当前还在燃烧的, 打上标记, 给下一次扫描做边沿检测
#   zx.em_seen 是**累计**计数(不是"当前几只"): 每扫一次、每看到一只燃烧的
#   就 +1 —— 所以周期从 20 刻改成 5 刻后, 这个数的增速约为原来的 4 倍,
#   这是正常的(它数的是"扫描命中次数"), 不是 bug。
scoreboard players set #em_seen zx.meta 0
execute as @e[type=!#sweetdream:hit_scan_exclude,distance=..9] at @s run function sweetdream:equipment/armor/ember/watch
scoreboard players operation @s zx.em_seen += #em_seen zx.meta
