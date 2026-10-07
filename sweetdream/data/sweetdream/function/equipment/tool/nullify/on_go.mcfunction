# ============================================================
# sweetdream:equipment/tool/nullify/on_go —— 无效: 宏部分(按 uuid 拼路径)
# ------------------------------------------------------------
# 【宏参数】zx:work nf.uu = 玩家自己的 uuid 文本(lib/uuid 取)
# 【执行者】玩家本人   【读】#nf_on zx.meta = 副手拿没拿「无效」(on_second 判好的)
# 【② 给加成, 条件三段】
#   · form_mark."$(uu)" 在   = 刚刚召唤过一个术阵(见 on_create)
#   · #nf_on = 1             = 副手正持「无效」
#   · zx.mm_add 还不到 1     = "不可叠加"(照 armor/lethe_shore/set_bonus 的定式)
# 【③ 标记用完即清, 无论有没有给成】
#   · 没拿「无效」-> 这份标记本就不该兑现, 留着会在下次拿上时凭空生效;
#   · 已有一份加成 -> 文案写"不可叠加", 这次就该作废。
# 【加成为什么落在 zx.mm_add】全包通用的「最大魔力值技能倍率」加成槽
#   (风行「风声」/ 套装「忘川彼岸」也用它) —— 2026-10-07 用户定稿: 原来那个
#   zx:data wg_bonus + lib/max_mana_bonus 的一次性槽位整体去掉, 加成直接进
#   通用乘区(lib/mm_add/hook_calc), 打出一次最大魔力值技能时清零。
#   ★ 加成存在玩家**自己的**计分项上, 所以这里用 @s 就行。
# ============================================================

# ① 先把 zx.mm_add 建出来 —— 计分板"没分数"不等于 0, 没有分数的玩家下面对不上
scoreboard players add @s zx.mm_add 0

# ② "这一份该兑现吗" -> #nf_free(1 = 兑现)
scoreboard players set #nf_free zx.meta 0
$execute if data storage zx:data form_mark."$(uu)" if score #nf_on zx.meta matches 1 unless score @s zx.mm_add matches 1.. run scoreboard players set #nf_free zx.meta 1

# ③ 兑现: +20 点(没有倒计时 —— 打出一次最大魔力值技能后清零)
execute if score #nf_free zx.meta matches 1 run scoreboard players set @s zx.mm_add 20

$execute if data storage zx:data form_mark."$(uu)" run data remove storage zx:data form_mark."$(uu)"
