# ============================================================
# sweetdream:lib/mark_consume —— 统一的"消耗一个通用标签"入口
# ------------------------------------------------------------
# 【入参】zx:work a = {target:"选择器", mark:"yuanhai|liuhuo|yehuo|shixin|dream"
#                      [, by:"消耗者选择器"]}
#   · target : 谁身上的标签被消耗（可以是范围选择器）
#   · mark   : 五个通用标签的英文名之一
#   · by     : 谁"消耗"的 —— 判「永恒」要用它（省略 / 空串 = @s，即调用者本人）
#     ★ 虹彩(漫彩吞噬) / 清醒梦(消耗白昼梦) 是"**目标生物身上**的标签被吞"，
#       但消耗者其实是**放了那个技能的玩家** —— 调用点先用 lib/find_by 反查出
#       施法者并打 zx.mc_by 标签，再传 by:"@a[tag=zx.mc_by,limit=1]"。
# 【做什么（顺序不能换）】
#   ① 目标身上真有这个标签吗？没有 -> 直接收工（不白扣蓝、不白给余烬）
#   ② 消耗者穿「永恒」且魔力 > 50 -> 扣 50 魔力 + 原地刷新标签（= "再次附着"）。
#      标签不消失，也 **不算被消耗**（余烬那次被动不给）。
#   ③ 否则真摘掉（走 tag/unmark，图标/租约一起收）
#   ④ 真摘掉时，若**调用点的 @s**（原执行者）穿「余烬」：
#      流火回 50 魔力 + 力量Ⅱ / 夜火回 100 魔力 + 力量Ⅴ
#      ★ 余烬只认 @s、不认 by —— 生物不会穿余烬，所以"目标身上的标签被吞"
#        这类消耗天生拿不到这份被动（和旧行为一致）。
# 【为什么要有这一层】以前各武器"摘标签"直接调 tag/unmark，装备被动（余烬 / 永恒）
#   就不知道谁被消耗了。所有会消耗通用标签的技能现在都改成调这里：
#     data modify storage zx:work a set value {target:"...",mark:"yehuo"}
#     function sweetdream:lib/mark_consume
# 【★ 转换类的消耗**不走**这里 ★】热熔(流火→夜火)、余烬(流火→夜火) 是**替换**
#   而不是消耗 —— 走这里的话，穿永恒会把流火"补回来"，变成"流火+夜火"双状态
#   （2026-10-04 记过的刷魔力漏洞）。那两处保持直调 tag/unmark。
# 【★ 本文件不是宏函数 ★】"目标身上有没有某个标签"只能写成 @s[tag=zx.status.$(mark)]
#   （要拼字符串 = 必须宏），所以那一段拆进了同目录的 lib/mark_check。
#   调用点写法不变（function sweetdream:lib/mark_consume，不带参数）。
# ============================================================

# ① 归一化 by（省略或空串 -> 调用者本人）
execute unless data storage zx:work a.by run data modify storage zx:work a.by set value "@s"
execute if data storage zx:work a{by:""} run data modify storage zx:work a.by set value "@s"

# ② 冻结到本轮专用节点 zx:work mc
#    （zx:work a 是全包共用的，下面还要调别的函数，别让它们把参数冲掉）
data modify storage zx:work mc set value {target:"",mark:"",by:"",ok:0b,done:0b}
data modify storage zx:work mc.target set from storage zx:work a.target
data modify storage zx:work mc.mark set from storage zx:work a.mark
data modify storage zx:work mc.by set from storage zx:work a.by

# ③ 判目标带没带标签 -> lib/mark_check（宏: 要拼 zx.status.$(mark)）
function sweetdream:lib/mark_check with storage zx:work mc
