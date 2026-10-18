# ============================================================
# sweetdream:equipment/tool/look/cooldown_get —— 查"主手那把武器"的剩余冷却
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {uuid, skill}
#   由 look/render_go 从"主手物品的 custom_data.skill"读出来再传进来。
# 【为什么要单独一个宏函数】冷却的路径是动态的:
#     players."<uuid>".cooldowns."<技能id>".end
#   而宏变量在"调用那一刻"就固定了。所以必须等读到技能 id 之后,
#   再调一次带宏的函数, 才能把技能 id 拼进路径里。
#
# 【出参】一位小数(2026-10-18 改)
#     #v_cdi zx.meta = 剩余秒的整数位(0,1,2...)
#     #v_cdd zx.meta = 十分位(0..9)
#   没在冷却时两者都是 0 ⇒ 面板显示 "0.0s"。
#
# 【★ 为什么从"整数秒"改成"一位小数"★】
#   用户反馈"观测镜的 CD 得 1 秒左右才换一次"。旧版把剩余 tick 折成整数秒,
#   于是 20 刻里数字只跳一次 —— 明明每刻都在重算, 看起来却像卡住。
#   1 tick = 0.05 秒 ⇒ 剩余 tick / 2 就是 0.1 秒单位, 每 2 刻跳一次,
#   既够平滑, 又不至于抖成一位数乱跳。
#
# 【★ 取整方向统一为"向下"★】
#   整数位与十分位必须来自**同一个**中间量(#v_cs), 否则会出现
#   "整数秒向上取整 30" + "十分位算出 29.5" 这种自相矛盾的组合。
#   统一向下: 剩 1 刻(0.05 秒)时显示 0.0, 但那时冷却其实已结束
#   (前置包会把 end 那条路径删掉, data get 读不到 ⇒ #v_end 归 0 ⇒ 仍是 0.0),
#   所以"显示 0.0" 就等于"可用", 口径一致。
#
# 【为什么用自己包的 #tps / #two / #ten】
#   不用前置包的 #interval —— 那个是"回魔间隔", 数值碰巧也是 20;
#   哪天把回魔间隔改成 10, 借它算冷却就会把秒数显示成 2 倍。
# ============================================================

# 没在冷却时这条路径不存在, data get 会失败 -> 计分项保留旧值。
# 所以先手动归零, 再尝试覆盖。
scoreboard players set #v_end zx.meta 0
$execute store result score #v_end zx.meta run data get storage manacore:players "$(uuid)".cooldowns."$(skill)".end

# 剩余 tick = 结束刻 - 当前刻, 负数当 0
scoreboard players operation #v_cdn zx.meta = #v_end zx.meta
scoreboard players operation #v_cdn zx.meta -= #now manacore.meta
execute if score #v_cdn zx.meta matches ..0 run scoreboard players set #v_cdn zx.meta 0

# tick -> 0.1 秒单位: n / 2(计分板的整数除法就是向下取整)
scoreboard players operation #v_cs zx.meta = #v_cdn zx.meta
scoreboard players operation #v_cs zx.meta /= #two zx.meta

# 拆位: 整数位 = cs / 10; 十分位 = cs - 整数位 × 10
#   #v_tt 只是乘法用的中转, 每轮都会被重新覆盖, 不必清。
scoreboard players operation #v_cdi zx.meta = #v_cs zx.meta
scoreboard players operation #v_cdi zx.meta /= #ten zx.meta
scoreboard players operation #v_tt zx.meta = #v_cdi zx.meta
scoreboard players operation #v_tt zx.meta *= #ten zx.meta
scoreboard players operation #v_cdd zx.meta = #v_cs zx.meta
scoreboard players operation #v_cdd zx.meta -= #v_tt zx.meta
