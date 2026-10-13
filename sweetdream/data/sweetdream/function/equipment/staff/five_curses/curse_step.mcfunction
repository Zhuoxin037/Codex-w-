# ============================================================
# sweetdream:equipment/staff/five_curses/curse_step —— 「世咒」推进一世
# ------------------------------------------------------------
# 【执行者】被打中的那只生物(@s = 目标)
# 【文案(逐层)】
#   一世: 虚弱Ⅲ 3 秒      二世: 缓慢Ⅳ 3 秒
#   三世: 受到的技能伤害 +20%, 5 秒
#   四世: 护甲及护甲韧性 -50%, 5 秒
#   五世: 记录接下来最多 5 秒内受到的全部伤害
#   终世: 造成记录伤害的 30% 真实伤害, 之后清除世咒
# 【★ 计时怎么算 ★】全世咒**共用一个**剩余秒数 zx.fcv_t:
#   推进到第 N 世时, 把 fcv_t **重置**成该层的时长(3/3/5/5/5 秒) ——
#   也就是"每次命中都刷新世咒时长并加深一层"。
#   fcv_t 归零 = 世咒整体到期 ⇒ second 里结算(五世自动走终世 30%)并清干净。
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

# ① 层数 +1, 上限 5(第五世之后再命中 = 刷新第五世的记录窗口, 不再往前推)
scoreboard players add @s zx.fcv_st 1
execute if score @s zx.fcv_st matches 6.. run scoreboard players set @s zx.fcv_st 5

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

# ---- 第五世: 开记录窗口 5 秒(累计伤害的钩子在 internal/damage/one) ----
execute if score @s zx.fcv_st matches 5 run scoreboard players set @s zx.fcv_rec 0
execute if score @s zx.fcv_st matches 5 run tag @s add zx.fcv_5
execute if score @s zx.fcv_st matches 5 run scoreboard players set @s zx.fcv_t 5

# ② 表现: 世咒加深(层数越高越红)
execute at @s run particle minecraft:witch ~ ~1 ~ 0.3 0.5 0.3 0.02 8 normal
