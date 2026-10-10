# ============================================================
# sweetdream:internal/damage/calc_as_owner —— 以"释放者本人"的身份算伤害(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work co 之类的**独立节点** {u0,u1,u2,u3}
#   (u0..u3 = 释放者 uuid 的 4 个 int; 用独立节点是为了不污染调用方要用的 zx:work a)
# 【入参另外需要】manacore:in arg 已装好本次要算的东西(uuid / 各倍率…)
# 【做什么】把 manacore:api/damage/calc 的执行者换成**释放者玩家本人**
# 【★★ 为什么必须换执行者(2026-10-10, 修 F13)★★】
#   召唤物(法球 marker / 海棠漩涡 item_display / 色彩 item_display)算伤害时,
#   执行者是**召唤物自己**。而 #manacore:event/damage_calc 里的加算 hook
#   (愿景升级增伤 / 共振 / 漫步冥河 / 桂冠 / 炽天使…)第一行几乎都是
#       `execute unless entity @s[type=minecraft:player] run return 0`
#   —— 召唤物不是玩家 ⇒ 这些 hook 全被跳过 ⇒ **召唤物伤害吃不到主人的装备加成**。
#   面板基数(按 uuid 查到的最大魔力)读得到, 主人当前的装备加成却读不到 ——
#   两种上下文不一致, 正是报告 F13 记的现象。
# 【为什么按 uuid 反查玩家】选择器里写不下 uuid 文本, 但玩家记录存了 uuid 的
#   4 个 int, `@a[nbt={UUID:[I;a,b,c,d]},limit=1]` 能精确定位那个人(同 stg_mul)。
# 【找不到人怎么办】玩家离线时退回"当前执行者(召唤物)"身份再算一遍 ——
#   至少面板基数还算得出来, 行为与修之前一致, 不会因为主人掉线而打不出伤害。
# 【位置上下文】calc 只读面板 + uuid, 不看坐标 ⇒ 不需要保留召唤物的位置。
# 【副作用】事件里的 hook 会写加算池 / 快照等 —— 都无位置依赖, 换身份安全。
# ============================================================

# ① 以释放者本人为执行者
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function manacore:api/damage/calc
# ② 找不到人(离线) -> 退回当前执行者, 至少还能按面板算
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function manacore:api/damage/calc
