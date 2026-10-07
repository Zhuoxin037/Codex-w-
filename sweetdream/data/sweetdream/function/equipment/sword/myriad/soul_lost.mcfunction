# ============================================================
# sweetdream:equipment/sword/myriad/soul_lost —— 手里没有这套武器了: 清「剑魂」
# ------------------------------------------------------------
# 【执行者】身上有剑魂的玩家(zx.mq_soul >= 1, 由 ol_second 每秒挑出来)
# 【文案】超限·千散: "…技能结束后清除（不包含本次技能积攒的"剑魂"），手持切换为
#         其它武器时一并清除。"(2026-10-08 用户定稿)
#
# 【★ 判据为什么写成"主手**和**副手都没有", 而不是"主手不是"★】
#   这套武器是**可以拿在副手放的** —— is_ol / special / 两把 cast 的换手判据
#   全都判了副手。如果只盯主手, 副手流派一按 F 换手(主手本来就握着别的东西)
#   就会被清空, 那是误伤。所以口径落成"**手里没有这套武器了**才清":
#     · 用户说的"切换主手"(把主手那把拿开/换成别的) -> 必然触发;
#     · 副手流派的正常使用                  -> 不受影响。
#
# 【和 soul_clear 的分工】别合并, 两件事结算方式不同:
#   · soul_clear  —— **按次**: 主动放一次技能, 扣掉"本次之前攒的那批"
#                     (文案括号里的"不包含本次技能积攒的")。
#   · soul_lost   —— **按持有状态**: 手上一旦没有这套武器, 全部清零。
#   合并写会让"放技能"和"换手"互相污染对方的规则。
#
# 【★ 为什么顺手把 zx.mq_base 也清零 ★】
#   mq_base 是 soul_clear 做减法的基准("技能开始前有几个")。剑魂都没了还留着旧基准,
#   下一次 soul_clear 就会减出一个负数(soul_clear 里有 matches ..0 的兜底, 结果是对的,
#   但留个负值基准属于脏状态 —— 清零更干净)。
# ============================================================

execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["myriad"]}] run return 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["qiansan"]}] run return 0
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["myriad"]}] run return 0
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["qiansan"]}] run return 0

scoreboard players set @s zx.mq_soul 0
scoreboard players set @s zx.mq_base 0

# 视觉同步: soul_fx 每刻按 zx.mq_soul 画圈, 归零后它自然停 —— 这里不用额外 kill 实体
# (剑魂本来就是计分项, 不是实体, 见 soul_gain 顶部注释)。
