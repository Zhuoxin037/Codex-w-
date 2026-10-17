# ============================================================
# sweetdream:equipment/staff/five_curses/curse_step —— 「世咒」推进一世
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = 目标)
# 【文案(逐层)】
#   一世: 虚弱Ⅲ 3 秒      二世: 缓慢Ⅳ 3 秒
#   三世: 受到的技能伤害 +20%, 5 秒
#   四世: 护甲及护甲韧性 -50%, 5 秒
#   五世: 记录接下来最多 10 秒内受到的全部伤害
#   终世: 造成记录伤害的 30% 真实伤害, 之后清除世咒
# 【★ 世咒怎么走(2026-10-15 用户拍板) ★】每次命中推进一世: 1→2→3→4→5;
#   **已在第五世之后再被本件命中 ⇒ 直接推进到终世结算(30%)并清除**, 不再刷新第五世。
#   ★ 旧行为是把 fcv_t 反复重置成 5(= 第五世的存在时间被一直往后刷), 永远走不到终世 ——
#     用户报为 bug。现写法: 加层**前**先快照"这一刀落下时是否已在第五世", 是就走终世分支(③)。
#   ★ 另一条到终世的路: 第五世的记录窗口**自然到期**(fcv_t 归零, 见 second/tick_one),
#     同样按 30% 结算。
# 【★ 计时怎么算 ★】全世咒**共用一个**剩余秒数 zx.fcv_t:
#   推进到第 N 世时, 把 fcv_t **重置**成该层的时长(3/3/5/5/10 秒)。
#   (一层一个计时器要 5 个账本、且互相覆盖, 收益不成比例; 共用一个是刻意的简化。)
# 【★ 三世易伤为什么不改 vuln_tag ★】vuln_tag 是夜火/噬心共用的 ×1.15 固定乘区;
#   本件要的是 **×1.20**, 所以另起 internal/damage/vuln_fcv3, 在 internal/damage/one
#   里按标签 zx.fcv_3 单独挂一条 —— 不去动公共那份, 免得把夜火的 15% 改成 20%。
# 【★ 四世破甲为什么用 attribute ★】项目里没有"按比例减护甲"的现成接口, 只能读
#   目标的 armor/armor_toughness **base** 值、取一半、加一个负的 add_value。
#   modifier 的 id 固定(sweetdream:fcv4_arm / _tou) ⇒ 重复推进时先 remove 再 add,
#   否则同 id 二次 add 会失败(静默, 护甲根本没减)。
# ============================================================

# ⓪ 记住"这份世咒是谁下的"(zx.fcv_u0..u3)
#   【为什么必须在目标身上存一份】终世可能在**记录窗口自然到期**时才结算,
#     那一刻施法者未必就在旁边 ⇒ 靠 @e[distance] 找人是找不回来的。
#     而"击杀返还魔力"必须记到施法者头上, 所以落咒的当下就把 uuid 抄下来。
#   【入参】调用方(普攻 ball_hit / 主动 skill)先把施法者的 u0..u3 放进
#     storage zx:work fcv —— 本函数只负责抄到目标身上。
#   【★ 直接 store 到 @s, 不要经假玩家中转 ★】假玩家是全局的, 一次命中多只目标时
#     "先存假玩家再赋给 @s" 会把同一个值灌给所有目标(串号); store 直接落到 @s 才对。
execute if data storage zx:work fcv.u0 run execute store result score @s zx.fcv_u0 run data get storage zx:work fcv.u0
execute if data storage zx:work fcv.u1 run execute store result score @s zx.fcv_u1 run data get storage zx:work fcv.u1
execute if data storage zx:work fcv.u2 run execute store result score @s zx.fcv_u2 run data get storage zx:work fcv.u2
execute if data storage zx:work fcv.u3 run execute store result score @s zx.fcv_u3 run data get storage zx:work fcv.u3

# ① ★ 加层**前**先判"这一刀落下时目标是不是已经在第五世" ★
#   【2026-10-15 用户拍板: 世咒是"逐级推进到终世"的链】已在第五世再被本件命中 ⇒
#     应当**推进到终世结算**, 而不是把第五世的记录窗口一直往后刷新(旧行为 = bug)。
#   ★ 快照标签挂在**目标自己**身上、不用假玩家 —— 一刀命中多只目标时不串号(坑 123 同款)。
#   ★ 开头先 remove 是防御性清残标(本函数末尾也会摘, 双保险)。
tag @s remove zx.fcv_final
execute if score @s zx.fcv_st matches 5.. run tag @s add zx.fcv_final

# ② 层数 +1, 上限 5
#   ★ 加层**前**先打快照标签 zx.fcv_new5 = "这一刀是从第四世跨进第五世"(⑤ 用它判断
#     记录要不要从头开始)。★ 标签挂在**目标自己**身上、不用假玩家。
execute if score @s zx.fcv_st matches 4 run tag @s add zx.fcv_new5
scoreboard players add @s zx.fcv_st 1
execute if score @s zx.fcv_st matches 6.. run scoreboard players set @s zx.fcv_st 5

# ③ ★ 已经在第五世 ⇒ 本刀走**终世结算(30%)**并清干净, 不再刷新第五世 ★
#   ★ #fcv_pct 必须**显式设回 30** —— 它是个**全局假玩家**, 主动技能会把它设成 80;
#     同一秒内先放技能再用普攻收尾时, 不重设就会按 80% 结算(与文案"终世 30% / 主动 80%"的分工不符)。
#   ★ final 内部会调 clear, 把 fcv_st 归 0 ⇒ 下面 1..5 世的 if 全部自然不成立,
#     不需要额外 return; 末尾"世咒加深"粒子也不再放(final 自己有更强的受击/魂火粒子)。
scoreboard players set #fcv_pct zx.meta 30
execute if entity @s[tag=zx.fcv_final] run function sweetdream:equipment/staff/five_curses/final

# ---- 第一世: 虚弱Ⅲ 3 秒 ----
execute if score @s zx.fcv_st matches 1 run effect give @s minecraft:weakness 3 2 true
execute if score @s zx.fcv_st matches 1 run scoreboard players set @s zx.fcv_t 3

# ---- 第二世: 缓慢Ⅳ 3 秒 ----
execute if score @s zx.fcv_st matches 2 run effect give @s minecraft:slowness 3 3 true
execute if score @s zx.fcv_st matches 2 run scoreboard players set @s zx.fcv_t 3

# ---- 第三世: 受技能伤害 +20%, 5 秒(标签驱动, 结算在 internal/damage/vuln_fcv3) ----
execute if score @s zx.fcv_st matches 3 run tag @s add zx.fcv_3
execute if score @s zx.fcv_st matches 3 run scoreboard players set @s zx.fcv_t 5

# ---- 第四世: 护甲 / 护甲韧性 -50%, 5 秒 ----
execute if score @s zx.fcv_st matches 4 run function sweetdream:equipment/staff/five_curses/armor_cut
execute if score @s zx.fcv_st matches 4 run scoreboard players set @s zx.fcv_t 5

# ---- 第五世: 开记录窗口 10 秒(累计伤害的钩子在 internal/damage/one) ----
#   ★ 2026-10-13 用户拍板: 第五世期间的伤害**累计**, 不许清零 ⇒
#     只有"这一刀才刚跨进第五世"才把 zx.fcv_rec 归零(那一刻它本来就是 0)。
#   ★ 2026-10-15 补充: "已在第五世再被命中"现在**走不到这里**(③ 已结算并清干净),
#     ⇒ 这一段实际只在"刚跨进第五世"时跑一次; fcv_new5 仍是"要不要归零"的判据, 保留兼容。
execute if score @s zx.fcv_st matches 5 if entity @s[tag=zx.fcv_new5] run scoreboard players set @s zx.fcv_rec 0
execute if score @s zx.fcv_st matches 5 run tag @s add zx.fcv_5
execute if score @s zx.fcv_st matches 5 run scoreboard players set @s zx.fcv_t 10
tag @s remove zx.fcv_new5

# ④ 表现: 世咒加深(层数越高越红)
#   ★ 结算终世的那一刀**不放**(它走 ③ 的 final, 已自带受击/魂火粒子); 只给"真的推了一层"放。
execute unless entity @s[tag=zx.fcv_final] at @s run particle minecraft:witch ~ ~1 ~ 0.3 0.5 0.3 0.02 8 normal
tag @s remove zx.fcv_final
