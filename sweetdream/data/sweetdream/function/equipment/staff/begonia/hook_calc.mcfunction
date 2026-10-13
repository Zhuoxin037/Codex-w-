# ============================================================
# sweetdream:equipment/staff/begonia/hook_calc —— 漩涡增强: mm 通道 +20%(加算)
# ------------------------------------------------------------
# @calc: add     ← 加算型: 只往加算池里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 排在 lib/dmg_add_apply 之前
#   (顺序由 check 规则 dmgord 盯着)。
# 【技能原文(超限·海棠)】"若有生物在漩涡范围内死亡，则对该漩涡进行增强：
#   在漩涡内使用关于最大魔力值的技能时造成的伤害提升 20%。"
# 【三个判据逐个落实】
#   ① "关于最大魔力值的技能" = 本次结算走 mm 通道(读快照 zx:work ch.max_mana_mul,
#      与 lib/mm_add/take 同一口径) —— 平A / 攻击力类 / 当前魔力类都吃不到;
#   ② "在漩涡内" = 施法者站在某个**增强了**的漩涡 6 格内(6 = 超限漩涡的半径,
#      漩涡本体 = item_display, tag zx.bg_vtx, 增强后 tag zx.bg_emp);
#   ③ "对该漩涡" = 归属校验: 漩涡 data.zx.bg.u0..u3 必须是**这个玩家**的 UUID
#      —— 别人增强的漩涡不能给你加成(多玩家不串)。
# 【写入哪个池】mm 通道 +20(加算, 和共振/漫步冥河/mm_add 同一条流水线)。
#   ★ 不消费(与 mm_add 不同): 增强跟着漩涡寿命走, 不是"下一次"口径。
# ------------------------------------------------------------
# 【★★ N09 修(2026-10-11): 本文件必须**不含宏变量** ★★】
#   原实现把 `$execute if entity @e[…$(u0)…$(u3)…]` 直接写在本文件里
#   ⇒ 本文件成了**宏函数**; 而它是被 `#manacore:event/damage_calc` **无参**派发的
#   (标签只能 `function #…`, 没有 with) ⇒ 宏行拿不到参数, 整段(含"往池子 +20")
#   一条都不跑, 且**零日志** —— 海棠增强形同不存在。
#   第 29~33 行就地准备 bgc 参数也没用: 参数必须在**调用那一刻**就具备。
#   正解 = 拆两层: 本文件是**普通函数**(判玩家 / 判通道 / 备 UUID 节点 / 定位置),
#   唯一那条宏行搬进 begonia/emp_find, 由本文件 `with storage zx:work bgc` 调用。
# ============================================================

# ⓪ 不是玩家(法球 / 箭 / marker 在算伤害) -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 本次结算走的是 mm 通道吗(没走就不用查漩涡了)
scoreboard players set #u zx.meta 0
execute store result score #u zx.meta run data get storage zx:work ch.max_mana_mul 100
execute unless score #u zx.meta matches 1.. run return 0

# ② + ③ 施法者 UUID 四 int 备进宏节点(归属校验只能拼进选择器)
data modify storage zx:work bgc set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work bgc.u0 set from entity @s UUID[0]
data modify storage zx:work bgc.u1 set from entity @s UUID[1]
data modify storage zx:work bgc.u2 set from entity @s UUID[2]
data modify storage zx:work bgc.u3 set from entity @s UUID[3]

# ④ 查"我自己增强过的漩涡" —— 交给宏叶子
#   【★ N09 补: 必须先 `at @s` ★】emp_find 里的 `distance=..6` 是以**执行位置**为圆心的。
#   本事件由 calc_as_owner 把执行者换成了玩家本人, 但**没换位置** ——
#   不加 `at @s` 就会拿"命令栈里残留的召唤物坐标"当圆心, 判成"施法者不在漩涡旁"
#   (判决静默偏向"不给加成")。@s 已由 ⓪ 保证是玩家。
execute at @s run function sweetdream:equipment/staff/begonia/emp_find with storage zx:work bgc
