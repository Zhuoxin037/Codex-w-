# ============================================================
# sweetdream:core/load —— 加载 / 重载时执行
# ------------------------------------------------------------
# 【谁调用它】data/minecraft/tags/function/load.json
# 【为什么用 execute unless + storage 标记来建计分板目标】
#   scoreboard objectives add 在目标已存在时会报错, 报错会中断整个函数 ——
#   第二次 /reload 之后后面的初始化就全都不跑了。
#   所以给目标配一个创建标记, 把 add 限制成一次。
#   (注意: scoreboard players set 在 1.21.5 不会自动建目标, 不能用它兜底。)
# 【zx.meta 现在用来干嘛】记"备份架子连续丢了几 tick",
#   详见 internal/summon_named_stand。
# ============================================================

execute unless data storage zx:config obj_meta run scoreboard objectives add zx.meta dummy
execute unless data storage zx:config obj_meta run data modify storage zx:config obj_meta set value 1b

# zx.meta 上的常量: #tps = 每秒多少 tick。
# 面板要把"剩余冷却 tick"换算成秒, 用的是它, 而不是前置包的 #interval。
# (#interval 是"回魔间隔", 默认也是 20 —— 但那是巧合。哪天把回魔间隔改成 10,
#  借它算冷却就会把秒数显示成 2 倍。)
scoreboard players set #tps zx.meta 20

# 观测镜冷却显示的一位小数(2026-10-18): 要显示 "3.4s" 就得把 tick 先折成
# "0.1 秒"单位 —— 1 tick = 0.05 秒 ⇒ ceil(tick/2) 就是 0.1 秒数, 再拆成
# 整数位(cdi)与十分位(cdd)。除 2 与拆位各需要一个常量。
scoreboard players set #two zx.meta 2
scoreboard players set #ten zx.meta 10

# 横刀突进用的计分项: 每个玩家自己的"还剩几步"
#   用计分项而不是 storage —— 它天然"每人一份", 不用按 UUID 拼路径,
#   于是突进那一整套完全不需要宏函数, 少一层就少一类坑。
execute unless data storage zx:config obj_dash run scoreboard objectives add zx.dash dummy
execute unless data storage zx:config obj_dash run data modify storage zx:config obj_dash set value 1b

# 无息(2026-10-07 批1)突击用的计分项: 每人自己"还剩几步"(同 zx.dash 一套写法)
execute unless data storage zx:config obj_hush run scoreboard objectives add zx.hush dummy
execute unless data storage zx:config obj_hush run data modify storage zx:config obj_hush set value 1b
# 无息 · 归位倒计时(安全网): 每刻 -1, 归零强制收尾, 防止原点 marker 丢失时卡死
execute unless data storage zx:config obj_hush_bk run scoreboard objectives add zx.hush_bk dummy
execute unless data storage zx:config obj_hush_bk run data modify storage zx:config obj_hush_bk set value 1b

# 神裁(2026-10-07 批1):
#   zx.vd_lt = 被动"每次攻击后"的按刻去重戳(player_hurt_entity 每命中一只触发一次)
execute unless data storage zx:config obj_vd_lt run scoreboard objectives add zx.vd_lt dummy
execute unless data storage zx:config obj_vd_lt run data modify storage zx:config obj_vd_lt set value 1b
#   zx.vd_ft = 「领域」marker 的剩余秒数(3 -> 0 后 kill, 由 lib/second 每秒 -1)
execute unless data storage zx:config obj_vd_ft run scoreboard objectives add zx.vd_ft dummy
execute unless data storage zx:config obj_vd_ft run data modify storage zx:config obj_vd_ft set value 1b

# 火种(2026-10-07 批1):
#   zx.td_on  = 「火种」状态(1=燃烧 / 0=熄灭)
execute unless data storage zx:config obj_td_on run scoreboard objectives add zx.td_on dummy
execute unless data storage zx:config obj_td_on run data modify storage zx:config obj_td_on set value 1b
#   zx.td_lt  = "每次攻击"去重戳
execute unless data storage zx:config obj_td_lt run scoreboard objectives add zx.td_lt dummy
execute unless data storage zx:config obj_td_lt run data modify storage zx:config obj_td_lt set value 1b

# 回锋(2026-10-07 批1):
#   zx.rb_lt   = "每次攻击"去重戳
execute unless data storage zx:config obj_rb_lt run scoreboard objectives add zx.rb_lt dummy
execute unless data storage zx:config obj_rb_lt run data modify storage zx:config obj_rb_lt set value 1b
#   zx.rb_blade = 「断刃」层数(0..3; 观测镜第二行显示见 lib/reg/build 的 layer 表)
execute unless data storage zx:config obj_rb_blade run scoreboard objectives add zx.rb_blade dummy
execute unless data storage zx:config obj_rb_blade run data modify storage zx:config obj_rb_blade set value 1b
#   zx.rb_rep = 主动技能"还要重复打几次"(0..3, 起手 = 层数)   # layer-skip: 这是技能执行进度, 玩家要看的是 zx.rb_blade「断刃」层数(已登记)
#   zx.rb_t   = 距离下一次打击的剩余刻数(起手 7 = 0.35 秒; 0/无分数 = 不在重复中)
#     ★ 这两个是"每 0.35 秒重复一次"的计时器, 由 core/tick 驱动 rebound/tick_step。
execute unless data storage zx:config obj_rb_rep run scoreboard objectives add zx.rb_rep dummy
execute unless data storage zx:config obj_rb_rep run data modify storage zx:config obj_rb_rep set value 1b
execute unless data storage zx:config obj_rb_t run scoreboard objectives add zx.rb_t dummy
execute unless data storage zx:config obj_rb_t run data modify storage zx:config obj_rb_t set value 1b
#   zx.rb_omul = 回锋主动**当前这一段**的倍率(千分比整数, 2000 = ×2.0)
#     ★ 2026-10-23 用户纠正口径: "每重复一次则**当次**伤害加倍率", 不是整体加倍率。
#       ⇒ 第 1 段 ×2(2000), 每重复一次本段倍率 ×2 ⇒ 4 层时各段 = 2/4/8/16/32。
#       由 cast 起手 set 2000、tick_step 每段打之前 `×= #2`(仅超限时), recalc 换算成 double。
#     layer-skip: 这是"这一段"的倍率, 玩家要看的是层数 zx.rb_blade(已登记)
execute unless data storage zx:config obj_rb_omul run scoreboard objectives add zx.rb_omul dummy
execute unless data storage zx:config obj_rb_omul run data modify storage zx:config obj_rb_omul set value 1b
#   zx.rb_ol = 这一轮连击是不是**超限·回锋**放的(0/1, 跨刻保留到连击打完)
#     ★ 必须挂在玩家身上: tick_step 是在 0.35 秒之后跑的, 那时手上的剑未必还是回锋,
#       不能再 `if items` 判一遍(与"换手仍生效"同源的坑)。
#     layer-skip: 内部旗标, 不是层数
execute unless data storage zx:config obj_rb_ol run scoreboard objectives add zx.rb_ol dummy
execute unless data storage zx:config obj_rb_ol run data modify storage zx:config obj_rb_ol set value 1b

# ---- 批2 · 斧(2026-10-07) ----
# 崩裂(2026-10-07 批2):
#   zx.fi_ft = 「裂缝」marker 的剩余秒数(5 -> 0 后 kill, 由 lib/second 每秒 -1)
execute unless data storage zx:config obj_fi_ft run scoreboard objectives add zx.fi_ft dummy
execute unless data storage zx:config obj_fi_ft run data modify storage zx:config obj_fi_ft set value 1b
# 天使核心(2026-10-08 新增表现):
#   zx.ab_t = 「圣光柱」(受伤生物处升起的光柱 item_display)的剩余秒数(2 -> 0 后 kill, 由 lib/second 每秒 -1)
execute unless data storage zx:config obj_ab_t run scoreboard objectives add zx.ab_t dummy
execute unless data storage zx:config obj_ab_t run data modify storage zx:config obj_ab_t set value 1b
# 释梦(2026-10-07 批2):
#   zx.dr_life = 「入梦体」marker 的安全寿命(600 tick, 由 core/tick 每刻 -1, 归零自毁)
execute unless data storage zx:config obj_dr_life run scoreboard objectives add zx.dr_life dummy
execute unless data storage zx:config obj_dr_life run data modify storage zx:config obj_dr_life set value 1b
# 饮鸩(2026-10-07 批2):
#   zx.dg_on  = 攻击力加成的剩余秒数(10 -> 0, 由 lib/second 每秒 -1, 到点 strip)
#   zx.dg_buf = 这次"血量换基础攻击力"实际加了多少(账本, 撤除时按它减回去)
execute unless data storage zx:config obj_dg_on run scoreboard objectives add zx.dg_on dummy
execute unless data storage zx:config obj_dg_on run data modify storage zx:config obj_dg_on set value 1b
execute unless data storage zx:config obj_dg_buf run scoreboard objectives add zx.dg_buf dummy
execute unless data storage zx:config obj_dg_buf run data modify storage zx:config obj_dg_buf set value 1b
# 超限·饮鸩(2026-10-23 批 K4) —— 第二形态的五个账(全部在**玩家**身上):
#   zx.dg_ol2  = 1 = 第一形态已经放过, 血量 >60% 时再按一次可进第二形态
#   zx.dg_mode = 2 = 第二形态进行中(每一下满蓄力平A 触发一次 ol_hit)
#   zx.dg_n    = 本形态已触发次数(0..4, 满 4 次关模式)
#   zx.dg_on2  = 第二形态加成的剩余秒数(10 -> 0, 到点 ol_strip)
#   zx.dg_buf2 = 第二形态往面板 base_attack 里加了多少(账本, 撤除时按它减回去)
#   ★ 与第一形态的 dg_on / dg_buf **分开两份**: 两段可以同时在身上
#     (第一形态 12 秒还没到期时就开了第二形态), 共用一本账会被减两次。
execute unless data storage zx:config obj_dg_ol2 run scoreboard objectives add zx.dg_ol2 dummy
execute unless data storage zx:config obj_dg_ol2 run data modify storage zx:config obj_dg_ol2 set value 1b
execute unless data storage zx:config obj_dg_mode run scoreboard objectives add zx.dg_mode dummy
execute unless data storage zx:config obj_dg_mode run data modify storage zx:config obj_dg_mode set value 1b
execute unless data storage zx:config obj_dg_n run scoreboard objectives add zx.dg_n dummy
execute unless data storage zx:config obj_dg_n run data modify storage zx:config obj_dg_n set value 1b
execute unless data storage zx:config obj_dg_on2 run scoreboard objectives add zx.dg_on2 dummy
execute unless data storage zx:config obj_dg_on2 run data modify storage zx:config obj_dg_on2 set value 1b
execute unless data storage zx:config obj_dg_buf2 run scoreboard objectives add zx.dg_buf2 dummy
execute unless data storage zx:config obj_dg_buf2 run data modify storage zx:config obj_dg_buf2 set value 1b
# 葬火(2026-10-07 批2):
#   zx.py_x   = 放空的魔力值 X(第二段的伤害基数; 0 = 没有待结算的葬火)
#   zx.py_rdy = 「下一次攻击」已就绪(1 = 右键之后还没打出那一下)
#   zx.py_d   = 第二段的 2 秒倒计时(40 tick, 由 core/tick 每刻 -1)
#   zx.py_lt  = "每次攻击"去重戳
execute unless data storage zx:config obj_py_x run scoreboard objectives add zx.py_x dummy
execute unless data storage zx:config obj_py_x run data modify storage zx:config obj_py_x set value 1b
execute unless data storage zx:config obj_py_rdy run scoreboard objectives add zx.py_rdy dummy
execute unless data storage zx:config obj_py_rdy run data modify storage zx:config obj_py_rdy set value 1b
execute unless data storage zx:config obj_py_d run scoreboard objectives add zx.py_d dummy
execute unless data storage zx:config obj_py_d run data modify storage zx:config obj_py_d set value 1b
execute unless data storage zx:config obj_py_lt run scoreboard objectives add zx.py_lt dummy
execute unless data storage zx:config obj_py_lt run data modify storage zx:config obj_py_lt set value 1b
# 歌谣(2026-10-07 批2):
#   zx.bd_tune = 「曲调」层数(0..8; 观测镜第二行显示见 lib/reg/build 的 layer 表)
#   zx.bd_song = 「下一次攻击」已就绪(1 = 右键之后还没打出那一下)
#   zx.bd_lt   = "每次攻击"去重戳
execute unless data storage zx:config obj_bd_tune run scoreboard objectives add zx.bd_tune dummy
execute unless data storage zx:config obj_bd_tune run data modify storage zx:config obj_bd_tune set value 1b
execute unless data storage zx:config obj_bd_song run scoreboard objectives add zx.bd_song dummy
execute unless data storage zx:config obj_bd_song run data modify storage zx:config obj_bd_song set value 1b
execute unless data storage zx:config obj_bd_lt run scoreboard objectives add zx.bd_lt dummy
execute unless data storage zx:config obj_bd_lt run data modify storage zx:config obj_bd_lt set value 1b
# 超限·歌谣(2026-10-23 批 K5):
#   zx.blt_lt = 攻击攒层之后记的 tick(kill 拿它去重: 一击必杀不该加两点)
#   zx.nt_t   = 「音符」marker 上的倒计时刻数(20 -> 0, 到 0 铺路径结算)
#   zx.nt_d   = 「音符」marker 上的路径伤害整点(基础攻击力 × X)
#   ★ nt_t / nt_d 是**召唤物身上**的推进量, 不进观测镜 layer 表。
execute unless data storage zx:config obj_blt_lt run scoreboard objectives add zx.blt_lt dummy
execute unless data storage zx:config obj_blt_lt run data modify storage zx:config obj_blt_lt set value 1b
execute unless data storage zx:config obj_nt_t run scoreboard objectives add zx.nt_t dummy
execute unless data storage zx:config obj_nt_t run data modify storage zx:config obj_nt_t set value 1b
execute unless data storage zx:config obj_nt_d run scoreboard objectives add zx.nt_d dummy
execute unless data storage zx:config obj_nt_d run data modify storage zx:config obj_nt_d set value 1b
#
# 超限·剜霜 frost_carve（2026-10-23 批 K5）：
#   zx.frc_fr = 「披霜」剩余份数(0..3; 受击消耗一份, 冻住攻击者及其 3 格内 2 秒)
#   zx.frc_ft = 「披霜」剩余秒数(12 -> 0, 到点把 frc_fr 清 0)
#   ★ 记在**玩家自己**身上, 但它是"一份一份的使用次数"而不是持续累积的层数,
#     观测镜没有对应行(与饮鸩 dg_on2 同族), 不进 layer 表。
execute unless data storage zx:config obj_frc_fr run scoreboard objectives add zx.frc_fr dummy
execute unless data storage zx:config obj_frc_fr run data modify storage zx:config obj_frc_fr set value 1b
execute unless data storage zx:config obj_frc_ft run scoreboard objectives add zx.frc_ft dummy
execute unless data storage zx:config obj_frc_ft run data modify storage zx:config obj_frc_ft set value 1b
# 威霆(2026-10-07 批2):
#   zx.tc_n    = 「天煌」点数(0..2000; 观测镜第二行显示见 lib/reg/build 的 layer 表)
#   zx.tc_on   = 场上是否有自己的术阵(1 = 有; 术阵结束由 field_end 反查施法者清 0)
#   zx.tc_lt   = "每次攻击"去重戳
#   zx.tc_ft   = 术阵 marker 的剩余秒数(由 lib/second 每秒 -1)
#   zx.tc_bc   = 被击者身上的累计雷击次数(每满 10 次掉 10% 最大生命)
#   zx.tc_bs   = 「落雷排期」marker 上"还剩几道真闪电没劈"(起手 = X; 排期见 bolt_go/bolt_fx)
#   zx.tc_ang  = 上面那个 marker 上"下一道闪电的角度"(每道 +30°, 让 X 道不重叠)
execute unless data storage zx:config obj_tc_n run scoreboard objectives add zx.tc_n dummy
execute unless data storage zx:config obj_tc_n run data modify storage zx:config obj_tc_n set value 1b
execute unless data storage zx:config obj_tc_on run scoreboard objectives add zx.tc_on dummy
execute unless data storage zx:config obj_tc_on run data modify storage zx:config obj_tc_on set value 1b
execute unless data storage zx:config obj_tc_lt run scoreboard objectives add zx.tc_lt dummy
execute unless data storage zx:config obj_tc_lt run data modify storage zx:config obj_tc_lt set value 1b
execute unless data storage zx:config obj_tc_ft run scoreboard objectives add zx.tc_ft dummy
execute unless data storage zx:config obj_tc_ft run data modify storage zx:config obj_tc_ft set value 1b
execute unless data storage zx:config obj_tc_bc run scoreboard objectives add zx.tc_bc dummy
execute unless data storage zx:config obj_tc_bc run data modify storage zx:config obj_tc_bc set value 1b
execute unless data storage zx:config obj_tc_bs run scoreboard objectives add zx.tc_bs dummy
execute unless data storage zx:config obj_tc_bs run data modify storage zx:config obj_tc_bs set value 1b
execute unless data storage zx:config obj_tc_ang run scoreboard objectives add zx.tc_ang dummy
execute unless data storage zx:config obj_tc_ang run data modify storage zx:config obj_tc_ang set value 1b
#   zx.tc_end  = 术阵 marker 的**绝对到期 tick**(gametime + 持续秒数×20; R03 卸载补偿用:
#     区块卸载期间全局时钟照走, marker 重新加载时按它补一刀, 免得术阵比框架记录的多活)
execute unless data storage zx:config obj_tc_end run scoreboard objectives add zx.tc_end dummy
execute unless data storage zx:config obj_tc_end run data modify storage zx:config obj_tc_end set value 1b
# 苍蓝星(2026-10-07 批2):
#   zx.as_lt  = "每次攻击"去重戳
#   zx.as_x2  = 「本武器伤害倍率翻倍」待生效标记(1 = 攒着; 下一次技能消费后清零)
#     ★ 观测镜第二行显示见 lib/reg/build 的 layer 表; 面板折进 smul_mm 见 azure_star/scan_mul
#   zx.as_d   = 主动"第 2 段还有几刻落地"(起手 7 = 0.35 秒; 0/无分数 = 没有待落的第 2 段)
#   zx.as_db  = "本次技能该不该 ×2"的存根(段① recalc 写下, 段② recalc2 消费)
#     ★ 为什么要存根: 两段隔 0.35 秒分两次结算, 而 zx.as_x2 在段① 就清零了。
execute unless data storage zx:config obj_as_lt run scoreboard objectives add zx.as_lt dummy
execute unless data storage zx:config obj_as_lt run data modify storage zx:config obj_as_lt set value 1b
execute unless data storage zx:config obj_as_x2 run scoreboard objectives add zx.as_x2 dummy
execute unless data storage zx:config obj_as_x2 run data modify storage zx:config obj_as_x2 set value 1b
execute unless data storage zx:config obj_as_d run scoreboard objectives add zx.as_d dummy
execute unless data storage zx:config obj_as_d run data modify storage zx:config obj_as_d set value 1b
execute unless data storage zx:config obj_as_db run scoreboard objectives add zx.as_db dummy
execute unless data storage zx:config obj_as_db run data modify storage zx:config obj_as_db set value 1b
# 红莲(2026-10-07 批2, 改为"每 0.35 秒一段"):
#   zx.rl_rep = 主动还有几段没打(起手 = 流火只数 + 夜火只数; 先当场打一段, 剩下的逐段推)
#   zx.rl_t   = 距离下一段的剩余刻数(起手 7 = 0.35 秒; 0/无分数 = 不在连击中)
#     ★ 筛 `zx.rl_t=1..` 是天然停摆: 打完最后一段就停在 0, 不再被选中, 不用额外清理。
execute unless data storage zx:config obj_rl_rep run scoreboard objectives add zx.rl_rep dummy
execute unless data storage zx:config obj_rl_rep run data modify storage zx:config obj_rl_rep set value 1b
execute unless data storage zx:config obj_rl_t run scoreboard objectives add zx.rl_t dummy
execute unless data storage zx:config obj_rl_t run data modify storage zx:config obj_rl_t set value 1b

# ---- 批3 · 法杖(2026-10-07) ----
# 共鸣(2026-10-07 批3):
#   zx.ch_end = 「共鸣水晶」(marker)的到期时刻(框架时钟; 8 秒后自毁)
execute unless data storage zx:config obj_ch_end run scoreboard objectives add zx.ch_end dummy
execute unless data storage zx:config obj_ch_end run data modify storage zx:config obj_ch_end set value 1b
#   zx.ch_cd  = 「共鸣水晶」"法术穿过"的节流倒计时(每触发一次压 10 tick = 0.5 秒;
#               用户 2026-10-09 定: 可以持续触发, 但每 0.5 秒最多一次)
execute unless data storage zx:config obj_ch_cd run scoreboard objectives add zx.ch_cd dummy
execute unless data storage zx:config obj_ch_cd run data modify storage zx:config obj_ch_cd set value 1b
#   zx.ch_beam = "这一刻正被自己人的持续光束照着"(1 = 有戳; 由光束每步置 1,
#                pass_set 读完立刻清 0)。★ 2026-10-20 从实体 tag 改成计分项 ——
#                原来每步给水晶 marker add 一次 tag、pass_set 每刻 remove,
#                光束持续期间等于每刻都在写 marker 的实体 NBT(chunk 每刻变脏)。
execute unless data storage zx:config obj_ch_beam run scoreboard objectives add zx.ch_beam dummy
execute unless data storage zx:config obj_ch_beam run data modify storage zx:config obj_ch_beam set value 1b
# ★ 2026-10-20 第二轮卡顿修复(pass_set 的两个"本刻戳"从实体 tag 改成计分项):
#   偏振光/终末天启的光束会**持续照着**水晶 ⇒ 每 0.5 秒(zx.ch_cd 节流)走一次完整
#   结算 ⇒ 对水晶 3/5 格内每一个生物先 addTag 再 removeTag。命中就 setChanged(),
#   所在 chunk 标脏 ⇒ 存盘重写整份 chunk。玩家感受 = "打一下卡一下"。
#   zx.ch_act = 这颗水晶"本刻有触发"(每刻开头清 0, 有球穿过/被光束照着才置 1)
#   zx.ch_p   = "本轮结算的目标"(圈 -> 打 -> 清, 生命周期只有本刻)
execute unless data storage zx:config obj_ch_act run scoreboard objectives add zx.ch_act dummy
execute unless data storage zx:config obj_ch_act run data modify storage zx:config obj_ch_act set value 1b
execute unless data storage zx:config obj_ch_p run scoreboard objectives add zx.ch_p dummy
execute unless data storage zx:config obj_ch_p run data modify storage zx:config obj_ch_p set value 1b
#   zx.ch_mine = "这颗水晶属于当前正在铺光的那位施法者" —— 由 polarized_light/cry_scan
#                每**束**光算一次(原来在 beam_step 里每**步**算一次, 且要 NBT 匹配),
#                beam_step 每步只按它做 scores 筛。没水晶时 #pl_has=0, 整行不跑。
execute unless data storage zx:config obj_ch_mine run scoreboard objectives add zx.ch_mine dummy
execute unless data storage zx:config obj_ch_mine run data modify storage zx:config obj_ch_mine set value 1b
# 调色盘(2026-10-07 批3):
#   zx.pal_c1 / zx.pal_c2 = 玩家身上两个"颜色槽"(0 空 / 1 红 / 2 黄 / 3 蓝)
#   zx.pal_id / zx.pal_rng / zx.pal_thr / zx.pal_mul / zx.pal_blu / zx.pal_n
#       = “色彩”光球的参数: id / 半径 / 阀值 / 伤害倍率(1+红数) / 蓝数 / 已打数
#   zx.pal_hit = 贴在生物身上: 最后一次打它的“色彩”id(用来跳过"已攻击过的生物")
#   ★ 2026-10-08: 原 zx.pal_life / zx.pal_end(寿命) **已全部删掉** ——
#     文案里"色彩"只有两个自毁条件(离自身 12 格 / 打满阀值), 没有时间限制。
execute unless data storage zx:config obj_pal_c1 run scoreboard objectives add zx.pal_c1 dummy
execute unless data storage zx:config obj_pal_c1 run data modify storage zx:config obj_pal_c1 set value 1b
execute unless data storage zx:config obj_pal_c2 run scoreboard objectives add zx.pal_c2 dummy
execute unless data storage zx:config obj_pal_c2 run data modify storage zx:config obj_pal_c2 set value 1b
execute unless data storage zx:config obj_pal_id run scoreboard objectives add zx.pal_id dummy
execute unless data storage zx:config obj_pal_id run data modify storage zx:config obj_pal_id set value 1b
execute unless data storage zx:config obj_pal_rng run scoreboard objectives add zx.pal_rng dummy
execute unless data storage zx:config obj_pal_rng run data modify storage zx:config obj_pal_rng set value 1b
execute unless data storage zx:config obj_pal_thr run scoreboard objectives add zx.pal_thr dummy
execute unless data storage zx:config obj_pal_thr run data modify storage zx:config obj_pal_thr set value 1b
execute unless data storage zx:config obj_pal_mul run scoreboard objectives add zx.pal_mul dummy
execute unless data storage zx:config obj_pal_mul run data modify storage zx:config obj_pal_mul set value 1b
execute unless data storage zx:config obj_pal_blu run scoreboard objectives add zx.pal_blu dummy
execute unless data storage zx:config obj_pal_blu run data modify storage zx:config obj_pal_blu set value 1b
execute unless data storage zx:config obj_pal_n run scoreboard objectives add zx.pal_n dummy
execute unless data storage zx:config obj_pal_n run data modify storage zx:config obj_pal_n set value 1b
execute unless data storage zx:config obj_pal_hit run scoreboard objectives add zx.pal_hit dummy
execute unless data storage zx:config obj_pal_hit run data modify storage zx:config obj_pal_hit set value 1b
# 海棠(2026-10-07 批3):
#   zx.bg_t = 漩涡 marker 的剩余秒数(8 -> 0, 归零在 vortex_end 结算)
execute unless data storage zx:config obj_bg_t run scoreboard objectives add zx.bg_t dummy
execute unless data storage zx:config obj_bg_t run data modify storage zx:config obj_bg_t set value 1b
# 海棠超限(2026-10-10 批 G): zx.bg_ol = 施法那刻"手里是不是超限版"的快照(玩家身上)
execute unless data storage zx:config obj_bg_ol run scoreboard objectives add zx.bg_ol dummy
execute unless data storage zx:config obj_bg_ol run data modify storage zx:config obj_bg_ol set value 1b
# 海棠增强检测(2026-10-12 坑 134): zx.bg_n = 漩涡**上一刻**6 格内的活体数(挂在漩涡实体上)。
#   vortex_death 每刻拿"这一刻的数量"跟它比: 变少 => 范围内有生物死亡 => 增强。
#   旧版用 @e 正向判死(MC-108307 下恒假, 永不触发), 已重写。
execute unless data storage zx:config obj_bg_n run scoreboard objectives add zx.bg_n dummy
execute unless data storage zx:config obj_bg_n run data modify storage zx:config obj_bg_n set value 1b
# 蛊毒(2026-10-07 批3):
#   zx.gp_t = 被选中的「噬心」目标身上: 本轮还剩几秒(6 -> 0, 归零在 gp_end 结算)
execute unless data storage zx:config obj_gp_t run scoreboard objectives add zx.gp_t dummy
execute unless data storage zx:config obj_gp_t run data modify storage zx:config obj_gp_t set value 1b
# 暮光(2026-10-07 批3):
#   zx.tw_t = 被选中的「噬心」目标身上: 本轮还剩几秒(8 -> 0, 归零在 tw_end 摘修饰符)
execute unless data storage zx:config obj_tw_t run scoreboard objectives add zx.tw_t dummy
execute unless data storage zx:config obj_tw_t run data modify storage zx:config obj_tw_t set value 1b
# 风帆(2026-10-07 批3):
#   zx.sl_u0..u3 / zx.sl_mask / zx.sl_ok = 玩家侧"记录": 最近生物的 UUID 四个 int + 四标记位掩码 + 有无
#   zx.sl_vt = 玩家侧"旋风进行中"的剩余秒数(15 -> 0); 用来识别"再次使用技能"
#   zx.sl_t / zx.sl_p = 旋风 marker 侧: 剩余秒数 / 距下次脉冲的秒数
#   zx.sl_a = 旋风 marker 侧: 表现用的当前角度(每刻 +6, 0..359; 见 whirl_fx)
#   zx.sl_m = 旋风 marker 侧: 最近一次附着了哪一种属性(0 无 / 1 渊海 / 2 流火 / 3 白昼梦 / 4 噬心)
execute unless data storage zx:config obj_sl_u0 run scoreboard objectives add zx.sl_u0 dummy
execute unless data storage zx:config obj_sl_u0 run data modify storage zx:config obj_sl_u0 set value 1b
execute unless data storage zx:config obj_sl_u1 run scoreboard objectives add zx.sl_u1 dummy
execute unless data storage zx:config obj_sl_u1 run data modify storage zx:config obj_sl_u1 set value 1b
execute unless data storage zx:config obj_sl_u2 run scoreboard objectives add zx.sl_u2 dummy
execute unless data storage zx:config obj_sl_u2 run data modify storage zx:config obj_sl_u2 set value 1b
execute unless data storage zx:config obj_sl_u3 run scoreboard objectives add zx.sl_u3 dummy
execute unless data storage zx:config obj_sl_u3 run data modify storage zx:config obj_sl_u3 set value 1b
execute unless data storage zx:config obj_sl_mask run scoreboard objectives add zx.sl_mask dummy
execute unless data storage zx:config obj_sl_mask run data modify storage zx:config obj_sl_mask set value 1b
execute unless data storage zx:config obj_sl_ok run scoreboard objectives add zx.sl_ok dummy
execute unless data storage zx:config obj_sl_ok run data modify storage zx:config obj_sl_ok set value 1b
execute unless data storage zx:config obj_sl_vt run scoreboard objectives add zx.sl_vt dummy
execute unless data storage zx:config obj_sl_vt run data modify storage zx:config obj_sl_vt set value 1b
execute unless data storage zx:config obj_sl_t run scoreboard objectives add zx.sl_t dummy
execute unless data storage zx:config obj_sl_t run data modify storage zx:config obj_sl_t set value 1b
execute unless data storage zx:config obj_sl_p run scoreboard objectives add zx.sl_p dummy
execute unless data storage zx:config obj_sl_p run data modify storage zx:config obj_sl_p set value 1b
execute unless data storage zx:config obj_sl_a run scoreboard objectives add zx.sl_a dummy
execute unless data storage zx:config obj_sl_a run data modify storage zx:config obj_sl_a set value 1b
execute unless data storage zx:config obj_sl_m run scoreboard objectives add zx.sl_m dummy
execute unless data storage zx:config obj_sl_m run data modify storage zx:config obj_sl_m set value 1b

# ---- 批3 · 盔甲(2026-10-07) ----
# 共用的"魔力上限差值账本"(armor_mana):
#   zx.am_mana = 已经加进面板多少(每秒重算"该有多少", 补差值; 换装自动退)
execute unless data storage zx:config obj_am_mana run scoreboard objectives add zx.am_mana dummy
execute unless data storage zx:config obj_am_mana run data modify storage zx:config obj_am_mana set value 1b
# 血肉磨坊(2026-10-07 批3):
#   zx.fm_t = 受伤后的窗口剩余秒数(5 -> 0; 由 hurt 拉满, passive 每秒 -1)
execute unless data storage zx:config obj_fm_t run scoreboard objectives add zx.fm_t dummy
execute unless data storage zx:config obj_fm_t run data modify storage zx:config obj_fm_t set value 1b
# 息影(2026-10-07 批3):
#   zx.fd_t = 距上次释放技能还剩几秒(10 -> 0; 由 on_cast 拉满, passive 每秒 -1, 归零兑现)
execute unless data storage zx:config obj_fd_t run scoreboard objectives add zx.fd_t dummy
execute unless data storage zx:config obj_fd_t run data modify storage zx:config obj_fd_t set value 1b
# 堕梦·超限(2026-10-23 批 K9): 两个记在**被时停的生物**身上的临时量
#   zx.fd_ol = 这一份 DoT 是不是超限档(0/1; one 里拿不到施法者, 只能挂 DoT 时拍进来)
#   zx.fd_n  = 这一份 DoT 已经跳了几次(>6 ⇒ 之后每跳 ×0.08)
#   ★ 都由 one 在"脱离时停摘标"时一并清 0 —— 记在生物身上的临时分数必须配收尸。
execute unless data storage zx:config obj_fd_ol run scoreboard objectives add zx.fd_ol dummy
execute unless data storage zx:config obj_fd_ol run data modify storage zx:config obj_fd_ol set value 1b
execute unless data storage zx:config obj_fd_n run scoreboard objectives add zx.fd_n dummy
execute unless data storage zx:config obj_fd_n run data modify storage zx:config obj_fd_n set value 1b

# 装备效果用的"账本": 每个来源自己身上"已经加进面板多少"
#   装备加成只能靠"穿上加、脱下减"的差值写法(面板是一个数, 没有加成层),
#   所以每个来源单独记一笔, 换装时才知道自己该加减多少。
#   静脉泵 / 套装各记魔力, 体外 / 套装各记生命, 互不干涉。
#   (计分项名字上限 16 字符, 所以写得短)
execute unless data storage zx:config obj_pump_mana run scoreboard objectives add zx.pump_mana dummy
execute unless data storage zx:config obj_pump_mana run data modify storage zx:config obj_pump_mana set value 1b
execute unless data storage zx:config obj_set_mana run scoreboard objectives add zx.set_mana dummy
execute unless data storage zx:config obj_set_mana run data modify storage zx:config obj_set_mana set value 1b
execute unless data storage zx:config obj_power_hp run scoreboard objectives add zx.power_hp dummy
execute unless data storage zx:config obj_power_hp run data modify storage zx:config obj_power_hp set value 1b
execute unless data storage zx:config obj_set_hp run scoreboard objectives add zx.set_hp dummy
execute unless data storage zx:config obj_set_hp run data modify storage zx:config obj_set_hp set value 1b
# 升级系统: 盔甲升级给"魔力上限"的账本(同上面一套写法, 换装时靠差值加减)
execute unless data storage zx:config obj_up_mana run scoreboard objectives add zx.up_mana dummy
execute unless data storage zx:config obj_up_mana run data modify storage zx:config obj_up_mana set value 1b
# 升级系统 · 硬化石(2026-10-07): 护甲值 / 护甲韧性 / 最大生命值 三本账(同一套差值写法)
execute unless data storage zx:config obj_up_armor run scoreboard objectives add zx.up_armor dummy
execute unless data storage zx:config obj_up_armor run data modify storage zx:config obj_up_armor set value 1b
execute unless data storage zx:config obj_up_at run scoreboard objectives add zx.up_at dummy
execute unless data storage zx:config obj_up_at run data modify storage zx:config obj_up_at set value 1b
execute unless data storage zx:config obj_up_hp run scoreboard objectives add zx.up_hp dummy
execute unless data storage zx:config obj_up_hp run data modify storage zx:config obj_up_hp set value 1b
# 升级系统 · 神经衰弱石(2026-10-12): 攻击速度的账本(挂原版 attack_speed modifier,
#   和上面三本账同一套差值写法; 落地见 upgrade/held_apply + upgrade/api/atks_*)
execute unless data storage zx:config obj_up_atks run scoreboard objectives add zx.up_atks dummy
execute unless data storage zx:config obj_up_atks run data modify storage zx:config obj_up_atks set value 1b
# R02 死亡账本自愈(2026-10-10):
#   zx.deaths  = 原版死亡计数(criterion minecraft.custom:minecraft.deaths) —— 死亡探针;
#                死亡会重建玩家实体, 原版属性修饰符丢、计分板账本还在 ⇒ 账本失配。
#   zx.dc_last = 上次自愈时见到的死亡数(和 zx.deaths 一比就知道"这一秒死过没有")
execute unless data storage zx:config obj_deaths run scoreboard objectives add zx.deaths minecraft.custom:minecraft.deaths
execute unless data storage zx:config obj_deaths run data modify storage zx:config obj_deaths set value 1b
execute unless data storage zx:config obj_dc_last run scoreboard objectives add zx.dc_last dummy
execute unless data storage zx:config obj_dc_last run data modify storage zx:config obj_dc_last set value 1b
# O02 性能(2026-10-11, 依据 spark 剖析):
#   zx.hp_c = 原版生命 criterion(minecraft.health) —— 原版自动同步, 读它是纯计分板
#             操作(免费)。之前"活着吗/血多少"用 `data get entity @s Health` 读,
#             而**任何 data ... entity 都会把整个玩家(54 格背包+组件+lore)完整
#             序列化成 NBT** —— 观测镜面板每刻一次 + 账本自愈每人每秒一次,
#             剖析里它就是最大热点(NbtPredicate.entityToNbt 整条链)。
#   ★ 只拿它判"活着/死了"(>=1)和面板显示 —— 不做精确血量运算
#     (criterion 的刻度是 ×2 还是原值没有先例背书, 别依赖)。
execute unless data storage zx:config obj_hp_c run scoreboard objectives add zx.hp_c health
execute unless data storage zx:config obj_hp_c run data modify storage zx:config obj_hp_c set value 1b
#   zx.hp_show = 面板"当前生命"的每秒缓存(观测镜 cache 写, render_go 读)
execute unless data storage zx:config obj_hp_show run scoreboard objectives add zx.hp_show dummy
execute unless data storage zx:config obj_hp_show run data modify storage zx:config obj_hp_show set value 1b
# 升级系统 · 冷却石(2026-10-07):
#   zx.cdr   = 上一次写进 manacore 的 cooldown_reduction(×1000), 一样就跳过写入
#   zx.msp_c = 魔力沸涌的"攒秒"计数器(够 every 秒才真的减一次冷却)
execute unless data storage zx:config obj_cdr run scoreboard objectives add zx.cdr dummy
execute unless data storage zx:config obj_cdr run data modify storage zx:config obj_cdr set value 1b
execute unless data storage zx:config obj_msp_c run scoreboard objectives add zx.msp_c dummy
execute unless data storage zx:config obj_msp_c run data modify storage zx:config obj_msp_c set value 1b

# 超限系统: 施法**那一刻**拍下来的超限乘区快照(整数百分比)
#   不现读主手 —— 燎原光环 / 风行 3 轮爆发与回响都是施法之后才结算的,
#   那时候玩家可能已经换手了。详见 overlimit/api/snap。
execute unless data storage zx:config obj_ol_d run scoreboard objectives add zx.ol_d dummy
execute unless data storage zx:config obj_ol_d run data modify storage zx:config obj_ol_d set value 1b
execute unless data storage zx:config obj_ol_m run scoreboard objectives add zx.ol_m dummy
execute unless data storage zx:config obj_ol_m run data modify storage zx:config obj_ol_m set value 1b
execute unless data storage zx:config obj_ol_c run scoreboard objectives add zx.ol_c dummy
execute unless data storage zx:config obj_ol_c run data modify storage zx:config obj_ol_c set value 1b

# 桂冠专用: zx.dio_mana = 已经加进面板的魔力上限; zx.dio_regen = 还剩几秒回魔
execute unless data storage zx:config obj_dio_mana run scoreboard objectives add zx.dio_mana dummy
execute unless data storage zx:config obj_dio_mana run data modify storage zx:config obj_dio_mana set value 1b
execute unless data storage zx:config obj_dio_regen run scoreboard objectives add zx.dio_regen dummy
execute unless data storage zx:config obj_dio_regen run data modify storage zx:config obj_dio_regen set value 1b
# 桂冠超限(2026-10-10 批 H):
#   zx.dio_wine = 「酒浆」层数(最多 10) / zx.dio_ramt = 每秒回魔量(80/60/80 三种)
#   zx.dio_emp  = 技能伤害+30% 还剩几秒 / zx.dio_ih = 瞬间治疗Ⅳ还剩几秒(期间不可再触发)
execute unless data storage zx:config obj_dio_wine run scoreboard objectives add zx.dio_wine dummy
execute unless data storage zx:config obj_dio_wine run data modify storage zx:config obj_dio_wine set value 1b
execute unless data storage zx:config obj_dio_ramt run scoreboard objectives add zx.dio_ramt dummy
execute unless data storage zx:config obj_dio_ramt run data modify storage zx:config obj_dio_ramt set value 1b
execute unless data storage zx:config obj_dio_emp run scoreboard objectives add zx.dio_emp dummy
execute unless data storage zx:config obj_dio_emp run data modify storage zx:config obj_dio_emp set value 1b
execute unless data storage zx:config obj_dio_ih run scoreboard objectives add zx.dio_ih dummy
execute unless data storage zx:config obj_dio_ih run data modify storage zx:config obj_dio_ih set value 1b

# 风行于大地之上专用: 风声层数 / aura 加了多少最大魔力 / aura 剩余秒数 / 3 轮爆发剩几轮
execute unless data storage zx:config obj_wg_sound run scoreboard objectives add zx.wg_sound dummy
execute unless data storage zx:config obj_wg_sound run data modify storage zx:config obj_wg_sound set value 1b
execute unless data storage zx:config obj_wg_mana run scoreboard objectives add zx.wg_mana dummy
execute unless data storage zx:config obj_wg_mana run data modify storage zx:config obj_wg_mana set value 1b
execute unless data storage zx:config obj_wg_aura run scoreboard objectives add zx.wg_aura dummy
execute unless data storage zx:config obj_wg_aura run data modify storage zx:config obj_wg_aura set value 1b
# zx.wg_burst: 技能召唤完术阵后还剩几轮没打(每秒由 second 扣 1, 扣到 0 才结算风声奖励)
execute unless data storage zx:config obj_wg_burst run scoreboard objectives add zx.wg_burst dummy
execute unless data storage zx:config obj_wg_burst run data modify storage zx:config obj_wg_burst set value 1b

# 「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸套装 / 无效)专用:
#   zx.mm_add    = 加成的百分点(整数, 加算; 20 = +20%)
#   zx.mm_add_lt = 上次消费发生在第几刻(同刻去重用, 见 lib/mm_add/take)
#   ★ 2026-10-07 用户定稿: 原来那套 zx:data wg_bonus + lib/max_mana_bonus 整体去掉,
#     加成改成走这条通用乘区(和共振/漫步/炽天使同一条加算流水线)。
#   ★ 2026-10-08 用户定稿: **去掉倒计时**(zx.mm_add_t 已作废删除) —— 拿到就一直
#     挂着, 直到自身打出一次以最大魔力值结算的技能才清零(回到 lore"下一次"原义)。
#     ⚠️ 挂 zx.mm_hold 的那些伤害(忘川彼岸被动 / 风声回响)只读、不消费。
execute unless data storage zx:config obj_mm_add run scoreboard objectives add zx.mm_add dummy
execute unless data storage zx:config obj_mm_add run data modify storage zx:config obj_mm_add set value 1b
execute unless data storage zx:config obj_mm_add_lt run scoreboard objectives add zx.mm_add_lt dummy
execute unless data storage zx:config obj_mm_add_lt run data modify storage zx:config obj_mm_add_lt set value 1b

# 法球(法杖类普攻的载体)用的计分项: 一格 = 100(定点 2 位小数), 起步 3000 = 30 格
execute unless data storage zx:config obj_ball_dist run scoreboard objectives add zx.ball_dist dummy
execute unless data storage zx:config obj_ball_dist run data modify storage zx:config obj_ball_dist set value 1b

# 通用标签(渊海/流火/夜火/噬心/白昼梦)的图标系统:
#   zx.icon_id 只为读取旧版本编号而保留；新版使用完整 UUID 配对。
#   #icon_id 为旧数据兼容计数器，新版不再借号。
execute unless data storage zx:config obj_icon_id run scoreboard objectives add zx.icon_id dummy
execute unless data storage zx:config obj_icon_id run data modify storage zx:config obj_icon_id set value 1b
scoreboard players add #icon_id zx.meta 0

# 超•负•荷 的"超载状态"倒计时: 还剩几秒; 同时是"技能生效中"的开关
execute unless data storage zx:config obj_chg_on run scoreboard objectives add zx.chg_on dummy
execute unless data storage zx:config obj_chg_on run data modify storage zx:config obj_chg_on set value 1b

# 引梦镰 的"强化攻击"锁定: 触发过强化之后还剩几秒不能再触发(初始 0 = 没锁)
execute unless data storage zx:config obj_sd_lock run scoreboard objectives add zx.sd_lock dummy
execute unless data storage zx:config obj_sd_lock run data modify storage zx:config obj_sd_lock set value 1b

# 引梦镰 / 横刀 的"施法快照: 这把是不是超限版"(1/0)
#   ★ 为什么非要存玩家身上: 这两件的伤害都在施法**之后**才结算(镰刀 4 tick 后的
#     挥击帧、横刀 12 tick 后的落点), 那时武器已经被通用回手挪走了, 再判手里那把
#     一定判错。所以 cast 里拍一次, 结算处读它, 读完清掉。
execute unless data storage zx:config obj_sd_ol run scoreboard objectives add zx.sd_ol dummy
execute unless data storage zx:config obj_sd_ol run data modify storage zx:config obj_sd_ol set value 1b
execute unless data storage zx:config obj_hd_ol run scoreboard objectives add zx.hd_ol dummy
execute unless data storage zx:config obj_hd_ol run data modify storage zx:config obj_hd_ol set value 1b
# 影刃 的施法快照同理 —— 而且它的兑现时机更靠后(**换武器之后再击杀**),
#   那时手里必然不是影刃, 重判 is_ol 必为 0(2026-10-08 修: 超限击杀分支整个走不到)。
execute unless data storage zx:config obj_sb_ol run scoreboard objectives add zx.sb_ol dummy
execute unless data storage zx:config obj_sb_ol run data modify storage zx:config obj_sb_ol set value 1b

# 红莲(超限) 的施法快照 + "流火雨"计时(2026-10-09 批 F1)
#   zx.rl_ol   = 这把是不是超限版(cast 拍, 连击最后一段打完由 tick_step 清)
#                ★ 不能 cast 里清 —— recalc/hit_* 每一段都要读它。
#   zx.rl_rain = 超限版"消耗 >= 6 层"那 5 秒流火雨还剩几发(起手 4, 每秒 -1)
execute unless data storage zx:config obj_rl_ol run scoreboard objectives add zx.rl_ol dummy
execute unless data storage zx:config obj_rl_ol run data modify storage zx:config obj_rl_ol set value 1b
execute unless data storage zx:config obj_rl_rain run scoreboard objectives add zx.rl_rain dummy
execute unless data storage zx:config obj_rl_rain run data modify storage zx:config obj_rl_rain set value 1b

# 超•负•荷(超限) 的五个账(2026-10-09 批 F1; 后两个是 2026-10-10 补的回收账本)
#   zx.chg_ol   = 这次施法是不是超限版(cast 拍; tick/hit/end 都读它)
#   zx.chg_mode = **第二形态开关(0/1)**: = "当前正处于超载阶段" —— 闪电落点追加伤害 +
#                 攻击反噬 + **状态期间冷却冻结**(只在第二形态 chg_mode=1 时冻;
#                 第一阶段/第一形态不冻, 冷却照常自然走) +
#                 打够把冷却压到 0 才在状态结束时自动再开。
#                 ★ 它**会退**: 超载真的结束那一拍 `end -> mode_off` 置回 0(2026-10-10
#                   用户定稿, 之前是"进了就不退" ⇒ 加成焊在身上)。
#                 (2026-10-10 删 mode_tick; 见 tick ③ / freeze_cd / end_ol / mode_off)
#   zx.chg_atk  = 第二形态"加了 base_attack 多少"× 100(整数账本, mode_on 写 / mode_off 读)
#   zx.chg_mm   = 第二形态"当时的 max_mana"    × 100(整数账本, 同上; 加的是 ×0.005 = ×0.5)
#                 ★ 为什么要有账本: 那两条加成是 `stats/add` 加在**玩家存档属性**上的,
#                   不是效果、不会自己过期 ⇒ 收回时必须按账本**原样**减, 不能读面板反推
#                   (面板里混着别的装备加成, 反推会连别人的一起减掉)。
execute unless data storage zx:config obj_chg_ol run scoreboard objectives add zx.chg_ol dummy
execute unless data storage zx:config obj_chg_ol run data modify storage zx:config obj_chg_ol set value 1b
execute unless data storage zx:config obj_chg_mode run scoreboard objectives add zx.chg_mode dummy
execute unless data storage zx:config obj_chg_mode run data modify storage zx:config obj_chg_mode set value 1b
execute unless data storage zx:config obj_chg_atk run scoreboard objectives add zx.chg_atk dummy
execute unless data storage zx:config obj_chg_atk run data modify storage zx:config obj_chg_atk set value 1b
execute unless data storage zx:config obj_chg_mm run scoreboard objectives add zx.chg_mm dummy
execute unless data storage zx:config obj_chg_mm run data modify storage zx:config obj_chg_mm set value 1b

# 负离子(超限) 的两个账(2026-10-09 批 F1)
#   zx.an_ol    = 这次施法是不是超限版(cast 拍, 用完即清)
#   zx.an_boost = "8 秒雷劲"还剩几秒(lib/on_lightning 判, lib/second 每秒 -1)
#   zx.an_2nd   = 1 秒后那道雷还有几刻(core/tick 每刻推, 见 second_strike)
execute unless data storage zx:config obj_an_ol run scoreboard objectives add zx.an_ol dummy
execute unless data storage zx:config obj_an_ol run data modify storage zx:config obj_an_ol set value 1b
execute unless data storage zx:config obj_an_boost run scoreboard objectives add zx.an_boost dummy
execute unless data storage zx:config obj_an_boost run data modify storage zx:config obj_an_boost set value 1b
execute unless data storage zx:config obj_an_2nd run scoreboard objectives add zx.an_2nd dummy
execute unless data storage zx:config obj_an_2nd run data modify storage zx:config obj_an_2nd set value 1b

# 超限·沉锚(2026-10-23 批 K6) —— 注意前缀用 anc, 不要抢负离子(anion)的 an_*
#   zx.anc_ol   = 这次施法是不是超限版(cast ⓪.6 拍, impact 分档读)
#   zx.anc_back = "回到原处"窗口还剩几秒(cast 设 4, lib/second 每秒 -1, ol_back 清 0)
#   zx.anc_bt   = 锚点 marker 自己的剩余秒数(4 -> 0 由 lib/second 每秒 -1, 归零 kill)
#   zx.anc_own  = 锚点 marker 的主人指纹(施法者 UUID[0]), 多人同窗口时不串
execute unless data storage zx:config obj_anc_ol run scoreboard objectives add zx.anc_ol dummy
execute unless data storage zx:config obj_anc_ol run data modify storage zx:config obj_anc_ol set value 1b
execute unless data storage zx:config obj_anc_back run scoreboard objectives add zx.anc_back dummy
execute unless data storage zx:config obj_anc_back run data modify storage zx:config obj_anc_back set value 1b
execute unless data storage zx:config obj_anc_bt run scoreboard objectives add zx.anc_bt dummy
execute unless data storage zx:config obj_anc_bt run data modify storage zx:config obj_anc_bt set value 1b
execute unless data storage zx:config obj_anc_own run scoreboard objectives add zx.anc_own dummy
execute unless data storage zx:config obj_anc_own run data modify storage zx:config obj_anc_own set value 1b

# 超限·焦骨 / 重溟 / 陨星(2026-10-23 批 K6)
#   zx.scb_ol  = 这次施法是不是超限·焦骨(cast ⓪.6 拍; 分档读)
#   zx.db_ol   = 这次施法是不是超限·重溟(cast ⓪.6 拍; 消耗上限/倍率/领域参数都读它)
#   zx.db_r    = 领域(marker 身上)的半径 —— 普通 3 / 超限 5 / 合并后 8·11·14。
#                ★ 放计分项而不是 marker NBT: field_tick 每秒读一次, 不写盘就不标脏。
#   zx.mt_keep = 熔星形态是不是超限版(1 = 换手也不结束、被动照掷)。cast 拍, end 清 0。
#                ★ 只有"触发键"(cast)判手持; 时长/概率/每刻结算一律不判主手。
execute unless data storage zx:config obj_scb_ol run scoreboard objectives add zx.scb_ol dummy
execute unless data storage zx:config obj_scb_ol run data modify storage zx:config obj_scb_ol set value 1b
execute unless data storage zx:config obj_db_ol run scoreboard objectives add zx.db_ol dummy
execute unless data storage zx:config obj_db_ol run data modify storage zx:config obj_db_ol set value 1b
execute unless data storage zx:config obj_db_r run scoreboard objectives add zx.db_r dummy
execute unless data storage zx:config obj_db_r run data modify storage zx:config obj_db_r set value 1b
execute unless data storage zx:config obj_mt_keep run scoreboard objectives add zx.mt_keep dummy
execute unless data storage zx:config obj_mt_keep run data modify storage zx:config obj_mt_keep set value 1b

# 电弧超限(2026-10-12 批 I1)
#   zx.arc_ol = 离弦那刻"手里这把是不是超限版"的快照(1/0; shot 拍, hook_victim 分流读)
#               ★ 为什么存玩家身上: 配对/伤害都发生在**受害者那一侧**(附魔回调),
#                 那里拿不到射手的主手 —— 所以离弦时拍一次, 命中处按它分流
#                 (同 sd_ol / hd_ol / sb_ol 的口径)。
#   zx.arc_wt = 「放电锚」(marker)的剩余秒数(3 -> 0 由 lib/second 每秒 -1, 归零收尾)
#   zx.arc_dt = 配对**两端**的放电窗口剩余秒数(3 -> 0; 防同一对在 3 秒内重复起放电)
execute unless data storage zx:config obj_arc_ol run scoreboard objectives add zx.arc_ol dummy
execute unless data storage zx:config obj_arc_ol run data modify storage zx:config obj_arc_ol set value 1b
execute unless data storage zx:config obj_arc_wt run scoreboard objectives add zx.arc_wt dummy
execute unless data storage zx:config obj_arc_wt run data modify storage zx:config obj_arc_wt set value 1b
execute unless data storage zx:config obj_arc_dt run scoreboard objectives add zx.arc_dt dummy
execute unless data storage zx:config obj_arc_dt run data modify storage zx:config obj_arc_dt set value 1b

# ---- 批 11 · 剑(2026-10-12): 潮痕 / 灰度 / 缺月 ----
#   潮痕 / 灰度: 一次结算, 全程走 zx:work -> 不需要玩家级新计分项。
#   缺月(被动 + 主动"冻结冷却"):
#     zx.cr_t  = 冻结窗剩余刻(120 -> 0; core/tick 每刻扣, 归零时 freeze_end 结算)
#     zx.cr_b  = 本次冻结换来的伤害加成百分比(0..150; cap 拍, freeze_end 读, 用完归零)
#     zx.cr_lt = 平A去重刻(zx.cr_lt == #now 就跳过, 同 rb_lt/td_lt 的口径)
execute unless data storage zx:config obj_cr_t run scoreboard objectives add zx.cr_t dummy
execute unless data storage zx:config obj_cr_t run data modify storage zx:config obj_cr_t set value 1b
execute unless data storage zx:config obj_cr_b run scoreboard objectives add zx.cr_b dummy
execute unless data storage zx:config obj_cr_b run data modify storage zx:config obj_cr_b set value 1b
execute unless data storage zx:config obj_cr_lt run scoreboard objectives add zx.cr_lt dummy
execute unless data storage zx:config obj_cr_lt run data modify storage zx:config obj_cr_lt set value 1b

# 圣骸旧观察实体/标志升级清理, 防止旧 payload 调用新宏。
kill @e[type=minecraft:marker,tag=zx.sr_w]
tag @e[tag=zx.sr_w] remove zx.sr_w

# 爆裂黎明: /reload 时清掉上一轮残留的「魂灵之影」(铁傀儡)。
#   它们的寿命/攻击倒计时都在计分板上, 重载后没有驱动方会再推进,
#   留在场上就是两个打不掉的孤儿实体 —— 直接清掉(与其余纯表现实体同款)。
kill @e[tag=zx.bd_shade]
# ---- 批 11 · 斧(2026-10-12): 圣骸 / 沉锚 / 焦骨 ----
#   圣骸(被动留「遗骸」+ 主动每秒结算):
#     zx.sr_on = 主动状态剩余秒(12 -> 0; lib/second 每秒结算一次并 -1)
#     zx.sr_ft = 单个遗骸的准确到期 tick(出生刻 +240)
#     zx.sr_next = 施法者下一次脉冲 tick; zx.sr_on = 还剩几跳(12 -> 0)
#     zx.sr_lt = 玩家此前持有圣骸的标记, 用于离手时一次性清理临时监听
#     zx.sr_wt = 观察 marker 的剩余刻(110 -> 0), 仅真正击杀进度确认死亡
#   沉锚(被动 10% 触发 + 主动"牵引"):
#     zx.an_lt   = 平A去重刻(zx.an_lt == #now 就跳过, 口径同 td_lt / cr_lt)
#     zx.an_pull = 牵引剩余刻(14 -> 0 = 0.7 秒; core/tick 每刻把自己朝目标拉 0.5 格)
#   焦骨: 一次结算, 全程走 zx:work -> 不需要玩家级新计分项。
execute unless data storage zx:config obj_sr_next run scoreboard objectives add zx.sr_next dummy
execute unless data storage zx:config obj_sr_next run data modify storage zx:config obj_sr_next set value 1b
execute unless data storage zx:config obj_sr_on run scoreboard objectives add zx.sr_on dummy
execute unless data storage zx:config obj_sr_on run data modify storage zx:config obj_sr_on set value 1b
execute unless data storage zx:config obj_sr_ft run scoreboard objectives add zx.sr_ft dummy
execute unless data storage zx:config obj_sr_ft run data modify storage zx:config obj_sr_ft set value 1b
execute unless data storage zx:config obj_sr_lt run scoreboard objectives add zx.sr_lt dummy
execute unless data storage zx:config obj_sr_lt run data modify storage zx:config obj_sr_lt set value 1b
execute unless data storage zx:config obj_sr_wt run scoreboard objectives add zx.sr_wt dummy
execute unless data storage zx:config obj_sr_wt run data modify storage zx:config obj_sr_wt set value 1b
# 升级时补齐旧活跃技能的下一跳, 避免缺 sr_next 分数后永久选不中。
scoreboard players operation #sr_resume zx.meta = #now manacore.meta
scoreboard players add #sr_resume zx.meta 20
execute as @a[scores={zx.sr_on=1..}] unless score @s zx.sr_next = @s zx.sr_next run scoreboard players operation @s zx.sr_next = #sr_resume zx.meta
execute unless data storage zx:config obj_an_lt run scoreboard objectives add zx.an_lt dummy
execute unless data storage zx:config obj_an_lt run data modify storage zx:config obj_an_lt set value 1b
execute unless data storage zx:config obj_an_pull run scoreboard objectives add zx.an_pull dummy
execute unless data storage zx:config obj_an_pull run data modify storage zx:config obj_an_pull set value 1b
#   沉锚: zx.an_own = 挂在**目标生物**身上, 记"把我锁住的是谁"(施法者 UUID 的第 0 个 int)
#   —— 2026-10-23 卡顿修复引入: 配合标签 zx.an_lock, 让牵引/飞锚每刻找目标时
#   走"标签 + 整数比较"而不是 `@e[nbt={UUID:[I;...]}]`(后者 = 整份 NBT 序列化)。
execute unless data storage zx:config obj_an_own run scoreboard objectives add zx.an_own dummy
execute unless data storage zx:config obj_an_own run data modify storage zx:config obj_an_own set value 1b

# 深海的回响 · 连续水刃：96 帧待机、48 帧施法，复用原有施法标记与入口。
execute unless data storage zx:config obj_de_cast run scoreboard objectives add zx.de_cast dummy
execute unless data storage zx:config obj_de_cast run data modify storage zx:config obj_de_cast set value 1b
execute unless data storage zx:config obj_de_wave run scoreboard objectives add zx.de_wave dummy
execute unless data storage zx:config obj_de_wave run data modify storage zx:config obj_de_wave set value 1b
scoreboard players set #deidle zx.meta 48
scoreboard players set #dezero zx.meta 0
scoreboard players set #dewave zx.meta 0
# zx.de_t: 深海连锁每人自己的倒计时(还剩几 tick 推下一波)。
#   【为什么不用 schedule】见 cast ⑦ —— 同名 schedule 是全局一个槽, 会互相顶掉。
execute unless data storage zx:config obj_de_t run scoreboard objectives add zx.de_t dummy
execute unless data storage zx:config obj_de_t run data modify storage zx:config obj_de_t set value 1b

# ---- 四件新装备/武器专用的计分项(目标名上限 16 字符, 所以写得很短) ----
# 群星坠落之挽歌: se_mana = 已加进面板的魔力上限; se_regen = 受击后"每秒回10魔力"还剩几秒
execute unless data storage zx:config obj_se_mana run scoreboard objectives add zx.se_mana dummy
execute unless data storage zx:config obj_se_mana run data modify storage zx:config obj_se_mana set value 1b
execute unless data storage zx:config obj_se_regen run scoreboard objectives add zx.se_regen dummy
execute unless data storage zx:config obj_se_regen run data modify storage zx:config obj_se_regen set value 1b

# 黄昏黎明之交界: dd_mana 已加上限 / dd_set 套装已加上限 / dd_temp 临时上限剩余秒 /
#   dd_t1 击杀基础(+200) / dd_t2 击杀带标签额外(+100×X, X 见 dd_n) /
#   dd_app 已经加了多少(差值账本) / dd_know 判断"几条进度是不是同一次击杀" /
#   dd_n 本刻 kill_mark 进来几次(= 死者身上的通用标签数 = X, 2026-10-12 坑 138)
execute unless data storage zx:config obj_dd_mana run scoreboard objectives add zx.dd_mana dummy
execute unless data storage zx:config obj_dd_mana run data modify storage zx:config obj_dd_mana set value 1b
execute unless data storage zx:config obj_dd_set run scoreboard objectives add zx.dd_set dummy
execute unless data storage zx:config obj_dd_set run data modify storage zx:config obj_dd_set set value 1b
execute unless data storage zx:config obj_dd_temp run scoreboard objectives add zx.dd_temp dummy
execute unless data storage zx:config obj_dd_temp run data modify storage zx:config obj_dd_temp set value 1b
execute unless data storage zx:config obj_dd_t1 run scoreboard objectives add zx.dd_t1 dummy
execute unless data storage zx:config obj_dd_t1 run data modify storage zx:config obj_dd_t1 set value 1b
execute unless data storage zx:config obj_dd_t2 run scoreboard objectives add zx.dd_t2 dummy
execute unless data storage zx:config obj_dd_t2 run data modify storage zx:config obj_dd_t2 set value 1b
execute unless data storage zx:config obj_dd_app run scoreboard objectives add zx.dd_app dummy
execute unless data storage zx:config obj_dd_app run data modify storage zx:config obj_dd_app set value 1b
execute unless data storage zx:config obj_dd_know run scoreboard objectives add zx.dd_know dummy
execute unless data storage zx:config obj_dd_know run data modify storage zx:config obj_dd_know set value 1b
#   dd_n = "本刻 kill_mark 进来了几次" = **死者身上有几个通用标签** = 100×X 里的那个 X
#     (2026-10-12 坑 138): 5 条标签进度各自独立触发, 死者的 Tags 里有几个通用标签
#     就同时触发几条 ⇒ dd_n 天然等于 X。★ 必须跟着账本在 kill_init 里一起归零 ——
#     不归零的话第二次击杀会接着上次的数往上加, 基础版"只加一次"的判据就永远不成立。
execute unless data storage zx:config obj_dd_n run scoreboard objectives add zx.dd_n dummy
execute unless data storage zx:config obj_dd_n run data modify storage zx:config obj_dd_n set value 1b

# 寒鸦: cc_ice = 冰凌层数(0..3)
#   (这一发是第几层 / 伤害多少, 射击时写进 zx:data cc."<uuid>"; 命中由附魔回调处理)
execute unless data storage zx:config obj_cc_ice run scoreboard objectives add zx.cc_ice dummy
execute unless data storage zx:config obj_cc_ice run data modify storage zx:config obj_cc_ice set value 1b

# 幽匿残响: se_cry = 「悲鸣」点数(0..50)
#   (这一发的伤害/归属写进箭自己 data.zx.se + 射手名下 zx:data se."<uuid>")
execute unless data storage zx:config obj_se_cry run scoreboard objectives add zx.se_cry dummy
execute unless data storage zx:config obj_se_cry run data modify storage zx:config obj_se_cry set value 1b
# 幽匿残响: se_t = 箭身上自带的存活倒计时(30 秒 = 600 tick, 射进虚空/一直飞时的兜底)
#   ★ 2026-10-05 补: 以前忘了建 —— tick_live 里四条操作全失败, 于是那支箭
#     永远摘不掉 zx.se_live(每刻照旧结算范围伤害 + 发粒子)。
execute unless data storage zx:config obj_se_t run scoreboard objectives add zx.se_t dummy
execute unless data storage zx:config obj_se_t run data modify storage zx:config obj_se_t set value 1b

# ---- 批 11 · 弩(2026-10-12): 云迹 / 爆裂黎明 ----
#   云迹: ct_ft = 「领域」marker 的剩余秒数(生 5 -> 0; lib/second 每秒 -1, 归零 kill 自己)。
#     领域本体是 marker(标签 zx.ct_field, data.zx.uu = 射手 uuid 文本), 无玩家级账本。
#   爆裂黎明: bd_on = 玩家是否处于"以魂灵之影为弹药"的状态(= 场上还有自己召唤的影);
#     bd_ft = 单只魂灵之影的剩余秒数(20 -> 0; lib/second 每秒 -1, 归零 kill);
#     bd_cd = 单只魂灵之影"距下次攻击还剩几秒"(3 -> 0: 打一下并复位 3)。
# ★ 三把新弩的"这一发付过账没有" —— 一律记在**射手自己**身上, 不记在箭上:
#     dt_paid / ct_paid / bd_paid = 1 表示"最近那一发扣过魔力(或吃掉过一只影),
#     命中时该结算"。扣不起魔力的那一发会被 shot 显式写成 0。
#     bd_mode = 1 主力(×8 + 最大魔力×0.15) / 2 续轰(×4 + 最大魔力×0.08)。
#     ct_seek = 云迹"还有一发箭没认领"的补认窗口(见坑 141)。
#   【为什么不用箭上的标签】`shot_crossbow` 进度的触发时机**可能早于箭进世界**
#     (寒鸦 shot 里就记着这个已知风险) —— 那时 `tag=!zx.cc_seen` 的"新箭"还不
#     存在, 标记永远打不上, 于是整把弩静默失效。改记在射手身上就没有时序问题。
execute unless data storage zx:config obj_ct_ft run scoreboard objectives add zx.ct_ft dummy
execute unless data storage zx:config obj_ct_ft run data modify storage zx:config obj_ct_ft set value 1b
execute unless data storage zx:config obj_bd_on run scoreboard objectives add zx.bd_on dummy
execute unless data storage zx:config obj_bd_on run data modify storage zx:config obj_bd_on set value 1b
execute unless data storage zx:config obj_bd_ft run scoreboard objectives add zx.bd_ft dummy
execute unless data storage zx:config obj_bd_ft run data modify storage zx:config obj_bd_ft set value 1b
execute unless data storage zx:config obj_bd_cd run scoreboard objectives add zx.bd_cd dummy
execute unless data storage zx:config obj_bd_cd run data modify storage zx:config obj_bd_cd set value 1b
execute unless data storage zx:config obj_dt_paid run scoreboard objectives add zx.dt_paid dummy
execute unless data storage zx:config obj_dt_paid run data modify storage zx:config obj_dt_paid set value 1b
execute unless data storage zx:config obj_ct_paid run scoreboard objectives add zx.ct_paid dummy
execute unless data storage zx:config obj_ct_paid run data modify storage zx:config obj_ct_paid set value 1b
execute unless data storage zx:config obj_ct_seek run scoreboard objectives add zx.ct_seek dummy
execute unless data storage zx:config obj_ct_seek run data modify storage zx:config obj_ct_seek set value 1b
execute unless data storage zx:config obj_bd_paid run scoreboard objectives add zx.bd_paid dummy
execute unless data storage zx:config obj_bd_paid run data modify storage zx:config obj_bd_paid set value 1b

# ---- 批 15-1(2026-10-15)· 弩四件: 眠羽 / 烬弦 / 逆弦 / 黯日 ----
#   四把弩的"这一发付过账没有" —— 与前三把(龙舌/云迹/爆裂黎明)同口径, 记在**射手自己**
#   身上(上面 dt_paid 那段已解释: 记在箭上有"进度早于箭进世界"的时序坑, 坑 141)。
#     fs_paid / es_paid / rs_paid / ds_paid = 1 表示"最近那一发扣过魔力, 命中时该结算";
#     扣不起魔力的那一发会被各自的 shot 显式写成 0(否则会给下一发用)。
#   两把**带节流**的弩另记"下次可触发"的时刻(#now 时间轴, 口径同 em_gate):
#     es_gate = 烬弦"整段效果"的下次可触发刻(+160 刻 = 8 秒)
#     ds_gate = 黯日"整段效果"的下次可触发刻(+400 刻 = 20 秒)
execute unless data storage zx:config obj_fs_paid run scoreboard objectives add zx.fs_paid dummy
execute unless data storage zx:config obj_fs_paid run data modify storage zx:config obj_fs_paid set value 1b
execute unless data storage zx:config obj_es_paid run scoreboard objectives add zx.es_paid dummy
execute unless data storage zx:config obj_es_paid run data modify storage zx:config obj_es_paid set value 1b
execute unless data storage zx:config obj_rs_paid run scoreboard objectives add zx.rs_paid dummy
execute unless data storage zx:config obj_rs_paid run data modify storage zx:config obj_rs_paid set value 1b
execute unless data storage zx:config obj_ds_paid run scoreboard objectives add zx.ds_paid dummy
execute unless data storage zx:config obj_ds_paid run data modify storage zx:config obj_ds_paid set value 1b
execute unless data storage zx:config obj_es_gate run scoreboard objectives add zx.es_gate dummy
execute unless data storage zx:config obj_es_gate run data modify storage zx:config obj_es_gate set value 1b
execute unless data storage zx:config obj_ds_gate run scoreboard objectives add zx.ds_gate dummy
execute unless data storage zx:config obj_ds_gate run data modify storage zx:config obj_ds_gate set value 1b

# ---- 批 K7(2026-10-23)· 弩超限四件的"这一发是超限弩射的"标记 ----
#   为什么统一叫 *_ol: 弩的命中结算全在附魔回调里, 那时手里拿的未必还是这把弩 ⇒
#   "超限"必须在 shot 那一刻写进**射手身上**(与 *_paid 同一层, 坑 141)。
#   · rs_ov = 逆弦(用 ov 而不是 ol: 该文件里 #rs_ol 已经是"进了强化档"的局部假名)
#   · ds_ol = 黯日
#   · dt_ol = 龙舌
#   (退弦的 bs_ol 放在批 13 那段一起写了, 见 obj_bs_ol)
execute unless data storage zx:config obj_rs_ov run scoreboard objectives add zx.rs_ov dummy
execute unless data storage zx:config obj_rs_ov run data modify storage zx:config obj_rs_ov set value 1b
execute unless data storage zx:config obj_ds_ol run scoreboard objectives add zx.ds_ol dummy
execute unless data storage zx:config obj_ds_ol run data modify storage zx:config obj_ds_ol set value 1b
execute unless data storage zx:config obj_dt_ol run scoreboard objectives add zx.dt_ol dummy
execute unless data storage zx:config obj_dt_ol run data modify storage zx:config obj_dt_ol set value 1b

# ---- 批 15-2(2026-10-15)· 消耗钩子四件: 归息 / 殓丝 / 回潮扣 / 烛跬 ----
#   三件"不可再次触发 / 持续 N 秒"的记账，一律记在**玩家自己**身上:
#     lb_cd    = 归息"下次可触发"的 tick 时刻(+160 刻 = 8 秒)
#     cfs_cd   = 殓丝「殓结」"下次可获得"的 tick 时刻(+240 刻 = 12 秒)
#     cfs_end  = 殓丝「殓结」的**到期刻**(+160 刻 = 8 秒)
#   ★ 存"时刻"而不是倒计时: 不用有人每刻去扣, 也没有"玩家下线期间倒计时不走"的问题
#     (口径同 frostmirror 的 fm_cd / ember 的 em_gate)。
#   回潮扣 / 烛跬 没有需要跨刻保存的状态 —— 它们的效果当场就兑现完了。
execute unless data storage zx:config obj_lb_cd run scoreboard objectives add zx.lb_cd dummy
execute unless data storage zx:config obj_lb_cd run data modify storage zx:config obj_lb_cd set value 1b
execute unless data storage zx:config obj_cfs_cd run scoreboard objectives add zx.cfs_cd dummy
execute unless data storage zx:config obj_cfs_cd run data modify storage zx:config obj_cfs_cd set value 1b
execute unless data storage zx:config obj_cfs_end run scoreboard objectives add zx.cfs_end dummy
execute unless data storage zx:config obj_cfs_end run data modify storage zx:config obj_cfs_end set value 1b

# ---- 批 15-3(2026-10-15)· 命中/受击四件 + 每秒一件: 刺纹 / 沸痕 / 轻枕 / 渡梦 / 滩纹 ----
#   ① 差值制账本(记在**玩家**身上, "已经加了多少", 每秒/每刻重算差值):
#      ah_hp  = 生命值上限已经加了多少(armor_hp 管; 沸痕 +4)
#      bv_arm = 护甲值已经加了多少(滩纹 armor_sync 管; 5 格内有渊海生物时 +2)
#   ② "不可再次触发"的节流(存**下次可触发刻**, 口径同 frostmirror/em_gate):
#      boil_cd / thorn_cd / lpillow_cd / cdream_cd
execute unless data storage zx:config obj_ah_hp run scoreboard objectives add zx.ah_hp dummy
execute unless data storage zx:config obj_ah_hp run data modify storage zx:config obj_ah_hp set value 1b
execute unless data storage zx:config obj_bv_arm run scoreboard objectives add zx.bv_arm dummy
execute unless data storage zx:config obj_bv_arm run data modify storage zx:config obj_bv_arm set value 1b
execute unless data storage zx:config obj_boil_cd run scoreboard objectives add zx.boil_cd dummy
execute unless data storage zx:config obj_boil_cd run data modify storage zx:config obj_boil_cd set value 1b
execute unless data storage zx:config obj_thorn_cd run scoreboard objectives add zx.thorn_cd dummy
execute unless data storage zx:config obj_thorn_cd run data modify storage zx:config obj_thorn_cd set value 1b
execute unless data storage zx:config obj_lpillow_cd run scoreboard objectives add zx.lpillow_cd dummy
execute unless data storage zx:config obj_lpillow_cd run data modify storage zx:config obj_lpillow_cd set value 1b
execute unless data storage zx:config obj_cdream_cd run scoreboard objectives add zx.cdream_cd dummy
execute unless data storage zx:config obj_cdream_cd run data modify storage zx:config obj_cdream_cd set value 1b
#   ★ 2026-10-16 撤: 此处曾有 zx.bt_imm(沸痕"灭火后 1 秒不着火"的每刻窗口)。
#     已证实**原版禁止写玩家 NBT**(/data 与 /execute store 对玩家一律抛
#     `commands.data.entity.invalid` = "Unable to modify player data")⇒ `Fire` 根本写不进去,
#     那个窗口从头到尾是空转。
#   ★ 同日再改(当天下午): 先试过"1 秒 fire_resistance", 但**抗火在 Java 版不消除着火**
#     (只能挡伤害) ⇒ 最终落地 = 触发瞬间在头顶放一格**细雪**(`setblock ~ ~1 ~ powder_snow keep`),
#     它是 JE 里唯一能真正熄灭燃烧实体、又会被燃烧者自己撞毁自清的方块。
#     锚点与回收见 boil_trace/on_hurt ⑦ 与 boil_trace/pw_off、core/tick 的 marker 派发
#     (那两个 marker 派发不需要账本, 故此处不登记)。

# ---- 批 15-4(2026-10-16)· 五套双件套(燧行/潮线/缝心/浅梦/残烛, 10 件) ----
#   ① 节流账本(存**下次可触发刻**, 口径同 boil_cd / frostmirror/em_gate):
#      fh_cd    燧帽: 近战点流火 8 秒
#      ss_cd    烟履: 近战收割流火 3 秒
#      tw_cd    候潮: 技能命中点渊海 10 秒
#      tw_set_cd 潮线套装: 减主手技能冷却 6 秒
#      ns_cd    针眠: 命中点噬心 10 秒
#      cr_cd    绯缝: 真伤回复 6 秒
#      cc_cd    焦衣: 流火转夜火 10 秒
#      cs_set_cd 残烛套装: 消费夜火后加基础攻击力 8 秒
#   ② 积攒 / 计数账本:
#      cr_knit    绯结层数(0..3)                       —— 缝心套装
#      cr_knit_cd 绯结积攒节流 6 秒                    —— 缝心套装
#      cr_amp_cd  绯结兑现(+15% 真伤)节流 5 秒         —— 缝心套装
#      ms_cnt     镜寐"每攻击 3 次"的计数(0..3)
#      ms_arm     镜寐"下一次命中要挂白昼梦"的标记(0/1)
#      lp_set_cd  浅梦套装: 挂上白昼梦后的节流 10 秒
#      lp_regen_end 浅梦套装"4 秒内每秒额外回 5 魔力"的到期刻
#      cs_batk    残烛套装: 已经加了多少基础攻击力(×100 整数, 回收时按它减回)
#      cs_end     残烛套装: 那 4 秒的到期刻
#   ★ cs_* 属烛跬(candle_step)、cr_* 属绯缝(crimson_seam)、tw_* 属候潮(tide_watch),
#     ms_* 属镜寐(mirror_sleep)、lp_* 属轻枕(light_pillow), 与本批之前的件无重名。
execute unless data storage zx:config obj_fh_cd run scoreboard objectives add zx.fh_cd dummy
execute unless data storage zx:config obj_fh_cd run data modify storage zx:config obj_fh_cd set value 1b
execute unless data storage zx:config obj_ss_cd run scoreboard objectives add zx.ss_cd dummy
execute unless data storage zx:config obj_ss_cd run data modify storage zx:config obj_ss_cd set value 1b
execute unless data storage zx:config obj_tw_cd run scoreboard objectives add zx.tw_cd dummy
execute unless data storage zx:config obj_tw_cd run data modify storage zx:config obj_tw_cd set value 1b
execute unless data storage zx:config obj_tw_set_cd run scoreboard objectives add zx.tw_set_cd dummy
execute unless data storage zx:config obj_tw_set_cd run data modify storage zx:config obj_tw_set_cd set value 1b
execute unless data storage zx:config obj_ns_cd run scoreboard objectives add zx.ns_cd dummy
execute unless data storage zx:config obj_ns_cd run data modify storage zx:config obj_ns_cd set value 1b
execute unless data storage zx:config obj_cr_cd run scoreboard objectives add zx.cr_cd dummy
execute unless data storage zx:config obj_cr_cd run data modify storage zx:config obj_cr_cd set value 1b
execute unless data storage zx:config obj_cc_cd run scoreboard objectives add zx.cc_cd dummy
execute unless data storage zx:config obj_cc_cd run data modify storage zx:config obj_cc_cd set value 1b
execute unless data storage zx:config obj_cs_set_cd run scoreboard objectives add zx.cs_set_cd dummy
execute unless data storage zx:config obj_cs_set_cd run data modify storage zx:config obj_cs_set_cd set value 1b
execute unless data storage zx:config obj_cr_knit run scoreboard objectives add zx.cr_knit dummy
execute unless data storage zx:config obj_cr_knit run data modify storage zx:config obj_cr_knit set value 1b
execute unless data storage zx:config obj_cr_knit_cd run scoreboard objectives add zx.cr_knit_cd dummy
execute unless data storage zx:config obj_cr_knit_cd run data modify storage zx:config obj_cr_knit_cd set value 1b
execute unless data storage zx:config obj_cr_amp_cd run scoreboard objectives add zx.cr_amp_cd dummy
execute unless data storage zx:config obj_cr_amp_cd run data modify storage zx:config obj_cr_amp_cd set value 1b
execute unless data storage zx:config obj_ms_cnt run scoreboard objectives add zx.ms_cnt dummy
execute unless data storage zx:config obj_ms_cnt run data modify storage zx:config obj_ms_cnt set value 1b
execute unless data storage zx:config obj_ms_arm run scoreboard objectives add zx.ms_arm dummy
execute unless data storage zx:config obj_ms_arm run data modify storage zx:config obj_ms_arm set value 1b
execute unless data storage zx:config obj_lp_set_cd run scoreboard objectives add zx.lp_set_cd dummy
execute unless data storage zx:config obj_lp_set_cd run data modify storage zx:config obj_lp_set_cd set value 1b
execute unless data storage zx:config obj_lp_regen_end run scoreboard objectives add zx.lp_regen_end dummy
execute unless data storage zx:config obj_lp_regen_end run data modify storage zx:config obj_lp_regen_end set value 1b
execute unless data storage zx:config obj_cs_batk run scoreboard objectives add zx.cs_batk dummy
execute unless data storage zx:config obj_cs_batk run data modify storage zx:config obj_cs_batk set value 1b
execute unless data storage zx:config obj_cs_end run scoreboard objectives add zx.cs_end dummy
execute unless data storage zx:config obj_cs_end run data modify storage zx:config obj_cs_end set value 1b

# ---- 批 13(2026-10-13)· 过渡/终端补缺四件 ----
#   退弦(弩): bs_paid = "这一发付过账"(写在射手身上, 坑 141)
#             bs_n    = 已射击次数(0..2, 满 3 归零)
#             bs_ready= "下一次命中要打 12 点保底"(命中结算读完即清)
execute unless data storage zx:config obj_bs_paid run scoreboard objectives add zx.bs_paid dummy
execute unless data storage zx:config obj_bs_paid run data modify storage zx:config obj_bs_paid set value 1b
execute unless data storage zx:config obj_bs_n run scoreboard objectives add zx.bs_n dummy
execute unless data storage zx:config obj_bs_n run data modify storage zx:config obj_bs_n set value 1b
execute unless data storage zx:config obj_bs_ready run scoreboard objectives add zx.bs_ready dummy
execute unless data storage zx:config obj_bs_ready run data modify storage zx:config obj_bs_ready set value 1b
#   ★ 批 K7(2026-10-23)超限·退弦 ----
#     bs_ol   = 玩家侧: "这一发是超限弩射出的"(写在射手身上, 与 bs_paid 同构)
#     bsb_n   = 目标侧: 被动已翻倍次数(0..3, 满 3 不再涨)
#     bsb_t   = 目标侧: 主层剩余刻(6 秒 = 120; 归 0 时 bsb_n 一并清 0)
#     bsb_x   = 目标侧: 「弦满额外再翻倍一次」那一层(0/1, 独立计时)
#     bsb_xt  = 目标侧: 额外层剩余刻(12 秒 = 240)
#   为什么要记在**目标身上**: 文案是"对该生物射中一次则该固定伤害翻倍" ⇒ 每只独立。
#   为什么用 4 个而不是 2 个: 主层(最多 3 层, 6 秒)与弦满额外层(1 层, 12 秒)的
#   计时与上限都不同, 混在一个计分项里无法表达"额外那层单独持续 12 秒"。
execute unless data storage zx:config obj_bs_ol run scoreboard objectives add zx.bs_ol dummy
execute unless data storage zx:config obj_bs_ol run data modify storage zx:config obj_bs_ol set value 1b
execute unless data storage zx:config obj_bsb_n run scoreboard objectives add zx.bsb_n dummy
execute unless data storage zx:config obj_bsb_n run data modify storage zx:config obj_bsb_n set value 1b
execute unless data storage zx:config obj_bsb_t run scoreboard objectives add zx.bsb_t dummy
execute unless data storage zx:config obj_bsb_t run data modify storage zx:config obj_bsb_t set value 1b
execute unless data storage zx:config obj_bsb_x run scoreboard objectives add zx.bsb_x dummy
execute unless data storage zx:config obj_bsb_x run data modify storage zx:config obj_bsb_x set value 1b
execute unless data storage zx:config obj_bsb_xt run scoreboard objectives add zx.bsb_xt dummy
execute unless data storage zx:config obj_bsb_xt run data modify storage zx:config obj_bsb_xt set value 1b
#   冰鉴(副手): fm_cd = 内置冷却的**到期时刻**(now + 80; 存到期刻而不是倒计时,
#     与法杖普攻门控同招 —— 不需要每刻有人去扣它)
execute unless data storage zx:config obj_fm_cd run scoreboard objectives add zx.fm_cd dummy
execute unless data storage zx:config obj_fm_cd run data modify storage zx:config obj_fm_cd set value 1b
#   长明(副手): el_cd = 灯灵的攻击倒计时(2 秒; 由**驱动方**每秒 -1, 坑 120)
execute unless data storage zx:config obj_el_cd run scoreboard objectives add zx.el_cd dummy
execute unless data storage zx:config obj_el_cd run data modify storage zx:config obj_el_cd set value 1b
#   引雷针(法杖): tr_due = 预约落雷的**到期刻**(now + 20; 由 core/tick 每刻判)
execute unless data storage zx:config obj_tr_due run scoreboard objectives add zx.tr_due dummy
execute unless data storage zx:config obj_tr_due run data modify storage zx:config obj_tr_due set value 1b
#   引雷针·超限(2026-10-23 批 K9):
#     zx.tr_ol    = 主人这一轮主动是不是超限档(0/1; 排队的雷跨刻, 要按它加 ×0.1 附伤)
#     zx.tr_bonus = 手上有没有"下次技能额外再放一次"的增益(0/1)
#     zx.tr_bdue  = 那个增益的**到期刻**(now + 240 = 12 秒)
#     ★ 三个都记在**玩家**身上: 落雷时执行者就是主人(排队 marker 用 UUID 换回来的),
#       直接 @s 落分最稳, 不用反查。
execute unless data storage zx:config obj_tr_ol run scoreboard objectives add zx.tr_ol dummy
execute unless data storage zx:config obj_tr_ol run data modify storage zx:config obj_tr_ol set value 1b
execute unless data storage zx:config obj_tr_bonus run scoreboard objectives add zx.tr_bonus dummy
execute unless data storage zx:config obj_tr_bonus run data modify storage zx:config obj_tr_bonus set value 1b
execute unless data storage zx:config obj_tr_bdue run scoreboard objectives add zx.tr_bdue dummy
execute unless data storage zx:config obj_tr_bdue run data modify storage zx:config obj_tr_bdue set value 1b
#     zx.tr_hn / zx.tr_he = 记在**被雷笼罩的生物**身上: 5 秒窗口内被劈的次数 / 窗口到期刻。
#     ★ 记在生物身上的临时分数: 窗口过期即归零(bolt_cnt ⓪), 不会无限累加。
execute unless data storage zx:config obj_tr_hn run scoreboard objectives add zx.tr_hn dummy
execute unless data storage zx:config obj_tr_hn run data modify storage zx:config obj_tr_hn set value 1b
execute unless data storage zx:config obj_tr_he run scoreboard objectives add zx.tr_he dummy
execute unless data storage zx:config obj_tr_he run data modify storage zx:config obj_tr_he set value 1b
execute unless data storage zx:config obj_bd_mode run scoreboard objectives add zx.bd_mode dummy
execute unless data storage zx:config obj_bd_mode run data modify storage zx:config obj_bd_mode set value 1b

# 虹彩: rb_end = 「漫彩」结束时刻(框架时钟) / rb_born = 施加时刻(判"是否5秒内结束")
#       rb_u0..u3 = 施加者 UUID(结算伤害时反查归属)
#   (存在**被打中那只生物**身上, 每秒由 lib/second 推)
execute unless data storage zx:config obj_rb_end run scoreboard objectives add zx.rb_end dummy
execute unless data storage zx:config obj_rb_end run data modify storage zx:config obj_rb_end set value 1b
execute unless data storage zx:config obj_rb_born run scoreboard objectives add zx.rb_born dummy
execute unless data storage zx:config obj_rb_born run data modify storage zx:config obj_rb_born set value 1b
execute unless data storage zx:config obj_rb_u0 run scoreboard objectives add zx.rb_u0 dummy
execute unless data storage zx:config obj_rb_u0 run data modify storage zx:config obj_rb_u0 set value 1b
execute unless data storage zx:config obj_rb_u1 run scoreboard objectives add zx.rb_u1 dummy
execute unless data storage zx:config obj_rb_u1 run data modify storage zx:config obj_rb_u1 set value 1b
execute unless data storage zx:config obj_rb_u2 run scoreboard objectives add zx.rb_u2 dummy
execute unless data storage zx:config obj_rb_u2 run data modify storage zx:config obj_rb_u2 set value 1b
execute unless data storage zx:config obj_rb_u3 run scoreboard objectives add zx.rb_u3 dummy
execute unless data storage zx:config obj_rb_u3 run data modify storage zx:config obj_rb_u3 set value 1b

# 清醒梦: ld_dream = 射手身上的「梦回」层数(0..5)
#         ld_end   = 被打中那只生物身上"受击额外真伤"的结束时刻(框架时钟)
#         ld_x     = 触发大效果时的「梦回」层数(=伤害/持续秒数的 X, 存在那只生物身上)
#         ld_u0..u3 = 施法者 UUID(结算真伤时反查归属)
#   (ld_end / ld_x / ld_u0..u3 都存在**被标记的那只生物**身上)
execute unless data storage zx:config obj_ld_dream run scoreboard objectives add zx.ld_dream dummy
execute unless data storage zx:config obj_ld_dream run data modify storage zx:config obj_ld_dream set value 1b
execute unless data storage zx:config obj_ld_end run scoreboard objectives add zx.ld_end dummy
execute unless data storage zx:config obj_ld_end run data modify storage zx:config obj_ld_end set value 1b
execute unless data storage zx:config obj_ld_x run scoreboard objectives add zx.ld_x dummy
execute unless data storage zx:config obj_ld_x run data modify storage zx:config obj_ld_x set value 1b
execute unless data storage zx:config obj_ld_u0 run scoreboard objectives add zx.ld_u0 dummy
execute unless data storage zx:config obj_ld_u0 run data modify storage zx:config obj_ld_u0 set value 1b
execute unless data storage zx:config obj_ld_u1 run scoreboard objectives add zx.ld_u1 dummy
execute unless data storage zx:config obj_ld_u1 run data modify storage zx:config obj_ld_u1 set value 1b
execute unless data storage zx:config obj_ld_u2 run scoreboard objectives add zx.ld_u2 dummy
execute unless data storage zx:config obj_ld_u2 run data modify storage zx:config obj_ld_u2 set value 1b
execute unless data storage zx:config obj_ld_u3 run scoreboard objectives add zx.ld_u3 dummy
execute unless data storage zx:config obj_ld_u3 run data modify storage zx:config obj_ld_u3 set value 1b

# 燎原: ly_aura = 光环还剩几秒(0 = 没有光环) / ly_timer = 离下一次灼烧还有几秒
#        ly_times = 这一次光环里已经灼烧了几次(第 3/6/9 次附加「流火」)
execute unless data storage zx:config obj_ly_aura run scoreboard objectives add zx.ly_aura dummy
execute unless data storage zx:config obj_ly_aura run data modify storage zx:config obj_ly_aura set value 1b
execute unless data storage zx:config obj_ly_timer run scoreboard objectives add zx.ly_timer dummy
execute unless data storage zx:config obj_ly_timer run data modify storage zx:config obj_ly_timer set value 1b
execute unless data storage zx:config obj_ly_times run scoreboard objectives add zx.ly_times dummy
execute unless data storage zx:config obj_ly_times run data modify storage zx:config obj_ly_times set value 1b

# 公共: fz_end = 冻结/时停的结束时刻(用框架时钟 #now)
execute unless data storage zx:config obj_fz_end run scoreboard objectives add zx.fz_end dummy
execute unless data storage zx:config obj_fz_end run data modify storage zx:config obj_fz_end set value 1b

# 烈火，残躯: fb_lava 熔浆层数
execute unless data storage zx:config obj_fb_lava run scoreboard objectives add zx.fb_lava dummy
execute unless data storage zx:config obj_fb_lava run data modify storage zx:config obj_fb_lava set value 1b

# 自己包用的两个小常量(框架只给了 #10/#100/#15/#16/#scale):
#   #2 用于"当前魔力 ×2 < 上限"这种比较, #3 用于"每 3 秒一次"的取模
scoreboard players set #2 zx.meta 2
scoreboard players set #3 zx.meta 3
#   #4 用于"连乘两次 ×2"(批二 10-20: 写成两条相邻的 `*= #2` 会被 check 的
#   "相邻重复"规则拦下, 合并成一次 `*= #4` 语义完全相同且更省一行)。
scoreboard players set #4 zx.meta 4
# 焚舟烈空换算用的常量:
#   #20 = 每 20 点烈空算一档, #30 = 每档 +30 魔力上限
#   ⚠️ 这两个不建的话 `#im_p /= #20` 会变成除以 0 —— 命令报错会中断整个
#   second_one, 现象就是"烈空在涨, 但上限不加、buff 也不倒计时"。
scoreboard players set #20 zx.meta 20
scoreboard players set #30 zx.meta 30

# 技能伤害默认用哪个伤害类型。
#   sweetdream:skill = 本包注册的类型, 和玩家平砍一样吃护甲, 但**不被受伤无敌帧吃掉**
#     (它被挂在原版标签 minecraft:bypasses_cooldown 里)。
#   ⚠️ 这是"注册表"类内容(damage_type), **只在进世界时加载** ——
#      改了它 / 第一次装它之后, 光 /reload 不够, 要退出世界再进来。
#   【保险开关】万一它没生效(所有技能忽然没伤害), 在游戏里执行:
#       /data modify storage zx:config damage_type set value "minecraft:player_attack"
#       /reload
#   就能立刻退回原版平砍类型(代价是多段伤害又会撞无敌帧)。
#   这个字段**只在不存在时**写, 所以你自己改过的值不会被覆盖。
execute unless data storage zx:config damage_type run data modify storage zx:config damage_type set value "sweetdream:skill"

# 清掉残留的法球(比如 /reload 时正在飞的那几颗)。法球是实体, 留着才是真残留;
# 而"读档以后接着飞"没有任何意义, 所以每次加载一律清空。
kill @e[tag=zx.ball]
# ★ 2026-10-21: 法球的两个临时计分项也要在加载时全局归零 ★
#   zx.ball_touch / zx.bt 是"本刻临时标记", 正常由 ball/tick_target、ball/fire 当场清;
#   但旧版判据范围写错(查询全维度、清理 4 格), 已经在存档里留下了一批脏分 ——
#   脏分会让**下一颗球直接判命中并当场消失**(详见 tick_target ②的说明)。
#   这里读取时全维度扫一次把它洗干净, 之后每刻只走 4 格, 不再全量遍历。
#   三个维度都要扫: load 的默认上下文只在主世界, 脏分可能留在下界/末地。
execute in minecraft:overworld run scoreboard players reset @e[distance=0..,scores={zx.ball_touch=1}] zx.ball_touch
execute in minecraft:the_nether run scoreboard players reset @e[distance=0..,scores={zx.ball_touch=1}] zx.ball_touch
execute in minecraft:the_end run scoreboard players reset @e[distance=0..,scores={zx.ball_touch=1}] zx.ball_touch
execute in minecraft:overworld run scoreboard players reset @e[distance=0..,scores={zx.bt=1}] zx.bt
execute in minecraft:the_nether run scoreboard players reset @e[distance=0..,scores={zx.bt=1}] zx.bt
execute in minecraft:the_end run scoreboard players reset @e[distance=0..,scores={zx.bt=1}] zx.bt
# 同理: 清掉残留的「共鸣水晶」marker(批3 共鸣), 免得 /reload 后留下孤儿。
kill @e[tag=zx.ch_cry]
# 同理: 清掉残留的“色彩”item_display(批3 调色盘; 2026-10-08 从 marker 换成可见光球)。
kill @e[tag=zx.pal_col]
# 同理: 清掉残留的“漩涡”item_display(批3 海棠; 2026-10-08 从 marker 换成蓝色漩涡贴图)。
kill @e[tag=zx.bg_vtx]
# 同理: 清掉残留的“旋风”marker(批3 风帆)。
kill @e[tag=zx.sl_vtx]
# ★ 批 D 的「陨石」(zx.mt_rock) 和「领域」(zx.tc_dom) 故意**不在这里清** ★
#   · 陨石: 只活 4 刻, 靠 core/tick 的每刻链推进 —— /reload 后链会重跑, 它自己会落地收尾,
#     清掉反而会在半空"凭空消失"。没有孤儿风险就不需要这个兜底。
#   · 领域: 术阵 marker(zx.tc_field)本来就不在 reload 清理名单里(和裂缝/万念领域一样),
#     领域实体也一样能跨 reload 存活 —— 它该继续躺在术阵上。清掉它 = 术阵还在、圈没了。
#     万一是 marker 被清掉的情况, core/tick 那句"附近没有术阵就自杀"下一瞬就收掉它。

# ============================================================
# 把备份架子住的区块永久加载
# ------------------------------------------------------------
# 【为什么需要】架子固定在主世界 (0.5, -60, 0.5) —— 基岩层下面, 但不是虚空
#   (世界最低点是 -64, 所以在世界内, 吃不到虚空伤害; 虚空伤害是无视无敌的,
#    真塞进虚空它会被销毁, 然后自愈逻辑反复重造, 直接实体爆炸)。
# 【forceload 干什么】强制那个区块一直加载并参与实体运算, 于是:
#   - 玩家跑到天涯海角, 备份和回手照样有效(选择器能找到它)
#   - 不再出现"区块没加载 -> 找不到 -> 误判成丢了"的重复生成
# 【想换位置】改这里的坐标 + summon_named_stand 里的 summon 坐标, 两处要一致。
# 【重复执行安全】forceload add 对已加载的区块是无害的。
# ============================================================
execute in minecraft:overworld run forceload add 0 0

# 升级 / 超限 的定义表(框架, 见 升级与超限系统-设计.md)
function sweetdream:upgrade/def/load
function sweetdream:overlimit/def/load

# 标签体系的运行时反查表(批 A; 三张表 tgdef / tge / tgidx, 见 标签体系-设计.md)
function sweetdream:tg/def/load

# 技能倍率三条通道的"口径表"(只给面板归类用, 见 lib/skill_mul/def)
function sweetdream:lib/skill_mul/def

# 通用标签 v2：创建缓存目标，迁移旧状态并重建显示。
function sweetdream:tag/load

# 时停独立计时(冷冻 zx.fz_end / 时停 zx.ts_end) + 原本是否 NoAI 的备份
execute unless data storage zx:config obj_ts_end run scoreboard objectives add zx.ts_end dummy
execute unless data storage zx:config obj_ts_end run data modify storage zx:config obj_ts_end set value 1b
execute unless data storage zx:config obj_noai_bak run scoreboard objectives add zx.noai_bak dummy
execute unless data storage zx:config obj_noai_bak run data modify storage zx:config obj_noai_bak set value 1b
# 引梦镰横扫: 注册 zx.sd_t / zx.sd_id / zx.sd_leave
function sweetdream:equipment/sword/sickle_dreams/sweep/load
# 余烬+焚舟: 烈空层数/模式/上限账本/套装 buff
execute unless data storage zx:config obj_lk run scoreboard objectives add zx.lk dummy
execute unless data storage zx:config obj_lk run data modify storage zx:config obj_lk set value 1b
execute unless data storage zx:config obj_lk_mode run scoreboard objectives add zx.lk_mode dummy
execute unless data storage zx:config obj_lk_mode run data modify storage zx:config obj_lk_mode set value 1b
execute unless data storage zx:config obj_im_mk run scoreboard objectives add zx.im_mk dummy
execute unless data storage zx:config obj_im_mk run data modify storage zx:config obj_im_mk set value 1b
execute unless data storage zx:config obj_im_buff run scoreboard objectives add zx.im_buff dummy
execute unless data storage zx:config obj_im_buff run data modify storage zx:config obj_im_buff set value 1b
execute unless data storage zx:config obj_im_buff_mk run scoreboard objectives add zx.im_buff_mk dummy
execute unless data storage zx:config obj_im_buff_mk run data modify storage zx:config obj_im_buff_mk set value 1b
execute unless data storage zx:config obj_em_mana run scoreboard objectives add zx.em_mana dummy
execute unless data storage zx:config obj_em_mana run data modify storage zx:config obj_em_mana set value 1b
execute unless data storage zx:config obj_im_set20 run scoreboard objectives add zx.im_set20 dummy
execute unless data storage zx:config obj_im_set20 run data modify storage zx:config obj_im_set20 set value 1b
execute unless data storage zx:config obj_em_conv run scoreboard objectives add zx.em_conv dummy
execute unless data storage zx:config obj_em_conv run data modify storage zx:config obj_em_conv set value 1b
# 余烬"夜火怪也补流火"的节流闸 = 该生物下次可补的 tick 时刻(见 ember/top_up)
execute unless data storage zx:config obj_em_gate run scoreboard objectives add zx.em_gate dummy
execute unless data storage zx:config obj_em_gate run data modify storage zx:config obj_em_gate set value 1b
execute unless data storage zx:config obj_em_seen run scoreboard objectives add zx.em_seen dummy
execute unless data storage zx:config obj_em_seen run data modify storage zx:config obj_em_seen set value 1b
#   zx.em_burn = 余烬「上一次扫描时还在燃烧」的边沿标记(1 = 有)。
#     ★ 2026-10-20 卡顿修复: 从实体 tag 改成计分项。scan_one 每 5 刻做一次
#       「清掉 9 格内全部标记 → 给还在燃烧的重新打上」, tag 版等于每 5 刻
#       写一遍范围内所有生物的实体 NBT(chunk 反复变脏)。计分项语义完全等价:
#       1 = 上次扫到时在烧、0 = 不在烧, 没分数的目标等同"从没打过标记"。
execute unless data storage zx:config obj_em_burn run scoreboard objectives add zx.em_burn dummy
execute unless data storage zx:config obj_em_burn run data modify storage zx:config obj_em_burn set value 1b
# 余烬高频扫描的次数锚(每 5 刻 +1, 见 core/tick 那段分频) ——
#   排查"余烬还是不触发"时先看它涨不涨: 不涨 = 扫描压根没跑。
execute unless data storage zx:config obj_em_scan run scoreboard objectives add zx.em_scan dummy
execute unless data storage zx:config obj_em_scan run data modify storage zx:config obj_em_scan set value 1b
# 焚舟实际点火次数(用来核对"点了几次火 vs 余烬转了几次")
execute unless data storage zx:config obj_im_ignite run scoreboard objectives add zx.im_ignite dummy
execute unless data storage zx:config obj_im_ignite run data modify storage zx:config obj_im_ignite set value 1b
execute unless data storage zx:config obj_em_mana50 run scoreboard objectives add zx.em_mana50 dummy
execute unless data storage zx:config obj_em_mana50 run data modify storage zx:config obj_em_mana50 set value 1b
# 脑髓蛭: 魔力上限账本 / 回魔修正是否已挂 / 攻击力账本
execute unless data storage zx:config obj_bl_mana run scoreboard objectives add zx.bl_mana dummy
execute unless data storage zx:config obj_bl_mana run data modify storage zx:config obj_bl_mana set value 1b
execute unless data storage zx:config obj_bl_regen run scoreboard objectives add zx.bl_regen dummy
execute unless data storage zx:config obj_bl_regen run data modify storage zx:config obj_bl_regen set value 1b
execute unless data storage zx:config obj_bl_atk run scoreboard objectives add zx.bl_atk dummy
execute unless data storage zx:config obj_bl_atk run data modify storage zx:config obj_bl_atk set value 1b
# 脑髓蛭 · 超限(2026-10-07):
#   zx.bl_rv = 已挂上的回魔修正值(3 普通 / 5 超限 / 0 没戴) —— 换头/超限后要能重挂
#   zx.bl_gu = 「蛊虫」层数(0..10)
#   zx.bl_gm = 「蛊虫」是否已进入"消耗模式"(1 = 满过 10 层, 之后只消耗不再累积)
#   zx.bl_ta = 攻击给的**定时**基础攻击力加成(整数, 过期作废)
#   zx.bl_te = 上面那条的到期时刻(框架时钟 #now)
execute unless data storage zx:config obj_bl_rv run scoreboard objectives add zx.bl_rv dummy
execute unless data storage zx:config obj_bl_rv run data modify storage zx:config obj_bl_rv set value 1b
execute unless data storage zx:config obj_bl_gu run scoreboard objectives add zx.bl_gu dummy
execute unless data storage zx:config obj_bl_gu run data modify storage zx:config obj_bl_gu set value 1b
execute unless data storage zx:config obj_bl_gm run scoreboard objectives add zx.bl_gm dummy
execute unless data storage zx:config obj_bl_gm run data modify storage zx:config obj_bl_gm set value 1b
execute unless data storage zx:config obj_bl_ta run scoreboard objectives add zx.bl_ta dummy
execute unless data storage zx:config obj_bl_ta run data modify storage zx:config obj_bl_ta set value 1b
execute unless data storage zx:config obj_bl_te run scoreboard objectives add zx.bl_te dummy
execute unless data storage zx:config obj_bl_te run data modify storage zx:config obj_bl_te set value 1b
#   zx.bl_lt = 上一次"攻击结算"的游戏刻(#now) —— 用来把**同一次平A**只算一次:
#      player_hurt_entity 是"每命中一个生物触发一次", 横扫打 3 只就是 3 次;
#      用"这刻已经算过就跳过"去重(玩家 2026-10-07 口径: 每次攻击只攒 1 层)
execute unless data storage zx:config obj_bl_lt run scoreboard objectives add zx.bl_lt dummy
execute unless data storage zx:config obj_bl_lt run data modify storage zx:config obj_bl_lt set value 1b
#   同类的"每次攻击只算一次"去重戳(2026-10-07 第十四批, 文案写「每次攻击(后)」的入口):
#     zx.ac_lt = 天使核心(hit) / zx.mt_lt = 陨星(hit) / zx.up_lt = 升级·魔力增殖(on_hit)
#     zx.rm_lt = 热熔(hit 的①「熔解」状态那半; ②是"攻击到生物"口径, 不走去重)
#   ★ 三件各用一个计分项, **不共用** —— 同一次平A可能同时命中多个入口(主手斧头 +
#     武器上的魔力增殖), 共用一个戳会互相吞掉对方(先跑的那件把戳写了, 后面的被跳过)。
execute unless data storage zx:config obj_ac_lt run scoreboard objectives add zx.ac_lt dummy
execute unless data storage zx:config obj_ac_lt run data modify storage zx:config obj_ac_lt set value 1b
execute unless data storage zx:config obj_mt_lt run scoreboard objectives add zx.mt_lt dummy
execute unless data storage zx:config obj_mt_lt run data modify storage zx:config obj_mt_lt set value 1b
execute unless data storage zx:config obj_up_lt run scoreboard objectives add zx.up_lt dummy
execute unless data storage zx:config obj_up_lt run data modify storage zx:config obj_up_lt set value 1b
execute unless data storage zx:config obj_rm_lt run scoreboard objectives add zx.rm_lt dummy
execute unless data storage zx:config obj_rm_lt run data modify storage zx:config obj_rm_lt set value 1b
# 脊骨共生: 魔力上限账本 / 护甲账本 / 生命上限账本
execute unless data storage zx:config obj_ss_mana run scoreboard objectives add zx.ss_mana dummy
execute unless data storage zx:config obj_ss_mana run data modify storage zx:config obj_ss_mana set value 1b
execute unless data storage zx:config obj_ss_armor run scoreboard objectives add zx.ss_armor dummy
execute unless data storage zx:config obj_ss_armor run data modify storage zx:config obj_ss_armor set value 1b
execute unless data storage zx:config obj_ss_hp run scoreboard objectives add zx.ss_hp dummy
execute unless data storage zx:config obj_ss_hp run data modify storage zx:config obj_ss_hp set value 1b
# 脊骨共生 · 超限(2026-10-07): 击杀给的**定时**护甲/生命加成(和 brain_leech 的 ta/te 同理)
#   zx.ss_ta = 定时加成值(整数) / zx.ss_te = 到期时刻(框架时钟 #now)
execute unless data storage zx:config obj_ss_ta run scoreboard objectives add zx.ss_ta dummy
execute unless data storage zx:config obj_ss_ta run data modify storage zx:config obj_ss_ta set value 1b
execute unless data storage zx:config obj_ss_te run scoreboard objectives add zx.ss_te dummy
execute unless data storage zx:config obj_ss_te run data modify storage zx:config obj_ss_te set value 1b
# 魔力上限下限保护垫了多少(见 lib/mana_floor)
execute unless data storage zx:config obj_floor_mana run scoreboard objectives add zx.floor_mana dummy
execute unless data storage zx:config obj_floor_mana run data modify storage zx:config obj_floor_mana set value 1b

# ---- 装备额外回魔的账本(两个) ----
#   【为什么需要】前置包只认"每秒恢复速率"(regen modifier), 而静脉泵/桂冠/挽歌/
#     黄昏黎明套装是**自己到点直接 add 魔力**的 —— 前置包不知道, 于是 debug 里
#     "回魔/秒"那一行永远显示 0, 玩家明明在回魔却看不见。
#   【为什么要两个】event/second 里各家装备排在前面, lib/second / debug/second 在后。
#     所以: 各家装备每秒往 regen_extra 里累加; debug/second(列表最后一个)负责
#     "把 regen_extra 抄进 regen_last, 再把 regen_extra 清零" —— 于是
#     regen_last 永远是"上一秒完整的一整秒里实收了多少", 读它的人不受顺序影响。
execute unless data storage zx:config obj_regen_extra run scoreboard objectives add zx.regen_extra dummy
execute unless data storage zx:config obj_regen_extra run data modify storage zx:config obj_regen_extra set value 1b
execute unless data storage zx:config obj_regen_last run scoreboard objectives add zx.regen_last dummy
execute unless data storage zx:config obj_regen_last run data modify storage zx:config obj_regen_last set value 1b
# 异彩: 魔力上限账本
execute unless data storage zx:config obj_ir_mana run scoreboard objectives add zx.ir_mana dummy
execute unless data storage zx:config obj_ir_mana run data modify storage zx:config obj_ir_mana set value 1b
# 幻昼: 魔力上限账本 / 套装攻击力账本(已挂多少) / 两条限时窗口各剩几秒
execute unless data storage zx:config obj_mr_mana run scoreboard objectives add zx.mr_mana dummy
execute unless data storage zx:config obj_mr_mana run data modify storage zx:config obj_mr_mana set value 1b
execute unless data storage zx:config obj_mr_atk run scoreboard objectives add zx.mr_atk dummy
execute unless data storage zx:config obj_mr_atk run data modify storage zx:config obj_mr_atk set value 1b
# 幻昼「受击」: 层数 zx.mr_atk1 (无上限; 每次受到伤害 +1 层, 每层基础攻击力 +1, 5 秒逐层到期)
execute unless data storage zx:config obj_mr_atk1 run scoreboard objectives add zx.mr_atk1 dummy
execute unless data storage zx:config obj_mr_atk1 run data modify storage zx:config obj_mr_atk1 set value 1b
# 幻昼「白昼」: 层数 zx.mr_atk2 (0..10; 攻击附有白昼梦的生物 +1 层, 每层基础攻击力 +2, 8 秒逐层到期)
execute unless data storage zx:config obj_mr_atk2 run scoreboard objectives add zx.mr_atk2 dummy
execute unless data storage zx:config obj_mr_atk2 run data modify storage zx:config obj_mr_atk2 set value 1b
# 幻昼套装"每层独立到期"的环形记账格(见 equipment/armor/mirage/expire):
#   +1 环 6 格(每层活 5 秒, 不设上限)  +2 环 9 格(每层活 8 秒, 上限 10 层)
execute unless data storage zx:config obj_mr_a0 run scoreboard objectives add zx.mr_a0 dummy
execute unless data storage zx:config obj_mr_a0 run data modify storage zx:config obj_mr_a0 set value 1b
execute unless data storage zx:config obj_mr_a1 run scoreboard objectives add zx.mr_a1 dummy
execute unless data storage zx:config obj_mr_a1 run data modify storage zx:config obj_mr_a1 set value 1b
execute unless data storage zx:config obj_mr_a2 run scoreboard objectives add zx.mr_a2 dummy
execute unless data storage zx:config obj_mr_a2 run data modify storage zx:config obj_mr_a2 set value 1b
execute unless data storage zx:config obj_mr_a3 run scoreboard objectives add zx.mr_a3 dummy
execute unless data storage zx:config obj_mr_a3 run data modify storage zx:config obj_mr_a3 set value 1b
execute unless data storage zx:config obj_mr_a4 run scoreboard objectives add zx.mr_a4 dummy
execute unless data storage zx:config obj_mr_a4 run data modify storage zx:config obj_mr_a4 set value 1b
execute unless data storage zx:config obj_mr_a5 run scoreboard objectives add zx.mr_a5 dummy
execute unless data storage zx:config obj_mr_a5 run data modify storage zx:config obj_mr_a5 set value 1b
execute unless data storage zx:config obj_mr_b0 run scoreboard objectives add zx.mr_b0 dummy
execute unless data storage zx:config obj_mr_b0 run data modify storage zx:config obj_mr_b0 set value 1b
execute unless data storage zx:config obj_mr_b1 run scoreboard objectives add zx.mr_b1 dummy
execute unless data storage zx:config obj_mr_b1 run data modify storage zx:config obj_mr_b1 set value 1b
execute unless data storage zx:config obj_mr_b2 run scoreboard objectives add zx.mr_b2 dummy
execute unless data storage zx:config obj_mr_b2 run data modify storage zx:config obj_mr_b2 set value 1b
execute unless data storage zx:config obj_mr_b3 run scoreboard objectives add zx.mr_b3 dummy
execute unless data storage zx:config obj_mr_b3 run data modify storage zx:config obj_mr_b3 set value 1b
execute unless data storage zx:config obj_mr_b4 run scoreboard objectives add zx.mr_b4 dummy
execute unless data storage zx:config obj_mr_b4 run data modify storage zx:config obj_mr_b4 set value 1b
execute unless data storage zx:config obj_mr_b5 run scoreboard objectives add zx.mr_b5 dummy
execute unless data storage zx:config obj_mr_b5 run data modify storage zx:config obj_mr_b5 set value 1b
execute unless data storage zx:config obj_mr_b6 run scoreboard objectives add zx.mr_b6 dummy
execute unless data storage zx:config obj_mr_b6 run data modify storage zx:config obj_mr_b6 set value 1b
execute unless data storage zx:config obj_mr_b7 run scoreboard objectives add zx.mr_b7 dummy
execute unless data storage zx:config obj_mr_b7 run data modify storage zx:config obj_mr_b7 set value 1b
execute unless data storage zx:config obj_mr_b8 run scoreboard objectives add zx.mr_b8 dummy
execute unless data storage zx:config obj_mr_b8 run data modify storage zx:config obj_mr_b8 set value 1b

# ============================================================
# ---- 七把新武器(2026-10-04)专用的计分项 ----
# ------------------------------------------------------------
# 沉渊(chenyuan): 无独立状态(靠通用标签「渊海」和冷却本身)
#   超限(2026-10-23 批 K5):
#   zx.cy_mmn = "下一个最大魔力值技能 +10%" 还挂着(1 = 有; 兑现一次置 0)
#   zx.cy_mml = 兑现的同刻去重戳(一次技能多段/多目标只算一次)
execute unless data storage zx:config obj_cy_mmn run scoreboard objectives add zx.cy_mmn dummy
execute unless data storage zx:config obj_cy_mmn run data modify storage zx:config obj_cy_mmn set value 1b
execute unless data storage zx:config obj_cy_mml run scoreboard objectives add zx.cy_mml dummy
execute unless data storage zx:config obj_cy_mml run data modify storage zx:config obj_cy_mml set value 1b
# 影刃(shadow_blade): sb_end = "5 秒内击杀"窗口的结束时刻(框架时钟 #now)
execute unless data storage zx:config obj_sb_end run scoreboard objectives add zx.sb_end dummy
execute unless data storage zx:config obj_sb_end run data modify storage zx:config obj_sb_end set value 1b
# 热熔(remelt): rm_on = 熔解状态还剩几秒(玩家身上) / rm_t = 被融甲生物还剩几秒(生物身上)
execute unless data storage zx:config obj_rm_on run scoreboard objectives add zx.rm_on dummy
execute unless data storage zx:config obj_rm_on run data modify storage zx:config obj_rm_on set value 1b
execute unless data storage zx:config obj_rm_t run scoreboard objectives add zx.rm_t dummy
execute unless data storage zx:config obj_rm_t run data modify storage zx:config obj_rm_t set value 1b
# 陨星(meteor): mt_on = 陨星状态还剩几秒(玩家身上)
execute unless data storage zx:config obj_mt_on run scoreboard objectives add zx.mt_on dummy
execute unless data storage zx:config obj_mt_on run data modify storage zx:config obj_mt_on set value 1b
#   ★ 批 D 新增: mt_rk = 落下来的那颗「陨石」还剩几刻落地(0..4) —— 记在陨石实体自己身上
#     (2026-10-08)。见 meteor/rock + rock_tick + core/tick。
#     ⚠️ 名字别叫 zx.mr_t —— 那个是漫步冥河的计分项, 占用中。
execute unless data storage zx:config obj_mt_rk run scoreboard objectives add zx.mt_rk dummy
execute unless data storage zx:config obj_mt_rk run data modify storage zx:config obj_mt_rk set value 1b
# 天穹(skyvault): sv_launch = 跃升后还需几 tick 才能再次施放(0/无 = 可以起手)
execute unless data storage zx:config obj_sv_launch run scoreboard objectives add zx.sv_launch dummy
execute unless data storage zx:config obj_sv_launch run data modify storage zx:config obj_sv_launch set value 1b
# 天穹: 缓缓跃升的步数(0..30, 每刻 +1, 到 31 由 rise_end 收尾) —— 见 skyvault/rise_step
execute unless data storage zx:config obj_sv_rise run scoreboard objectives add zx.sv_rise dummy
execute unless data storage zx:config obj_sv_rise run data modify storage zx:config obj_sv_rise set value 1b
# 天穹: 俯冲的"安全步数"(60 步, 用尽强制 impact, 防在地洞里无限冲)
#   ★ 2026-10-05 补: 以前忘了建 —— dive_ready 的 set 60、dive_tick 的 remove
#     和"步数用尽 -> impact"三条全失败, 只有"撞墙/落地/撞到怪"能收尾。
execute unless data storage zx:config obj_sv_step run scoreboard objectives add zx.sv_step dummy
execute unless data storage zx:config obj_sv_step run data modify storage zx:config obj_sv_step set value 1b
# 天穹「升痕」层数(0..3, 挂在**生物**身上; 用计分项而不是标签, 因为要数层)
execute unless data storage zx:config obj_stg run scoreboard objectives add zx.stg dummy
execute unless data storage zx:config obj_stg run data modify storage zx:config obj_stg set value 1b
# 超限·天穹(2026-10-23 批 K4): 两个"这一次施法是不是超限 / 是不是连锁段"的标记(玩家身上)
#   zx.sv_ol = 1 = 这一次用的是超限版(cast 拍; impact 拍成 #sv_ol 快照后清零)
#   zx.sv_cn = 1 = 这一次俯冲是"消耗 ≥10 层升痕"之后的**连锁段**
#              (ol_chain 设, 连锁段的 impact 末尾清零; 它同时决定跃升高度 0.6 格/刻)
#   ★ 都是"一次施法内"的临时标记, 但必须进 player_reset 清单(玩家在俯冲途中死亡重生
#     会重建实体, 残留的 sv_cn 会让下一次跃升变成 6 格、并且跃完自动俯冲)。
execute unless data storage zx:config obj_sv_ol run scoreboard objectives add zx.sv_ol dummy
execute unless data storage zx:config obj_sv_ol run data modify storage zx:config obj_sv_ol set value 1b
execute unless data storage zx:config obj_sv_cn run scoreboard objectives add zx.sv_cn dummy
execute unless data storage zx:config obj_sv_cn run data modify storage zx:config obj_sv_cn set value 1b
# 天穹「升痕」衰减计时(秒, 挂在**生物**身上): 每 15 秒 −1 层, 见 status/decay_stg
execute unless data storage zx:config obj_stg_t run scoreboard objectives add zx.stg_t dummy
execute unless data storage zx:config obj_stg_t run data modify storage zx:config obj_stg_t set value 1b
# 天使核心「圣痕」: 只需要"在不在", 用原生标签 zx.status.shenghen(没接头顶图标系统)
# 圣痕衰减计时(秒, 挂在**生物**身上): 15 秒后自动消失, 见 status/decay_shenghen
execute unless data storage zx:config obj_sh_t run scoreboard objectives add zx.sh_t dummy
execute unless data storage zx:config obj_sh_t run data modify storage zx:config obj_sh_t set value 1b
# 天使核心: ac_d = 第一段与第二段之间的"技能间隔"倒计时(tick), 见 angel_core/cast
execute unless data storage zx:config obj_ac_d run scoreboard objectives add zx.ac_d dummy
execute unless data storage zx:config obj_ac_d run data modify storage zx:config obj_ac_d set value 1b
# 极光与幻梦: ad_bell = 时停期间"周期钟声"的剩余秒数, 见 aurora_dream/bell
execute unless data storage zx:config obj_ad_bell run scoreboard objectives add zx.ad_bell dummy
execute unless data storage zx:config obj_ad_bell run data modify storage zx:config obj_ad_bell set value 1b

# 共振: 魔力上限账本(已加了多少, 穿上 +120 / 脱下 -120, 见 resonance/apply_mana)
execute unless data storage zx:config obj_rs_mana run scoreboard objectives add zx.rs_mana dummy
execute unless data storage zx:config obj_rs_mana run data modify storage zx:config obj_rs_mana set value 1b

# 炉心: 三条加成各自的账本(已加了多少) + 燃灰层数 + 衰减计时(秒)
execute unless data storage zx:config obj_fc_mana run scoreboard objectives add zx.fc_mana dummy
execute unless data storage zx:config obj_fc_mana run data modify storage zx:config obj_fc_mana set value 1b
execute unless data storage zx:config obj_fc_hp run scoreboard objectives add zx.fc_hp dummy
execute unless data storage zx:config obj_fc_hp run data modify storage zx:config obj_fc_hp set value 1b
execute unless data storage zx:config obj_fc_atk run scoreboard objectives add zx.fc_atk dummy
execute unless data storage zx:config obj_fc_atk run data modify storage zx:config obj_fc_atk set value 1b
execute unless data storage zx:config obj_fc_ash run scoreboard objectives add zx.fc_ash dummy
execute unless data storage zx:config obj_fc_ash run data modify storage zx:config obj_fc_ash set value 1b
execute unless data storage zx:config obj_fc_t run scoreboard objectives add zx.fc_t dummy
execute unless data storage zx:config obj_fc_t run data modify storage zx:config obj_fc_t set value 1b
# 炉心超限(2026-10-10 批 H): zx.fc_hold = 「燃灰」12 层冻结还剩几秒(结束时直接降到 8 层)
execute unless data storage zx:config obj_fc_hold run scoreboard objectives add zx.fc_hold dummy
execute unless data storage zx:config obj_fc_hold run data modify storage zx:config obj_fc_hold set value 1b

# ---- 第五批(2026-10-05)第一批效果: 万念 / 千散 的换手 ----
#   zx.mq_wait = 预约后还剩几 tick 才动刀(等通用回手线跑完, 见 myriad/swap)
#   zx.mq_dir  = 换的方向: 1 = 万念 -> 千散; 2 = 千散 -> 万念
#   ⚠️ 两个都是"只给带 zx.mq_swap 标签的人用"的临时变量, 不进面板注册表。
execute unless data storage zx:config obj_mq_wait run scoreboard objectives add zx.mq_wait dummy
execute unless data storage zx:config obj_mq_wait run data modify storage zx:config obj_mq_wait set value 1b
execute unless data storage zx:config obj_mq_dir run scoreboard objectives add zx.mq_dir dummy
execute unless data storage zx:config obj_mq_dir run data modify storage zx:config obj_mq_dir set value 1b

# ---- 超限·万念(2026-10-08): 剑魂 / 居合 / 领域 / 特殊技能窗口 ----
#   zx.mq_ol   = 手里这把是不是超限版(1/0)。★ 它是"本次施法的快照": cast 开头
#                由 is_ol 读出来存到玩家身上, 后面 hit_go / tail / swap 都读它 ——
#                因为换手之后"手里那把"已经变了, 再判一次会判错。
#   zx.mq_soul = 剑魂数(0..5)
#   zx.mq_base = 本次技能**开始前**的剑魂数(技能结束时要清掉的就是这一批)
#   zx.mq_ju   = 「居合」还剩几秒
#   zx.mq_jb   = 居合攒下的独立乘区层数(每切换 +1 => 下一次技能伤害 +20%)
#   zx.mq_win  = 特殊技能窗口还剩几秒(-1 = 没有窗口; >=1 才放得出特殊技能)
#   zx.mq_h5   = 领域里的平A计数(满 5 开窗口)
#   zx.mq_hl   = 平A去重的那一个游戏刻(口径: 一次平A算一次, 见 on_hit)
#   zx.mq_ft   = 领域 marker 还剩几秒
#   zx.mq_fa   = 领域画圈的当前角度(每秒 +18)
#   zx.mq_sa   = 剑魂画圈的当前角度(每刻 +5)
#   ⚠️ "用了但没建"的计分项 = 那条命令静默失败、机制不触发(不报错、不写日志),
#     所以这十一项必须在这里建全。
#   ★ 还有一组**不是计分项、挂在 zx.meta 上的"本次施法通道标记"**(假玩家, 不用建):
#     #mq_isq(手里是千散) / #mq_qs(本次打的是**千散口径**) / #mq_pas(本次是**被动兑现**)
#     / #mq_sw(本次切换了形态) / #mq_rep(本次要打几次) / #mq_echo(本次单次伤害)
#     / #mq_in(在不在自己领域里)
#     —— 它们只描述"这一发", 由 tail 末尾(或调用方)复位。判据一律写成 `matches 1`
#        (假玩家没 set 过时 `matches 0` 不成立, 见 RULES「没分数≠0」)。
#     剑魂口径就挂在这上面: `#mq_qs` + `#mq_pas` 一起决定"清剑魂"(见 myriad/tail ④)。
execute unless data storage zx:config obj_mq_ol run scoreboard objectives add zx.mq_ol dummy
execute unless data storage zx:config obj_mq_ol run data modify storage zx:config obj_mq_ol set value 1b
execute unless data storage zx:config obj_mq_soul run scoreboard objectives add zx.mq_soul dummy
execute unless data storage zx:config obj_mq_soul run data modify storage zx:config obj_mq_soul set value 1b
execute unless data storage zx:config obj_mq_base run scoreboard objectives add zx.mq_base dummy
execute unless data storage zx:config obj_mq_base run data modify storage zx:config obj_mq_base set value 1b
execute unless data storage zx:config obj_mq_ju run scoreboard objectives add zx.mq_ju dummy
execute unless data storage zx:config obj_mq_ju run data modify storage zx:config obj_mq_ju set value 1b
execute unless data storage zx:config obj_mq_jb run scoreboard objectives add zx.mq_jb dummy
execute unless data storage zx:config obj_mq_jb run data modify storage zx:config obj_mq_jb set value 1b
execute unless data storage zx:config obj_mq_win run scoreboard objectives add zx.mq_win dummy
execute unless data storage zx:config obj_mq_win run data modify storage zx:config obj_mq_win set value 1b
execute unless data storage zx:config obj_mq_h5 run scoreboard objectives add zx.mq_h5 dummy
execute unless data storage zx:config obj_mq_h5 run data modify storage zx:config obj_mq_h5 set value 1b
execute unless data storage zx:config obj_mq_hl run scoreboard objectives add zx.mq_hl dummy
execute unless data storage zx:config obj_mq_hl run data modify storage zx:config obj_mq_hl set value 1b
execute unless data storage zx:config obj_mq_ft run scoreboard objectives add zx.mq_ft dummy
execute unless data storage zx:config obj_mq_ft run data modify storage zx:config obj_mq_ft set value 1b
execute unless data storage zx:config obj_mq_fa run scoreboard objectives add zx.mq_fa dummy
execute unless data storage zx:config obj_mq_fa run data modify storage zx:config obj_mq_fa set value 1b
execute unless data storage zx:config obj_mq_sa run scoreboard objectives add zx.mq_sa dummy
execute unless data storage zx:config obj_mq_sa run data modify storage zx:config obj_mq_sa set value 1b

# ---- 第五批(2026-10-05)第二批效果: 苦痛 / 三法杖 / 两甲 ----
# 苦痛(agony): zx.ag_end = 被锁生物身上"效果结束时刻"(框架时钟, 挂在生物身上)
execute unless data storage zx:config obj_ag_end run scoreboard objectives add zx.ag_end dummy
execute unless data storage zx:config obj_ag_end run data modify storage zx:config obj_ag_end set value 1b
# 偏振光(polarized_light): zx.pl_t = 光束还剩几秒(玩家身上, 0 = 没在放)
execute unless data storage zx:config obj_pl_t run scoreboard objectives add zx.pl_t dummy
execute unless data storage zx:config obj_pl_t run data modify storage zx:config obj_pl_t set value 1b
# 偏振光超限(2026-10-10 批 G):
#   zx.pl_ol = 施法那刻"是不是超限版"的快照(second/core-tick 的分流判据, 每次施法都写)
#   zx.pl_ct = 超限版结算闸的计数器(10 刻 = 0.5 秒结算一次, 20 刻 = 1 秒并扣 pl_t 1 秒)
execute unless data storage zx:config obj_pl_ol run scoreboard objectives add zx.pl_ol dummy
execute unless data storage zx:config obj_pl_ol run data modify storage zx:config obj_pl_ol set value 1b
execute unless data storage zx:config obj_pl_ct run scoreboard objectives add zx.pl_ct dummy
execute unless data storage zx:config obj_pl_ct run data modify storage zx:config obj_pl_ct set value 1b
# ★ 2026-10-20 卡顿修复: 光线的两个"一次性戳"从实体 tag 改成计分项。
#   原先 beam/beam_one 每刻给**生物** add 再 remove zx.pl_cur / zx.pl_d ——
#   每刻都让那只生物所在 chunk 变脏, EntityStorage 于是每刻重写整份 chunk
#   (与 2026-10-20 法球那次是同一个机理)。计分项只动内存里的分数,
#   不碰实体 NBT。语义完全等价: 1 = 有戳, 0 = 没戳。
#   zx.pl_cur = 本条光线正在画的目标(beam_step 的"到达"判据)
#   zx.pl_d   = 本刻已经画过的目标(超限三道光线逐轮筛选用, 每刻开头整体归零)
execute unless data storage zx:config obj_pl_cur run scoreboard objectives add zx.pl_cur dummy
execute unless data storage zx:config obj_pl_cur run data modify storage zx:config obj_pl_cur set value 1b
execute unless data storage zx:config obj_pl_d run scoreboard objectives add zx.pl_d dummy
execute unless data storage zx:config obj_pl_d run data modify storage zx:config obj_pl_d set value 1b
# ★ 2026-10-20 第二轮: zx.pl_f = 铺点降频计数器(0 -> 1 -> 2 -> 0 循环, =1 的那刻跳过)。
#   光点从"每刻一遍"改成"每 2 刻一遍": end_rod 粒子寿命约 0.5~0.75 秒, 0.1 秒补一次
#   视觉上完全连续, 而递归开销直接减半(超限三道光的递归是最贵的一段)。
execute unless data storage zx:config obj_pl_f run scoreboard objectives add zx.pl_f dummy
execute unless data storage zx:config obj_pl_f run data modify storage zx:config obj_pl_f set value 1b
# ★ 同一批卡顿修复(2026-10-20): 另外两处"每刻给生物写实体 tag"的临时戳。
#   · zx.se_path = 幽匿残响(超限箭矢飞行期间)以箭为中心框内全部生物的本刻标记,
#                 tick_live 每刻"清全部→框内重打", 于是每刻写 N 个生物的 NBT。
#   · zx.fi_on   = 裂地「裂缝锁」的"上一刻是否在圈内"标记, 同样每刻重算。
#   两者都只在自己那一个函数里用(已 grep 全包确认), 换成计分项后语义不变。
execute unless data storage zx:config obj_se_path run scoreboard objectives add zx.se_path dummy
execute unless data storage zx:config obj_se_path run data modify storage zx:config obj_se_path set value 1b
execute unless data storage zx:config obj_fi_on run scoreboard objectives add zx.fi_on dummy
execute unless data storage zx:config obj_fi_on run data modify storage zx:config obj_fi_on set value 1b
# 启示录(apocalypse):
#   zx.ap_pre = 每刻魔力快照(×100, 判"这次技能消耗了多少蓝"用, 见 apocalypse/snap)
#   zx.ap_on  = 灾示状态还剩几秒(玩家身上, 0 = 没在灾示)
#   zx.ap_t3  = 离下一次灾示还有几秒
#   zx.ap_t4  = 离下一次换页还有几秒
#   zx.ap_n   = 还没消耗的「启示」页数(0..3)
#   zx.ap_done= 本刻是否已经记过一页(0/1; 每刻由 snap 清零 —— 两条记页链
#               cooldown_start / 弩的 shot 可能同一刻都命中, 靠它限成一页)
#   zx.ap_p1/p2/p3 = 第 1/2/3 页记录的魔力值(×100 定点; 消耗一页整列左移一格)
#   zx.ap_cur = 当前页的魔力值(×100; 灾示伤害的基数)
execute unless data storage zx:config obj_ap_pre run scoreboard objectives add zx.ap_pre dummy
execute unless data storage zx:config obj_ap_pre run data modify storage zx:config obj_ap_pre set value 1b
execute unless data storage zx:config obj_ap_on run scoreboard objectives add zx.ap_on dummy
execute unless data storage zx:config obj_ap_on run data modify storage zx:config obj_ap_on set value 1b
execute unless data storage zx:config obj_ap_t3 run scoreboard objectives add zx.ap_t3 dummy
execute unless data storage zx:config obj_ap_t3 run data modify storage zx:config obj_ap_t3 set value 1b
execute unless data storage zx:config obj_ap_t4 run scoreboard objectives add zx.ap_t4 dummy
execute unless data storage zx:config obj_ap_t4 run data modify storage zx:config obj_ap_t4 set value 1b
execute unless data storage zx:config obj_ap_n run scoreboard objectives add zx.ap_n dummy
execute unless data storage zx:config obj_ap_n run data modify storage zx:config obj_ap_n set value 1b
execute unless data storage zx:config obj_ap_done run scoreboard objectives add zx.ap_done dummy
execute unless data storage zx:config obj_ap_done run data modify storage zx:config obj_ap_done set value 1b
execute unless data storage zx:config obj_ap_p1 run scoreboard objectives add zx.ap_p1 dummy
execute unless data storage zx:config obj_ap_p1 run data modify storage zx:config obj_ap_p1 set value 1b
execute unless data storage zx:config obj_ap_p2 run scoreboard objectives add zx.ap_p2 dummy
execute unless data storage zx:config obj_ap_p2 run data modify storage zx:config obj_ap_p2 set value 1b
execute unless data storage zx:config obj_ap_p3 run scoreboard objectives add zx.ap_p3 dummy
execute unless data storage zx:config obj_ap_p3 run data modify storage zx:config obj_ap_p3 set value 1b
# 启示录超限(批 K8): 第 4 页 / 快捷栏那件是否超限版 / 本次是否"至少三页"
execute unless data storage zx:config obj_ap_p4 run scoreboard objectives add zx.ap_p4 dummy
execute unless data storage zx:config obj_ap_p4 run data modify storage zx:config obj_ap_p4 set value 1b
execute unless data storage zx:config obj_ap_ol run scoreboard objectives add zx.ap_ol dummy
execute unless data storage zx:config obj_ap_ol run data modify storage zx:config obj_ap_ol set value 1b
execute unless data storage zx:config obj_ap_big run scoreboard objectives add zx.ap_big dummy
execute unless data storage zx:config obj_ap_big run data modify storage zx:config obj_ap_big set value 1b
execute unless data storage zx:config obj_ap_cur run scoreboard objectives add zx.ap_cur dummy
execute unless data storage zx:config obj_ap_cur run data modify storage zx:config obj_ap_cur set value 1b
# 枯枝园(withered_garden):
#   zx.gd_mana = 魔力上限账本(已加了多少, 穿 +300 / 脱 -300)
#   zx.gd_n    = 12 格内朽木数(抗性提升层数, 上限 3)   # layer-skip: 这是"身边有几根朽木"的环境计数, 不是自己攒的层
#   zx.gw_end  = 朽木(marker)身上"到期时刻"(框架时钟)
#   zx.gw_anim = 朽木本体上的动画帧号(14 → 0; 升/沉共用, 见 lib/anim_step)
execute unless data storage zx:config obj_gd_mana run scoreboard objectives add zx.gd_mana dummy
execute unless data storage zx:config obj_gd_mana run data modify storage zx:config obj_gd_mana set value 1b
execute unless data storage zx:config obj_gd_n run scoreboard objectives add zx.gd_n dummy
execute unless data storage zx:config obj_gd_n run data modify storage zx:config obj_gd_n set value 1b
execute unless data storage zx:config obj_gw_end run scoreboard objectives add zx.gw_end dummy
execute unless data storage zx:config obj_gw_end run data modify storage zx:config obj_gw_end set value 1b
execute unless data storage zx:config obj_gw_anim run scoreboard objectives add zx.gw_anim dummy
execute unless data storage zx:config obj_gw_anim run data modify storage zx:config obj_gw_anim set value 1b
# 无光海(lightless_sea):
#   zx.ls_mana = 魔力上限账本(穿 +200 / 脱 -200)
#   zx.ls_buf  = 基础攻击力账本(每影响一个生物 +1, 断供清零)
#   zx.ls_t    = 断供倒计时(有生物被影响时每秒重置为 3, 数到 0 清空攻击加成)
#   zx.ls_end  = 暗潮(marker)身上"到期时刻"(框架时钟)
#   zx.ls_anim = 暗潮本体上的动画帧号(14 → 0; 扩散/收拢共用, 见 lib/anim_step)
execute unless data storage zx:config obj_ls_mana run scoreboard objectives add zx.ls_mana dummy
execute unless data storage zx:config obj_ls_mana run data modify storage zx:config obj_ls_mana set value 1b
execute unless data storage zx:config obj_ls_buf run scoreboard objectives add zx.ls_buf dummy
execute unless data storage zx:config obj_ls_buf run data modify storage zx:config obj_ls_buf set value 1b
execute unless data storage zx:config obj_ls_t run scoreboard objectives add zx.ls_t dummy
execute unless data storage zx:config obj_ls_t run data modify storage zx:config obj_ls_t set value 1b
execute unless data storage zx:config obj_ls_end run scoreboard objectives add zx.ls_end dummy
execute unless data storage zx:config obj_ls_end run data modify storage zx:config obj_ls_end set value 1b
execute unless data storage zx:config obj_ls_anim run scoreboard objectives add zx.ls_anim dummy
execute unless data storage zx:config obj_ls_anim run data modify storage zx:config obj_ls_anim set value 1b

# ---- 第一批效果(2026-10-06 晚): 漫步冥河之上 / 沉溺忘川彼岸 / 永恒 ----
# 漫步冥河之上(styx_walk):
#   zx.sw_mana = 魔力上限账本(穿 +210 / 脱 -210)
#   zx.sw_cd   = 暗海的"下次可触发时刻"(内置 8 秒 CD, 存绝对刻)
#   zx.sea_end = 暗海(item_display)身上"到期时刻"(框架时钟); 出生 = #now + 100(5 秒)
#   zx.sea_cap = 暗海(item_display)身上"**硬上限**时刻" = 出生时刻 + 200(10 秒)
#                ★ 用户口径(2026-10-06 晚): **基础寿命不变(主片 5 秒 / 次级片 3 秒),
#                  但每个暗海最多存在 10 秒** —— 结附噬心会给全部暗海续 2 秒,
#                  但不许超过 cap(否则多只生物反复停留就能无限续)。
#   zx.sw_st   = **生物身上**"踏入暗海的时刻" —— 停留满 2 秒才结附噬心
#   zx.sw_last = **生物身上**"上一次被判定在暗海里的时刻" —— 与 sw_st 配合判断是否
#                **连续**停留(2026-10-06 修 bug: 原来靠 zx.in_sea 每刻标签,
#                但 second 每秒清、sea_enter 同一秒内紧跟着判 = 永远判到"刚清空",
#                于是每秒把踏入时刻重置一次, 停多久都到不了 40 刻)
#   zx.sea_anim= 暗海(item_display)身上的**帧号**: 入场铺开(sea_in6/sea_in4)与
#                退场收拢(sea_out6/sea_out4)都靠它, 由 lib/anim_step 每刻 -1
#   (zx.sea_hit / zx.sea_hurt_t / zx.sea_bind 是每秒用的临时标签, 不是计分项, 不用建)
execute unless data storage zx:config obj_sw_mana run scoreboard objectives add zx.sw_mana dummy
execute unless data storage zx:config obj_sw_mana run data modify storage zx:config obj_sw_mana set value 1b
execute unless data storage zx:config obj_sw_cd run scoreboard objectives add zx.sw_cd dummy
execute unless data storage zx:config obj_sw_cd run data modify storage zx:config obj_sw_cd set value 1b
execute unless data storage zx:config obj_sea_end run scoreboard objectives add zx.sea_end dummy
execute unless data storage zx:config obj_sea_end run data modify storage zx:config obj_sea_end set value 1b
execute unless data storage zx:config obj_sea_cap run scoreboard objectives add zx.sea_cap dummy
execute unless data storage zx:config obj_sea_cap run data modify storage zx:config obj_sea_cap set value 1b

# 雷鸣(thunder, 副手道具):
#   zx.th_due = 登记用的 marker 身上"该再劈一道的时刻" = 雷击那一刻 + 20(1 秒)
execute unless data storage zx:config obj_th_due run scoreboard objectives add zx.th_due dummy
execute unless data storage zx:config obj_th_due run data modify storage zx:config obj_th_due set value 1b
execute unless data storage zx:config obj_sw_st run scoreboard objectives add zx.sw_st dummy
execute unless data storage zx:config obj_sw_st run data modify storage zx:config obj_sw_st set value 1b
execute unless data storage zx:config obj_sw_last run scoreboard objectives add zx.sw_last dummy
execute unless data storage zx:config obj_sw_last run data modify storage zx:config obj_sw_last set value 1b
execute unless data storage zx:config obj_sea_anim run scoreboard objectives add zx.sea_anim dummy
execute unless data storage zx:config obj_sea_anim run data modify storage zx:config obj_sea_anim set value 1b

# 沉溺忘川彼岸(lethe_shore):
#   zx.lt_mana  = 魔力上限账本(穿 +180 / 脱 -180)
#   zx.lt_n     = 攻击计数(攒够阈值进「残念」)
#   zx.lt_need  = 当前所需攻击次数(默认 8, 可被削到最低 3)
#   zx.lt_end   = 「残念」到期时刻(3 秒)
#   zx.lt_reset = "阈值重置窗口"到期时刻(20 秒内没再触发就复位回 8)
execute unless data storage zx:config obj_lt_mana run scoreboard objectives add zx.lt_mana dummy
execute unless data storage zx:config obj_lt_mana run data modify storage zx:config obj_lt_mana set value 1b
execute unless data storage zx:config obj_lt_n run scoreboard objectives add zx.lt_n dummy
execute unless data storage zx:config obj_lt_n run data modify storage zx:config obj_lt_n set value 1b
execute unless data storage zx:config obj_lt_need run scoreboard objectives add zx.lt_need dummy
execute unless data storage zx:config obj_lt_need run data modify storage zx:config obj_lt_need set value 1b
execute unless data storage zx:config obj_lt_end run scoreboard objectives add zx.lt_end dummy
execute unless data storage zx:config obj_lt_end run data modify storage zx:config obj_lt_end set value 1b
execute unless data storage zx:config obj_lt_reset run scoreboard objectives add zx.lt_reset dummy
execute unless data storage zx:config obj_lt_reset run data modify storage zx:config obj_lt_reset set value 1b

# 永恒(eternity):
#   zx.et_mana = 魔力上限账本(穿 +280 / 脱 -280)
execute unless data storage zx:config obj_et_mana run scoreboard objectives add zx.et_mana dummy
execute unless data storage zx:config obj_et_mana run data modify storage zx:config obj_et_mana set value 1b

# ---- 第二批效果(2026-10-06 深夜): 副手 7 件(tool/*) ----
# 体外魔力泵(mana_pump):
#   zx.mp_mana = 魔力上限账本(副手拿着 +120 / 放下 -120)
execute unless data storage zx:config obj_mp_mana run scoreboard objectives add zx.mp_mana dummy
execute unless data storage zx:config obj_mp_mana run data modify storage zx:config obj_mp_mana set value 1b

# ---- 第三批效果(2026-10-06 晚): 负离子(斧) / 终末天启(法杖) ----
# 负离子(anion): 无持久状态 —— 冷却与魔力全走 manacore, 不需要计分项。
# 终末天启(final_revelation):
#   zx.fr_t     = 光柱还剩几秒(玩家身上; 同时也是"技能在不在释放中"的开关)
#   zx.fr_auto  = 这次光柱是不是「圣光」满 10 层自动触发的(0 = 主动释放 → 有 ×0.2 收尾)
#   zx.fr_light = 「圣光」层数(0..10; 每次普攻 +1, 满 10 自动释放并清空)
#   ★ 三个都是"用了但没建 = 那条命令直接失败、机制静默不触发"的计分项, 必须建全。
execute unless data storage zx:config obj_fr_t run scoreboard objectives add zx.fr_t dummy
execute unless data storage zx:config obj_fr_t run data modify storage zx:config obj_fr_t set value 1b
execute unless data storage zx:config obj_fr_auto run scoreboard objectives add zx.fr_auto dummy
execute unless data storage zx:config obj_fr_auto run data modify storage zx:config obj_fr_auto set value 1b
execute unless data storage zx:config obj_fr_light run scoreboard objectives add zx.fr_light dummy
execute unless data storage zx:config obj_fr_light run data modify storage zx:config obj_fr_light set value 1b
#   zx.fr_ref  = 实体光柱(item_display)的续命刻数(2026-10-07 实体光柱改版:
#                beam_go 每刻续 3, core/tick 每刻 -1, 扣完自杀) —— 记在光柱实体身上
execute unless data storage zx:config obj_fr_ref run scoreboard objectives add zx.fr_ref dummy
execute unless data storage zx:config obj_fr_ref run data modify storage zx:config obj_fr_ref set value 1b

# 朽木伤害换算用的常数: 最大魔力 ×0.08 = (×100 定点) ×#8 再 ×0.0001
scoreboard players set #8 zx.meta 8

# ---- 龙舌箭雨 · 随机落点用的常数(2026-10-13) ----
#   箭雨每根箭要在一个 ±2.00 格的范围里取随机坐标, 而全程按"百分之一格"做整数
#   运算(计分项是 Java int) ⇒ 偏移以 ±200 为单位。
#   #200 = 中心偏移: 把 lib/rnd 出来的 0..399(见 #400)平移成 -200..+199。
#   ★ 这里的常数**必须**先 set —— "#401 / #200 没 set 过" 会被 check.py 拦下来,
#     而 `%= 0` 是真会**除零中断整个函数**的(严格说 %= 0 会让整条 operation 失败,
#     后面那句坐标写入一条都不会跑 ⇒ 箭雨静默消失)。
scoreboard players set #200 zx.meta 200
#   #800 = 箭雨落点的 8 格跨度(2026-10-25 起是**普通**档: 落点 ±4.00 格, 用户拍板扩 2 格)。
#     lib/rnd 出来的是 0..399(见 lib/rnd 头注), 先 %800 只会把 >399 的部分留着,
#     所以要配合 `-= #400` 把范围平移成 -400..+399 ⇒ ±4.00 格。
scoreboard players set #800 zx.meta 800
#   #1200 / #600 = 箭雨落点的 12 格跨度(**超限**档: 落点 ±6.00 格, 2026-10-25 同批扩 2 格)。
#     ★ 这两条是 2026-10-25 新增的 —— 超限档原来用 #800/#400(±4 格), 扩 2 格后需要
#       跨度 12 格, 而包里没有现成的 1200/600, 必须**先 set 再用**:
#       `%= 0`(常数没 set 过时值为 0)会让整条 operation 失败 ⇒ 箭雨静默消失、零日志
#       (rain_deal 头注里的老坑)。平移量 = 跨度的一半 = 600。
scoreboard players set #1200 zx.meta 1200
scoreboard players set #600 zx.meta 600

# ---- 第一批效果用的常数(2026-10-06 晚) ----
#   #40  = 2 秒(暗海停留判定 / 暗海 +2 秒)
#   #60  = 3 秒(残念持续 / 次级暗海寿命)
#   #160 = 8 秒(漫步冥河暗海内置 CD)
#   #400 = 20 秒(沉溺忘川阈值重置窗口)
#   #130 = ×1.30(漫步冥河: 暗海内技能伤害 +30%)
scoreboard players set #40 zx.meta 40
scoreboard players set #60 zx.meta 60
scoreboard players set #160 zx.meta 160
scoreboard players set #400 zx.meta 400
scoreboard players set #130 zx.meta 130

#   #240 = 12 秒(批 15-2 新增: 殓丝「殓结」的获取间隔上限)
#     ★ 原本想用 #120 加两次凑 240 —— 能跑但读起来不知道是几秒; 直接加一条常量更清楚。
scoreboard players set #240 zx.meta 240

# ---- 第三批效果用的常数(2026-10-06 晚) ----
#   #120 = ×1.20(愠怒: 最大魔力类技能 +20%, 独立乘区)
#   #150 = ×1.50(炽天使之翼: 基础攻击力类技能 +50%)
#   ★ 和 #130 同款用法: 伤害先 ×100 取整, 乘常数再 ÷100 写回。
scoreboard players set #120 zx.meta 120
scoreboard players set #150 zx.meta 150

# ---- 批3 · 法杖(2026-10-07)用的常数 ----
#   #12 = 调色盘“色彩”的**初始**追踪/存活半径(每 1 个黄 +8)
scoreboard players set #12 zx.meta 12


# ---- 调试用的 /trigger 计分项(目标名上限 16 字符) ----
#   trigger 型: 玩家敲一次就把"自己那一格"设成 1, 由 debug/tg_router 每刻取走。
#   分数归 0 和重新 enable 都发生在取走之后 —— 见 debug/second。
execute unless data storage zx:config obj_dbg_stats run scoreboard objectives add zx.dbg_stats trigger
execute unless data storage zx:config obj_dbg_stats run data modify storage zx:config obj_dbg_stats set value 1b
execute unless data storage zx:config obj_dbg_worn run scoreboard objectives add zx.dbg_worn trigger
execute unless data storage zx:config obj_dbg_worn run data modify storage zx:config obj_dbg_worn set value 1b
execute unless data storage zx:config obj_dbg_raw run scoreboard objectives add zx.dbg_raw trigger
execute unless data storage zx:config obj_dbg_raw run data modify storage zx:config obj_dbg_raw set value 1b
execute unless data storage zx:config obj_dbg_diff run scoreboard objectives add zx.dbg_diff trigger
execute unless data storage zx:config obj_dbg_diff run data modify storage zx:config obj_dbg_diff set value 1b
execute unless data storage zx:config obj_dbg_cd run scoreboard objectives add zx.dbg_cd trigger
execute unless data storage zx:config obj_dbg_cd run data modify storage zx:config obj_dbg_cd set value 1b
execute unless data storage zx:config obj_dbg_mana run scoreboard objectives add zx.dbg_mana trigger
execute unless data storage zx:config obj_dbg_mana run data modify storage zx:config obj_dbg_mana set value 1b
# 术阵 +1 / -1(调试: 手动改自己名下的术阵数量, 见 debug/form_add 与 form_del)
execute unless data storage zx:config obj_dbg_fadd run scoreboard objectives add zx.dbg_fadd trigger
execute unless data storage zx:config obj_dbg_fadd run data modify storage zx:config obj_dbg_fadd set value 1b
execute unless data storage zx:config obj_dbg_fdel run scoreboard objectives add zx.dbg_fdel trigger
execute unless data storage zx:config obj_dbg_fdel run data modify storage zx:config obj_dbg_fdel set value 1b
execute unless data storage zx:config obj_dbg_menu run scoreboard objectives add zx.dbg_menu trigger
execute unless data storage zx:config obj_dbg_menu run data modify storage zx:config obj_dbg_menu set value 1b
execute unless data storage zx:config obj_dbg_give run scoreboard objectives add zx.dbg_give trigger
execute unless data storage zx:config obj_dbg_give run data modify storage zx:config obj_dbg_give set value 1b

# ---- C01 · 开发模式开关(发布配置) ----
#   #dev zx.meta = 1 = 开发构建(默认): 调试的"管理类"入口(发物 zx.dbg_give / 回魔 zx.dbg_mana /
#       清冷却 zx.dbg_cd / 术阵 ±1 zx.dbg_fadd|fdel)对**所有在线玩家**开放。
#   #dev zx.meta = 0 = 发布构建: 上面那几个入口**只对带 zx.admin 标签的玩家**开放。
#   ★ 只读入口(stats / worn / raw / diff / menu)两种模式下都对所有玩家开放 —— 它们不改世界状态。
#   ★ 【发布前怎么关】把下面这行的 1 改成 0 再 /reload; 或游戏里直接
#       /scoreboard players set #dev zx.meta 0        (写进发布说明, 见 C02)
#   ★ dev_flag 是"只初始化一次"的标记: storage 跨 /reload 保留, 所以游戏里改过的 #dev
#      不会被 reload 冲回默认值。想复位就 /data remove storage zx:config dev_flag 再 reload。
execute unless data storage zx:config dev_flag run scoreboard players set #dev zx.meta 1
execute unless data storage zx:config dev_flag run data modify storage zx:config dev_flag set value 1b

# ---- 通用数值注册表 ----
#   把"debug/stats 要显示哪些加成"从写死的代码变成一张表, 见 lib/reg/build。
#   ★ 以后加了新装备/新武器有加成, 只改 lib/reg/build 一处 ★
function sweetdream:lib/reg/build

# 建完立刻给在线玩家开一次(离线的人上线后由 debug/second 补)
function sweetdream:debug/second

# 环形下标取模用的模数: #6(+1 环) / #9(+2 环); #10 = +2 环的层数上限
scoreboard players set #6 zx.meta 6
scoreboard players set #9 zx.meta 9
scoreboard players set #10 zx.meta 10
# 百分比换算常量: #100 配合已有的 #3, "上限 ×3 ÷100" 就是 ×0.03
scoreboard players set #100 zx.meta 100
# 千分比换算常量（2026-10-20 批二加）: 血量快照一律 ×1000 定点（zx.hp_snap / zx.hl_hp），
#   读数回到"点"要 ÷1000。⚠️ 别和 #100 混用 —— 那是百分比。
scoreboard players set #1000 zx.meta 1000
# 万分比换算常量(2026-10-04 加): 升级的 mhp 一路上是"百分数 ×100"(即单位为 0.01%),
#   所以"最大魔力 × #up_pct"之后要 ÷10000 才是真百分比 —— 只除 #100 会**大 100 倍**。
#   #5000 = 10000 的一半, 用来做四舍五入(1.5% of 300 = 4.5 -> 5)。
#   见 upgrade/api/hit_percent 头注释里的单位链。
scoreboard players set #5000 zx.meta 5000
scoreboard players set #10000 zx.meta 10000
# 随机取模用的模数: #4 / #5(异彩"5 选 2"、幻昼"20% = 1/5")
scoreboard players set #4 zx.meta 4
scoreboard players set #5 zx.meta 5
# 伪随机发生器(LCG)的常数, 见 lib/rnd —— 别乱改, 那两个乘数/增量决定了周期和分布
scoreboard players set #1103515245 zx.meta 1103515245
scoreboard players set #12345 zx.meta 12345
scoreboard players set #65536 zx.meta 65536
scoreboard players set #32768 zx.meta 32768
# 标签效果用的百分比常量(2026-10-06 加):
#   #115 = +15%(夜火"受技能伤"/噬心"受真伤"的受击侧加乘), #80 = -20%(白昼梦自身技能伤害)。
#   白昼梦的"控制时长 +20%"用已有的 #20 + #100 算(ticks ×20 ÷100 = 加两成), 不另设常量。
scoreboard players set #115 zx.meta 115
scoreboard players set #80 zx.meta 80
# #13 = 1.3 的分子（启示录超限"该页 >500 时本次灾示 +30%"用 ×13÷10）
scoreboard players set #13 zx.meta 13

# ---- 通用标签的剩余秒数(TTL) + 图标淡出帧号 ----
#   zx.tt.<英文名> = 该标签还剩几秒: tag/mark_one 施加/刷新时 set 满值, tag/ttl_tick
#     每秒 -1, 归零走 tag/unmark_one(和手动摘标签同一条路)。
#   ★ 单位是**秒**、且是整数 —— 写错成 tick 会让时长差 20 倍。
#   zx.icon_fade = 标签图标淡出的帧号(8 → 0, 见 tag/icon_fade)。
#   ★ "用了但没建"的计分项 = 那条命令运行时直接失败、机制静默不触发(不报错、不写日志),
#     所以这六个必须在这里建全。
execute unless data storage zx:config obj_tt_yuanhai run scoreboard objectives add zx.tt.yuanhai dummy
execute unless data storage zx:config obj_tt_yuanhai run data modify storage zx:config obj_tt_yuanhai set value 1b
execute unless data storage zx:config obj_tt_liuhuo run scoreboard objectives add zx.tt.liuhuo dummy
execute unless data storage zx:config obj_tt_liuhuo run data modify storage zx:config obj_tt_liuhuo set value 1b
execute unless data storage zx:config obj_tt_yehuo run scoreboard objectives add zx.tt.yehuo dummy
execute unless data storage zx:config obj_tt_yehuo run data modify storage zx:config obj_tt_yehuo set value 1b
execute unless data storage zx:config obj_tt_shixin run scoreboard objectives add zx.tt.shixin dummy
execute unless data storage zx:config obj_tt_shixin run data modify storage zx:config obj_tt_shixin set value 1b
execute unless data storage zx:config obj_tt_dream run scoreboard objectives add zx.tt.dream dummy
execute unless data storage zx:config obj_tt_dream run data modify storage zx:config obj_tt_dream set value 1b
execute unless data storage zx:config obj_icon_fade run scoreboard objectives add zx.icon_fade dummy
execute unless data storage zx:config obj_icon_fade run data modify storage zx:config obj_icon_fade set value 1b

# ---- 倾囊超限(2026-10-23 批 K8): 8 秒「固定伤害追伤」窗口 ----
#   zx.ps_add = 本窗口每次固定伤害额外追加多少点(整数)
#   zx.ps_at  = 窗口到期时刻(用框架时钟 #now 比较; 0 = 没开)
#   ★ 另有一个全局闸 #ps_live(zx.meta): 当前有几名玩家窗口开着。with_from 的钩子
#     靠它决定"要不要反查施法者" —— 没人开窗口时一行都不跑。
execute unless data storage zx:config obj_ps_add run scoreboard objectives add zx.ps_add dummy
execute unless data storage zx:config obj_ps_add run data modify storage zx:config obj_ps_add set value 1b
execute unless data storage zx:config obj_ps_at run scoreboard objectives add zx.ps_at dummy
execute unless data storage zx:config obj_ps_at run data modify storage zx:config obj_ps_at set value 1b

# ---- 通用逐帧动画: 轨道表(见 lib/anim_step) ----
#   14 帧的关键帧, 数组下标 0..13 = 第 1..14 帧(下标 13 是终态)。
#   召唤物入场/退场都从这里取帧值 —— 以后新召唤物只要在实体的 data.zx.anim 里写
#   {field:"translation"/"scale", track:"轨道名", key:"帧号计分项", dir:"in"/"out"} 就能套用。
#   ★ 值必须带 f 后缀(float): transformation 的子列表是 float, 用 double 会写不进去。
#   ★ 曲线: rise_y/spread 是缓出(先快后慢, 破土 / 铺开); sink_y/shrink 是缓入
#     (先慢后快, 沉回地里 / 收拢退潮), 正好和入场对称。
data modify storage zx:anim rise_y set value [[0.0f,-2.027f,0.0f],[0.0f,-1.357f,0.0f],[0.0f,-0.741f,0.0f],[0.0f,-0.179f,0.0f],[0.0f,0.330f,0.0f],[0.0f,0.786f,0.0f],[0.0f,1.188f,0.0f],[0.0f,1.536f,0.0f],[0.0f,1.830f,0.0f],[0.0f,2.071f,0.0f],[0.0f,2.259f,0.0f],[0.0f,2.393f,0.0f],[0.0f,2.473f,0.0f],[0.0f,2.500f,0.0f]]
data modify storage zx:anim sink_y set value [[0.0f,2.473f,0.0f],[0.0f,2.393f,0.0f],[0.0f,2.259f,0.0f],[0.0f,2.071f,0.0f],[0.0f,1.830f,0.0f],[0.0f,1.536f,0.0f],[0.0f,1.188f,0.0f],[0.0f,0.786f,0.0f],[0.0f,0.330f,0.0f],[0.0f,-0.179f,0.0f],[0.0f,-0.741f,0.0f],[0.0f,-1.357f,0.0f],[0.0f,-2.027f,0.0f],[0.0f,-2.750f,0.0f]]
data modify storage zx:anim spread set value [[1.619f,1.0f,1.619f],[2.563f,1.0f,2.563f],[3.432f,1.0f,3.432f],[4.224f,1.0f,4.224f],[4.942f,1.0f,4.942f],[5.584f,1.0f,5.584f],[6.150f,1.0f,6.150f],[6.641f,1.0f,6.641f],[7.056f,1.0f,7.056f],[7.396f,1.0f,7.396f],[7.660f,1.0f,7.660f],[7.849f,1.0f,7.849f],[7.962f,1.0f,7.962f],[8.000f,1.0f,8.000f]]
data modify storage zx:anim shrink set value [[7.962f,1.0f,7.962f],[7.849f,1.0f,7.849f],[7.660f,1.0f,7.660f],[7.396f,1.0f,7.396f],[7.056f,1.0f,7.056f],[6.641f,1.0f,6.641f],[6.150f,1.0f,6.150f],[5.584f,1.0f,5.584f],[4.942f,1.0f,4.942f],[4.224f,1.0f,4.224f],[3.432f,1.0f,3.432f],[2.563f,1.0f,2.563f],[1.619f,1.0f,1.619f],[0.600f,1.0f,0.600f]]

# ---- 暗海(漫步冥河)专用: 主片直径 6 格 / 次级片直径 4 格, 各一套进出场 ----
#   ★ 2026-10-06 起暗海有**三个形态**(a 缓湾湖 / b 长湖 / c 半月湖, 生成/随机见
#     sea_pick_model + sea_make), 但三形态只是**贴图/轮廓**不同, 几何尺寸一致
#     ⇒ 轨道仍是"按直径"两条(6 格 / 4 格), 三形态共用, 不用乘 3。
#   (lib/anim_step 只能按轨道名取数组, 数组里是绝对帧值。)
#   数值 = 暗潮 spread/shrink 的等比缩放(6/8 与 4/8), 曲线/收尾法完全照抄:
#   收尾缩到很小的 0.45 / 0.30 再 kill, 表现是"沉进冥河"。
data modify storage zx:anim sea_in6 set value [[1.214f,1.0f,1.214f],[1.922f,1.0f,1.922f],[2.574f,1.0f,2.574f],[3.168f,1.0f,3.168f],[3.707f,1.0f,3.707f],[4.188f,1.0f,4.188f],[4.613f,1.0f,4.613f],[4.981f,1.0f,4.981f],[5.292f,1.0f,5.292f],[5.547f,1.0f,5.547f],[5.745f,1.0f,5.745f],[5.887f,1.0f,5.887f],[5.971f,1.0f,5.971f],[6.000f,1.0f,6.000f]]
data modify storage zx:anim sea_out6 set value [[5.971f,1.0f,5.971f],[5.887f,1.0f,5.887f],[5.745f,1.0f,5.745f],[5.547f,1.0f,5.547f],[5.292f,1.0f,5.292f],[4.981f,1.0f,4.981f],[4.613f,1.0f,4.613f],[4.188f,1.0f,4.188f],[3.707f,1.0f,3.707f],[3.168f,1.0f,3.168f],[2.574f,1.0f,2.574f],[1.922f,1.0f,1.922f],[1.214f,1.0f,1.214f],[0.450f,1.0f,0.450f]]
data modify storage zx:anim sea_in4 set value [[0.809f,1.0f,0.809f],[1.282f,1.0f,1.282f],[1.716f,1.0f,1.716f],[2.112f,1.0f,2.112f],[2.471f,1.0f,2.471f],[2.792f,1.0f,2.792f],[3.075f,1.0f,3.075f],[3.321f,1.0f,3.321f],[3.528f,1.0f,3.528f],[3.698f,1.0f,3.698f],[3.830f,1.0f,3.830f],[3.925f,1.0f,3.925f],[3.981f,1.0f,3.981f],[4.000f,1.0f,4.000f]]
data modify storage zx:anim sea_out4 set value [[3.981f,1.0f,3.981f],[3.925f,1.0f,3.925f],[3.830f,1.0f,3.830f],[3.698f,1.0f,3.698f],[3.528f,1.0f,3.528f],[3.321f,1.0f,3.321f],[3.075f,1.0f,3.075f],[2.792f,1.0f,2.792f],[2.471f,1.0f,2.471f],[2.112f,1.0f,2.112f],[1.716f,1.0f,1.716f],[1.282f,1.0f,1.282f],[0.809f,1.0f,0.809f],[0.300f,1.0f,0.300f]]


# 极光与幻梦 · 月蚀流光模型动画接线
execute unless data storage zx:config obj_ad_cast run scoreboard objectives add zx.ad_cast dummy
execute unless data storage zx:config obj_ad_cast run data modify storage zx:config obj_ad_cast set value 1b
execute unless data storage zx:config obj_ad_idle run scoreboard objectives add zx.ad_idle dummy
execute unless data storage zx:config obj_ad_idle run data modify storage zx:config obj_ad_idle set value 1b
execute unless data storage zx:config obj_ad_wait run scoreboard objectives add zx.ad_wait dummy
execute unless data storage zx:config obj_ad_wait run data modify storage zx:config obj_ad_wait set value 1b
execute unless data storage zx:config obj_ad_pulse run scoreboard objectives add zx.ad_pulse dummy
execute unless data storage zx:config obj_ad_pulse run data modify storage zx:config obj_ad_pulse set value 1b
scoreboard players set #adidle zx.meta 64
scoreboard players set #adhold zx.meta 32
scoreboard players set #adpulse zx.meta 33
scoreboard players set #adphase zx.meta 0
scoreboard players set #adframe zx.meta 0
# 极光与幻梦 · 月蚀流光模型动画接线 / END

# ---- 通用工具 · 平A 蓄力判定(2026-10-10) ----
#   zx.atk_lt = 玩家身上: 最近一次**命中**的游戏刻(由 lib/atk_charge 维护, 全包共用一份)。
#   ★ 蓄力是玩家属性、不分武器, 所以不用"每武器一个刻戳"。
execute unless data storage zx:config obj_atk_lt run scoreboard objectives add zx.atk_lt dummy
execute unless data storage zx:config obj_atk_lt run data modify storage zx:config obj_atk_lt set value 1b
#   zx.atk_gt = 玩家身上: "本刻已算过蓄力"的刻戳(同一记平A的多个入口共享一次计算, 见 lib/atk_charge 头部)。
execute unless data storage zx:config obj_atk_gt run scoreboard objectives add zx.atk_gt dummy
execute unless data storage zx:config obj_atk_gt run data modify storage zx:config obj_atk_gt set value 1b
#   zx.atk_ok = 玩家身上: 本刻"是否满蓄力"的玩家级拷贝 —— ★ 全包各平A被动闸门读它。
execute unless data storage zx:config obj_atk_ok run scoreboard objectives add zx.atk_ok dummy
execute unless data storage zx:config obj_atk_ok run data modify storage zx:config obj_atk_ok set value 1b
#   lib/atk_charge 的两个判据常数: 20 刻 × 攻速×100 = 2000
scoreboard players set #atk_k2000 zx.meta 2000
scoreboard players set #atk_k20 zx.meta 20

# ---- (zx.stand_miss 已随 O03 删除) ----
#   2026-10-11 O03 改造: 备份盔甲架整个体系退役(备份进 zx:ret 存储 + 临时架中转,
#   见 internal/itembackup/backup.mcfunction), "连续丢失计数"随之作废。
#   老存档里残留的 zx.stand_miss 目标和固定盔甲架(0.5,-60,0.5)无害, 不必清理。
# ---- 公共输入口的备份栈: 每次加载清空(2026-10-10, 修 F15 的配套) ----
#   zx:bak in 是 sweetdream:lib/in_bak 用的**栈**(list, 栈顶 = 下标 0)。
#   ★ 为什么要在 load 里清:
#     ① /reload **不会**清 /data storage(只有退出世界才清), 上一轮残留的栈会跟着进来;
#     ② 2026-10-10 之前它是"单层 compound", 老结构残留会让新的 prepend 直接失败
#        ⇒ 备份静默丢失。在这里一次性删干净, in_bak 就不必自己判类型。
#   函数执行是同步的, load 不可能在别人的 in_bak / in_restore 中间插进来, 清得安全。
data remove storage zx:bak in

# ---- 回手(消耗型武器)的持久记账(2026-10-10 修 R01/R06; 2026-10-11 三审 A02 改队列) ----
#   ★ 为什么用【计分项】而不是实体 tag:
#       tag 随实体消失 —— 玩家在"消耗 -> 回手"这 1 tick 之间掉线/死亡重生,
#       tag 就没了, 每秒那条兜底(internal/itembackup/recover)会判错手,
#       于是把备份那把刀写进错误的槽位。计分项是挂在玩家名下的持久数据,
#       重连/重生都还在, 兜底才能做出正确判断。
#   ★★ A02(2026-10-11 三审): "欠没欠武器"的**权威信号 = 队列**(存储里), 不是计分项 ★★
#       队列 zx:ret p."<uuid>".q = 列表, 每项 {slot:<int>, item:<物品快照>}(见 enqueue)。
#       下面两个计分项只是它的**镜像 / 触发器**, 千万别反过来拿它们判"还欠几件":
#   zx.ret_slot = **队首(q[0])的首选槽位**的镜像, 取值:
#        0..8  = 主手, 值为消耗那一刻的快捷栏下标(SelectedItemSlot)
#        -1    = 这一下是副手放的(副手没有"选中格"概念, 写回 weapon.offhand)
#        -2    = 队列空(没有待归还)
#       由 enqueue 在入队时按 q[0].slot 重算; 由 effect_2 在出队后重算; recover 兜底复位。
#       它唯一的用处: 让 return_go / recover_go(普通函数, 用不了 $(uuid))
#       能拼出 effect_2 的宏参数 $(slot)。
#   ★ 老版本没有队列, 回手写 weapon.mainhand(= **当前选中**的快捷栏格) ——
#     消耗后 1 tick 内滚轮切一下格子, 武器就会被塞进新选中的那一格,
#     **把那一格原有的物品直接顶掉**(item replace 不掉落, 凭空消失)。见 R01。
execute unless data storage zx:config obj_ret_slot run scoreboard objectives add zx.ret_slot dummy
execute unless data storage zx:config obj_ret_slot run data modify storage zx:config obj_ret_slot set value 1b

#   zx.ret_pend = **布尔**: 1 = 待归还队列非空, 0 = 空。
#   ★ 不变式: `zx.ret_pend = 1` ⟺ `zx:ret p."<uuid>".q` 有元素。
#     入队(enqueue)置 1; effect_2 出队后若队列已空则置 0(销账)。
#   ★ 它只是 recover 的**选择器开关**(`@a[scores={zx.ret_pend=1..}]`)—— 队列是权威,
#     别拿它当"还欠几件"的判据(它也数不出件数)。旧版是 20 秒倒计时、归零即**放弃**,
#     三审 A02 已删除该逻辑(改为**永不放弃** + 首次超时提示, 见 zx.ret_wait)。
#   ★ 不要拿 zx:ret 里的快照当"还欠一把"的判据 —— backup_go 每秒都会把玩家手里那把
#     重新快照回**暂存区**(stage.*), 那些键永远在(旧版就是这么错的: 重复发武器,
#     用一次多 20 把)。
execute unless data storage zx:config obj_ret_pend run scoreboard objectives add zx.ret_pend dummy
execute unless data storage zx:config obj_ret_pend run data modify storage zx:config obj_ret_pend set value 1b

#   zx.ret_wait = 待归还**已等待秒数**(recover 每秒 +1; 入队时归零, 销账时清掉)。
#   用途: 等太久(≥20 秒, 多半是背包全满)时给玩家**一次**提示, 免得以为武器没了。
#   只提示一次靠"=20 精确命中": 之后是 21/22…, 不会每秒刷屏。
execute unless data storage zx:config obj_ret_wait run scoreboard objectives add zx.ret_wait dummy
execute unless data storage zx:config obj_ret_wait run data modify storage zx:config obj_ret_wait set value 1b

# ============================================================
# 批 12(2026-10-13) · 法杖两件实装：五世恶咒 / 很冰的斧 用的账本
# ------------------------------------------------------------
# ★ 前缀说明：zx.fc_* 已被「炉心」占用(fc_mana / fc_hp / fc_atk / fc_ash / fc_t / fc_hold),
#   所以五世恶咒另起 **fcv_**(five curses)、很冰的斧另起 **td_**(triad), 不混用。
# ★ 这些账本记在**目标生物**身上(世咒是目标的 debuff), 不全是玩家 ——
#   但计分项本身不区分持有者, 照样要在 load 里 add。
# ★ 新增账本后**必须**重跑 `python .workbuddy/_gen_reset_scores.py`:
#   check.py 的 resetset 规则做**双向对账**(源码 zx.* 集合 == player_reset 清单),
#   漏跑会被拦下。
# ============================================================

#   zx.fcv_st  = 「世咒」层数(0=无 / 1..5 = 第一~五世), 记在**目标**身上。
#                ★ 2026-10-15: 已在第五世再被本件命中 ⇒ 立即结算终世(30%)并归 0, 不再停在 5。
#   zx.fcv_rec = 第五世期间"记录到的伤害"累计(定点 ×1000), 终世按它结算。
#   zx.fcv_t   = **各世共用**的剩余秒数(归零 = 世咒到期; 五世走终世 30%, 其余直接清)。
execute unless data storage zx:config obj_fcv_st run scoreboard objectives add zx.fcv_st dummy
execute unless data storage zx:config obj_fcv_st run data modify storage zx:config obj_fcv_st set value 1b
execute unless data storage zx:config obj_fcv_rec run scoreboard objectives add zx.fcv_rec dummy
execute unless data storage zx:config obj_fcv_rec run data modify storage zx:config obj_fcv_rec set value 1b
execute unless data storage zx:config obj_fcv_t run scoreboard objectives add zx.fcv_t dummy
execute unless data storage zx:config obj_fcv_t run data modify storage zx:config obj_fcv_t set value 1b
#   zx.fcv_pct = **这一份世咒**到期/被结算时按百分之几结算(30 / 40 / 80 / 100)。
#     2026-10-23 批 K9: 原来是全局假名 #fcv_pct, 但它是**全局**的, "同一刻先放主动(80)再
#     普攻收尾(30)"会串味; 而且"记录窗口自然到期"那条路压根拿不到施法者。
#     ⇒ 落咒当下(curse_step ⓪.5)就拍进目标身上, final 只读目标自己那份。
#     layer-skip: 是"档位参数", 不是层数
execute unless data storage zx:config obj_fcv_pct run scoreboard objectives add zx.fcv_pct dummy
execute unless data storage zx:config obj_fcv_pct run data modify storage zx:config obj_fcv_pct set value 1b
#   zx.fcv_3v = 第三世易伤的**千分比 ×10**(120 = +20% / 140 = +40%, 超限·主动档)。
#     受击侧 internal/damage/vuln_fcv3 是"挨打的那只在跑", 那时拿不到施法者,
#     所以挂易伤时就把百分比一起记在目标身上; 读不到按 120 兜底。
#     layer-skip: 同上, 不是层数
execute unless data storage zx:config obj_fcv_3v run scoreboard objectives add zx.fcv_3v dummy
execute unless data storage zx:config obj_fcv_3v run data modify storage zx:config obj_fcv_3v set value 1b
#   zx.fcv_u0..u3 = **施加这份世咒的玩家**的 UUID 四段。
#     终世可能在"记录窗口自然到期"时结算(那一刻施法者未必就在旁边),
#     而"击杀返还魔力"必须记到**施法者**头上 ⇒ 世咒落在谁身上就得记住是谁下的。
execute unless data storage zx:config obj_fcv_u0 run scoreboard objectives add zx.fcv_u0 dummy
execute unless data storage zx:config obj_fcv_u0 run data modify storage zx:config obj_fcv_u0 set value 1b
execute unless data storage zx:config obj_fcv_u1 run scoreboard objectives add zx.fcv_u1 dummy
execute unless data storage zx:config obj_fcv_u1 run data modify storage zx:config obj_fcv_u1 set value 1b
execute unless data storage zx:config obj_fcv_u2 run scoreboard objectives add zx.fcv_u2 dummy
execute unless data storage zx:config obj_fcv_u2 run data modify storage zx:config obj_fcv_u2 set value 1b
execute unless data storage zx:config obj_fcv_u3 run scoreboard objectives add zx.fcv_u3 dummy
execute unless data storage zx:config obj_fcv_u3 run data modify storage zx:config obj_fcv_u3 set value 1b
#   zx.fcv_t4  = 第四世「护甲/韧性 -50%」**自己的**剩余秒数(2026-10-13 加)。
#     各层共用的 zx.fcv_t 会被"每次命中"刷回 5 ⇒ 玩家在第四世续攻时破甲会跟着
#     续命, 远超文案的"持续 5 秒"。⇒ 破甲挂独立倒计时, 归零由 armor_uncut 摘掉。
execute unless data storage zx:config obj_fcv_t4 run scoreboard objectives add zx.fcv_t4 dummy
execute unless data storage zx:config obj_fcv_t4 run data modify storage zx:config obj_fcv_t4 set value 1b

#   zx.tri_form   = 「很冰的斧」当前形态(0 = 冰斧 / 1 = 热刀 / 2 = 重枪), 记在**玩家**身上。
#   zx.tri_strong = 主动技能的"强化"还剩几秒(术阵期间 15 → 0), 归零只结束强化;
#     ★ 2026-10-22 起归零**不再切回冰斧** —— 形态常驻(用户定)。
#   zx.tri_next   = 下一次普攻的状态位(0 = 正常 / 1 = 额外再打 2 次 / 2 = 这一刀为空)。
#   ★ 前缀用 tri_ 而不是 td_: zx.td_* 已经被「火种」(sword/tinder) 占用
#     (td_on = 燃烧状态 / td_lt = 攻击去重戳), 别混。
execute unless data storage zx:config obj_tri_form run scoreboard objectives add zx.tri_form dummy
execute unless data storage zx:config obj_tri_form run data modify storage zx:config obj_tri_form set value 1b
execute unless data storage zx:config obj_tri_strong run scoreboard objectives add zx.tri_strong dummy
execute unless data storage zx:config obj_tri_strong run data modify storage zx:config obj_tri_strong set value 1b
execute unless data storage zx:config obj_tri_next run scoreboard objectives add zx.tri_next dummy
execute unless data storage zx:config obj_tri_next run data modify storage zx:config obj_tri_next set value 1b
#   zx.tri_hit  = 强化「很热的刀」在这只目标身上**累计命中了几次**(记在目标身上)。
#     文案: 每次 -1 护甲, 命中 3 次后再 -1 护甲韧性, **技能结束后恢复**
#     ⇒ 所以要数次数, 强化结束时由 second 统一摘掉 modifier 并清零(见 triad/second)。
execute unless data storage zx:config obj_tri_hit run scoreboard objectives add zx.tri_hit dummy
execute unless data storage zx:config obj_tri_hit run data modify storage zx:config obj_tri_hit set value 1b
#   zx.tri_u0..u3 = **削这份护甲的是谁**(施法者 UUID 四段, 2026-10-13 加)。
#     "技能结束后恢复"原来只认 zx.tri_hit 标记、不认人 ⇒ 多人各拿一把三形态法杖时,
#     A 的技能结束会把 B 刚削掉的护甲/韧性一起恢复掉 ⇒ 恢复时按 owner 逐个比对。
execute unless data storage zx:config obj_tri_u0 run scoreboard objectives add zx.tri_u0 dummy
execute unless data storage zx:config obj_tri_u0 run data modify storage zx:config obj_tri_u0 set value 1b
execute unless data storage zx:config obj_tri_u1 run scoreboard objectives add zx.tri_u1 dummy
execute unless data storage zx:config obj_tri_u1 run data modify storage zx:config obj_tri_u1 set value 1b
execute unless data storage zx:config obj_tri_u2 run scoreboard objectives add zx.tri_u2 dummy
execute unless data storage zx:config obj_tri_u2 run data modify storage zx:config obj_tri_u2 set value 1b
execute unless data storage zx:config obj_tri_u3 run scoreboard objectives add zx.tri_u3 dummy
execute unless data storage zx:config obj_tri_u3 run data modify storage zx:config obj_tri_u3 set value 1b
#   zx.tri_nores = 强化「很重的枪」打出的"抗性提升失效"还剩几**刻**(2026-10-13 加)。
#     文案是"失效 **2 秒**"; 原版没有"禁止获得效果", 只能靠每刻反复清除来逼近
#     ⇒ 由 core/tick 每刻跑 triad/nores_tick: 清一次效果 + 扣 1 刻, 到点摘标签。
#     ★ 单位是**刻**(40 = 2 秒), 与驱动方 core/tick 的周期一致(坑 120: 别把秒当刻)。
execute unless data storage zx:config obj_tri_nores run scoreboard objectives add zx.tri_nores dummy
execute unless data storage zx:config obj_tri_nores run data modify storage zx:config obj_tri_nores set value 1b
#   zx.staff_gcd = 法杖普攻的"下一次允许出手的时刻"(2026-10-13 加, 记在玩家身上)。
#     存的是**到期刻**(现在 + 10 刻 = 0.5 秒), 不是倒数 —— #now 是持久化 tick 计数,
#     跨 /reload 连续, 也不需要每刻有人去扣它。见 equipment/staff/gate。
execute unless data storage zx:config obj_staff_gcd run scoreboard objectives add zx.staff_gcd dummy
execute unless data storage zx:config obj_staff_gcd run data modify storage zx:config obj_staff_gcd set value 1b

# ---------------- 批 15-5（术阵 · 领域 · 召唤物，2026-10-16）----------------
#   重溟（斧 · 史诗）: 主动"前方 5×4"命中带「渊海」者 -> 消耗最多 2 个 -> 每个在其处
#   生成半径 3 / 4 秒的领域。被动"平A命中带渊海者"额外一段伤害, 对**同一生物**
#   10 秒最多一次。
#     zx.db_ft = 领域 marker 的剩余秒数(lib/second 每秒 -1, 归零 kill)。
#     zx.db_pd = 该生物"下次可以触发被动"的 #now 时刻(逐目标节流, 记在生物身上;
#                同构先例 = 余烬 zx.em_gate)。10 秒 = 200 刻, 见 deep_brine/passive_gate。
execute unless data storage zx:config obj_db_ft run scoreboard objectives add zx.db_ft dummy
execute unless data storage zx:config obj_db_ft run data modify storage zx:config obj_db_ft set value 1b
execute unless data storage zx:config obj_db_pd run scoreboard objectives add zx.db_pd dummy
execute unless data storage zx:config obj_db_pd run data modify storage zx:config obj_db_pd set value 1b

#   长夜（法杖 · 传说）: 主动召唤 1 术阵 + 自身位置半径 6 / 8 秒的「夜原」。
#     夜原每秒随机挑 1 个带「夜火」的生物 -> 消耗 -> 附「流火」+ 护甲/韧性 -60%
#     (整个夜原期间) -> 打 最大魔力×0.12; 每消耗一次后续伤害 ×1.08(独立乘区)。
#     普攻命中带「夜火」者回 30 魔力, 2 秒最多一次。
#     zx.ln_ft   = 夜原 marker 的剩余秒数(lib/second 每秒 -1, 归零 field_end)。
#     zx.ln_n    = 夜原 marker 上"已消耗次数"(0..8) —— 换算成独立乘区 1.08^n 查表用。
#     zx.ln_gate = 该玩家"下次可以回魔"的 #now 时刻(2 秒 = 40 刻, 记在玩家身上)。
execute unless data storage zx:config obj_ln_ft run scoreboard objectives add zx.ln_ft dummy
execute unless data storage zx:config obj_ln_ft run data modify storage zx:config obj_ln_ft set value 1b
execute unless data storage zx:config obj_ln_n run scoreboard objectives add zx.ln_n dummy
execute unless data storage zx:config obj_ln_n run data modify storage zx:config obj_ln_n set value 1b
execute unless data storage zx:config obj_ln_gate run scoreboard objectives add zx.ln_gate dummy
execute unless data storage zx:config obj_ln_gate run data modify storage zx:config obj_ln_gate set value 1b

#   凝壳（胸甲 · 史诗）: 受伤后若魔力够且术阵位有空 -> 扣 80 魔力 + 占 1 术阵位,
#   在自身位置生成半径 3 / 4 秒的领域; 20 秒内不可再触发。
#   领域内生物"整次领域最多冻一次"(1 秒); 领域每秒打 基础攻击力 ×4。
#     zx.cs_cd  = 该玩家"下次可以触发被动"的 #now 时刻(20 秒 = 400 刻, 记在玩家身上)。
#     zx.cs_ft  = 领域 marker 的剩余秒数(lib/second 每秒 -1, 归零 field_end)。
#     zx.cs_fid = **领域实例号** —— 生物上次是被哪个领域冻的(记在生物身上)。
#                 实例号 = 该领域 marker 的 UUID[0]; 相等就说明本领域已经冻过它了,
#                 这就是"每名生物整次领域最多触发一次冰冻"的实现方式(见 field_tick 文件头)。
execute unless data storage zx:config obj_cs_cd run scoreboard objectives add zx.cs_cd dummy
execute unless data storage zx:config obj_cs_cd run data modify storage zx:config obj_cs_cd set value 1b
execute unless data storage zx:config obj_cs_ft run scoreboard objectives add zx.cs_ft dummy
execute unless data storage zx:config obj_cs_ft run data modify storage zx:config obj_cs_ft set value 1b
execute unless data storage zx:config obj_cs_fid run scoreboard objectives add zx.cs_fid dummy
execute unless data storage zx:config obj_cs_fid run data modify storage zx:config obj_cs_fid set value 1b

#   迟庭（法杖 · 史诗）: 主动在**准星处**生成半径 4 / 6 秒的领域(先登记 1 个真术阵)。
#   领域每秒对**处于缓慢**的生物打 最大魔力值 ×0.04; 生物的缓慢在领域内结束时,
#   额外打 基础攻击力 ×4 并向领域外击退最多 1 格(每只整次领域最多一次)。
#   普攻命中给 2 秒缓慢Ⅱ(这条不用计分项)。
#   ★ 前缀用 ltc_ 而不是 lt_: zx.lt_* 已经归「沉溺忘川彼岸」(lethe_shore) 所有
#     (zx.lt_end = 残念到期刻 / zx.lt_mana / zx.lt_n / zx.lt_reset)。复用会变成
#     "一个计分项代表两件事"(坑 136/143: 附魔只被主手遍历、一条计分项只代表一件事)。
#     zx.ltc_ft  = 领域 marker 的剩余秒数(lib/second 每秒 -1, 归零 field_end)。
#     zx.ltc_fid = **领域实例号** —— 这只生物上次是在哪个领域里"被看到带缓慢"的
#                 (记在生物身上; 实例号 = 该领域 marker 的 UUID[0])。
#     zx.ltc_end = **领域实例号** —— 这只生物已经**在哪个领域**里触发过"缓慢结束"那一段。
#                 两个都存实例号 ⇒ 换个领域自然不相等, 陈旧值永远匹配不上、无需额外清理。
#                 "整次领域最多一次" = `zx.ltc_end` 不等于本领域实例号才放行(见 field_tick)。
execute unless data storage zx:config obj_ltc_ft run scoreboard objectives add zx.ltc_ft dummy
execute unless data storage zx:config obj_ltc_ft run data modify storage zx:config obj_ltc_ft set value 1b
execute unless data storage zx:config obj_ltc_fid run scoreboard objectives add zx.ltc_fid dummy
execute unless data storage zx:config obj_ltc_fid run data modify storage zx:config obj_ltc_fid set value 1b
execute unless data storage zx:config obj_ltc_end run scoreboard objectives add zx.ltc_end dummy
execute unless data storage zx:config obj_ltc_end run data modify storage zx:config obj_ltc_end set value 1b

# ---- 批 15-5 之 雷楔（剑 · 史诗, 2026-10-16）----
#   主动在**自身位置**召唤 1 个术阵 + 一个持续 8 秒的「雷楔」(marker 实体)。
#   「雷楔」: 使用者攻击了它 8 格内的生物后, 它对**命中位置**落一道真闪电,
#   并对落点 1 格内的生物打 基础攻击力 ×2; 每秒最多触发一次(节流记在雷楔自己身上)。
#   ★ 前缀 twg_: zx.tw_* 已归「潮痕 / 潮线」一族所有(zx.tw_cd / zx.tw_set / zx.tw_t /
#     zx.tw_tgt), zx:work tw 也被 beach_vein 用着 ⇒ 一个计分项只代表一件事(坑 136/143)。
#     zx.twg_ft   = 雷楔 marker 的剩余秒数(lib/second 每秒 -1, 归零 wedge_end)。
#     zx.twg_own  = 雷楔 marker 上的"我属于谁" = 施法者 UUID[0]
#                   (cast 用它落实"同一使用者同时只能存在一个")。
#     zx.twg_gate = 雷楔 marker 上的"下次可落雷的绝对刻"(= #now + #20, 即 1 秒)
#                   —— 存到期刻而不是倒计时, 不需要每刻去减(先例 zx.em_gate)。
execute unless data storage zx:config obj_twg_ft run scoreboard objectives add zx.twg_ft dummy
execute unless data storage zx:config obj_twg_ft run data modify storage zx:config obj_twg_ft set value 1b
execute unless data storage zx:config obj_twg_own run scoreboard objectives add zx.twg_own dummy
execute unless data storage zx:config obj_twg_own run data modify storage zx:config obj_twg_own set value 1b
execute unless data storage zx:config obj_twg_gate run scoreboard objectives add zx.twg_gate dummy
execute unless data storage zx:config obj_twg_gate run data modify storage zx:config obj_twg_gate set value 1b
#   超限·雷楔(2026-10-23 批 K3)：
#     zx.twg_dot  = 生物身上「雷击残留」的剩余秒数(0 = 没有; lib/second 每秒 -1)。
#     zx.twg_dotk = 档位(1 = 3 秒 / 当前魔力 ×0.07；2 = 5 秒 / 最大魔力 ×0.08)。
#   ★ 这两个**记在敌人身上**, 所以不是"玩家自攒层数", 不进 lib/reg/build 的 layer 表。
#   ★ 必须在 core/load 声明 + 重跑 _gen_reset_scores.py 吗? —— 不需要进 player_reset:
#     它们挂在生物身上, 玩家重生不会带走它们, 而且 0 = 未激活、lib/second 会推到底。
execute unless data storage zx:config obj_twg_dot run scoreboard objectives add zx.twg_dot dummy
execute unless data storage zx:config obj_twg_dot run data modify storage zx:config obj_twg_dot set value 1b
execute unless data storage zx:config obj_twg_dotk run scoreboard objectives add zx.twg_dotk dummy
execute unless data storage zx:config obj_twg_dotk run data modify storage zx:config obj_twg_dotk set value 1b

# ---- 批 15-6 · 范围主动 + 连锁(2026-10-17) ----
#   盲烛（剑 · 史诗）
#     被动: 平A命中「夜火」者 -> 它 2.5 格内随机一个其他生物吃一发(0.06 / 它自己也带夜火则 0.1)。
#           **该效果 5 秒最多一次** -> 记在**玩家**身上(不是逐目标)。
#     烛火: 主动消耗「夜火」后点亮 8 秒, 期间每一下平A 都追加一次(0.08 / 没有别人则打目标 0.04)。
#     zx.bcd_pd = **下一次被动可触发的绝对刻** (add 0 -> > #now 就还在冷却 -> = #now -> += 100)。
#     zx.bcd_cd = **烛火的到期绝对刻**      (> #now 就是还亮着; 过期自然失配, 不用每秒递减)。
#                 ★ 这两个都必须进 event/player_reset 的清单, 否则死亡重生后烛火会跟着人回来。
execute unless data storage zx:config obj_bcd_pd run scoreboard objectives add zx.bcd_pd dummy
execute unless data storage zx:config obj_bcd_pd run data modify storage zx:config obj_bcd_pd set value 1b
execute unless data storage zx:config obj_bcd_cd run scoreboard objectives add zx.bcd_cd dummy
execute unless data storage zx:config obj_bcd_cd run data modify storage zx:config obj_bcd_cd set value 1b

#   折径（法杖 · 史诗）
#     「折光」不在五状态受管词表里(mark_one 逐字校验), 所以自成一套:
#       zx.br_g  = 身上有折光(纯标签, 选择器用)
#       zx.br_gl = **折光的到期绝对刻**(> #now 才有效; 10 秒 = 200 刻, 2026-10-23 起)
#     ★ 过期不主动清标签 —— 所有判定都同时看"到期刻 > #now", 残留不会误判;
#       被折径主动消耗时(take_zg)一起清。所以它不需要进每秒扫描。
#     ★ 它记在**生物**身上(不是玩家), 因此不进 event/player_reset 的清单。
execute unless data storage zx:config obj_br_gl run scoreboard objectives add zx.br_gl dummy
execute unless data storage zx:config obj_br_gl run data modify storage zx:config obj_br_gl set value 1b
#     zx.br_gn = 身上的「折光」**层数**(原版恒 1 / 超限最多 3; 记在生物身上)。
#       主动技能按它决定"额外射几道分光束"。被 take_zg 消耗时一并 reset。
execute unless data storage zx:config obj_br_gn run scoreboard objectives add zx.br_gn dummy
execute unless data storage zx:config obj_br_gn run data modify storage zx:config obj_br_gn set value 1b
#     zx.br_ol = 记在**玩家**身上: 这一轮主动/普攻是不是超限·折径(0/1)。
#       ★ 必须挂在玩家: 主动是一条递归 9 段的链, 每一段都要读档位, 而递归全程
#         执行者都是施法者本人 ⇒ 读 @s 不会被同刻别人的施法串掉(meta 假名会)。
execute unless data storage zx:config obj_br_ol run scoreboard objectives add zx.br_ol dummy
execute unless data storage zx:config obj_br_ol run data modify storage zx:config obj_br_ol set value 1b

#   命缕（法杖 · 史诗）—— 两套丝线各用一套计分项, 互不干扰
#     普攻血丝(记在**生物**身上):
#       zx.ft_ln_end = 血丝的到期绝对刻(5 秒 = 100 刻)
#       (有没有血丝看标签 zx.ft_ln)
#     主动连丝(实例号写在主目标 / 相连者 / 玩家三方):
#       zx.ft_n    = 实例号(= 施法刻 #now) —— 把"哪一组丝"分开
#       zx.ft_main = (标签) 主目标; zx.ft_lk = (标签) 相连者
#       zx.ft_hp   = 主目标**上次血量 ×1000** —— 真伤按前后血量差算"本次伤害"
#     节流(记在**玩家**身上): zx.ft_pd = 血丝结算的下次可触发刻(8 秒)
#     状态(记在**玩家**身上) —— 连丝的全部核心状态, **不用 marker**:
#       zx.ft_mine = 自己当前这组丝的实例号, **0 = 没有**(实例号 = 施法刻 #now)
#       zx.ft_end  = 这组丝的**到期绝对刻**(施法刻 +140); watch 每刻判, 到点自己收场
#       zx.ft_got  = 已结算真伤次数(0..6) —— 记玩家不记生物, 换目标也不重置
#       ★ 判据必须写 `matches 0` 而不是 `1..`(实例号理论上可能为负, 别赌)。
#   ★ zx.ft_hp / zx.ft_pd / zx.ft_mine / zx.ft_end / zx.ft_got 都要进
#     event/player_reset 的清单(玩家重生要清); zx.ft_n 主要活在生物上, 一起清也无害。
#   ★ 2026-10-17: 删掉 zx.ft_ft / zx.ft_cnt / zx.ft_own 三个 marker 专用项
#     —— marker 载体已取消(存档实证: 这三项从来没有过记录 ⇒ marker 一直没生成成功)。
#   ★ 2026-10-17 晚: 排查期的 zx.ft_scan(跑的刻数) / zx.ft_max(看到的最大掉血)
#     一并删除 —— 结论是**训练人偶不吃 /damage**, 代码侧无误, 诊断量已无用途。
execute unless data storage zx:config obj_ft_ln_end run scoreboard objectives add zx.ft_ln_end dummy
execute unless data storage zx:config obj_ft_ln_end run data modify storage zx:config obj_ft_ln_end set value 1b
execute unless data storage zx:config obj_ft_n run scoreboard objectives add zx.ft_n dummy
execute unless data storage zx:config obj_ft_n run data modify storage zx:config obj_ft_n set value 1b
execute unless data storage zx:config obj_ft_hp run scoreboard objectives add zx.ft_hp dummy
execute unless data storage zx:config obj_ft_hp run data modify storage zx:config obj_ft_hp set value 1b
execute unless data storage zx:config obj_ft_pd run scoreboard objectives add zx.ft_pd dummy
execute unless data storage zx:config obj_ft_pd run data modify storage zx:config obj_ft_pd set value 1b
execute unless data storage zx:config obj_ft_mine run scoreboard objectives add zx.ft_mine dummy
execute unless data storage zx:config obj_ft_mine run data modify storage zx:config obj_ft_mine set value 1b
execute unless data storage zx:config obj_ft_end run scoreboard objectives add zx.ft_end dummy
execute unless data storage zx:config obj_ft_end run data modify storage zx:config obj_ft_end set value 1b
execute unless data storage zx:config obj_ft_got run scoreboard objectives add zx.ft_got dummy
execute unless data storage zx:config obj_ft_got run data modify storage zx:config obj_ft_got set value 1b
# 命缕超限(批 K9):
#   zx.ft_pol  = 这一发普攻是不是超限版(attack 每次重写; settle 用它决定 0.05/0.06 与是否节流)
#   zx.ft2_end = 第二组丝线的到期时刻(玩家; 只有超限才赋非 0, 基础版恒 0)
#   zx.ft_tg1  = 第一组是否已绷紧过(幂等旗标, 收场时清)
#   zx.ft2n    = 第二组的实例号(生物)     zx.ft_cn = 该生物被几条丝连着(1 / 2)
execute unless data storage zx:config obj_ft_pol run scoreboard objectives add zx.ft_pol dummy
execute unless data storage zx:config obj_ft_pol run data modify storage zx:config obj_ft_pol set value 1b
execute unless data storage zx:config obj_ft2_end run scoreboard objectives add zx.ft2_end dummy
execute unless data storage zx:config obj_ft2_end run data modify storage zx:config obj_ft2_end set value 1b
execute unless data storage zx:config obj_ft_tg1 run scoreboard objectives add zx.ft_tg1 dummy
execute unless data storage zx:config obj_ft_tg1 run data modify storage zx:config obj_ft_tg1 set value 1b
execute unless data storage zx:config obj_ft2n run scoreboard objectives add zx.ft2n dummy
execute unless data storage zx:config obj_ft2n run data modify storage zx:config obj_ft2n set value 1b
execute unless data storage zx:config obj_ft_cn run scoreboard objectives add zx.ft_cn dummy
execute unless data storage zx:config obj_ft_cn run data modify storage zx:config obj_ft_cn set value 1b

# ---- 批 15-7 · 连接/转化/资源(2026-10-17) ----
#   彼岸（法杖 · 传说）: 普攻命中后的附加判断"对同一个生物 8 秒内最多触发一次"
#     zx.os_pd = 该生物"下次可以触发附加效果"的 #now 时刻(逐目标节流, 记在**生物**身上;
#                同构先例 = 重溟 zx.db_pd)。8 秒 = 160 刻, 见 other_shore/p_gate。
#     ★ 它记在生物身上; 生成器 _gen_reset_scores 会按"所有 objectives"一并收进
#       event/player_reset 的清单 —— 对生物无效、对玩家无害(玩家身上永远是 0),
#       保持"清单 == 全仓 objectives"的双向校验成立即可。
execute unless data storage zx:config obj_os_pd run scoreboard objectives add zx.os_pd dummy
execute unless data storage zx:config obj_os_pd run data modify storage zx:config obj_os_pd set value 1b

#   失血（剑 · 史诗）: 「心血」层数 0..3
#     zx.bld_n = 当前层数(玩家身上; 平A消耗「噬心」+1, 主动一次清零)。
#     ★ 前缀 bld_ 而不是 bl_: zx.bl_* 已归「脑水蛭」(brain_leech) 一族所有
#       (zx.bl_mana / bl_regen / bl_atk / bl_rv / bl_gu / bl_gm / bl_ta / bl_te)
#       ⇒ 一个计分项只代表一件事(坑 136/143/167)。
execute unless data storage zx:config obj_bld_n run scoreboard objectives add zx.bld_n dummy
execute unless data storage zx:config obj_bld_n run data modify storage zx:config obj_bld_n set value 1b

#   杂纹（护腿 · 史诗）: 8 秒窗口内"消费过哪几种状态", 满 3 种兑现
#     zx.mv_end = 记录窗口的**到期绝对刻**(> #now 就是窗口还开着; 过期 = 下次消费重开)
#     zx.mv_n   = 本窗口已记录的不同种类数(0..3)
#     ★ 这两个都记在**玩家**身上, 必须进 event/player_reset 的清单
#       (否则死亡重生后窗口/计数会跟着人回来, 一上线就白送一次奖励)。
#     ★ "记过哪几种"用标签 zx.mv.<种类> 表达(不用五个计分项)。
execute unless data storage zx:config obj_mv_end run scoreboard objectives add zx.mv_end dummy
execute unless data storage zx:config obj_mv_end run data modify storage zx:config obj_mv_end set value 1b
execute unless data storage zx:config obj_mv_n run scoreboard objectives add zx.mv_n dummy
execute unless data storage zx:config obj_mv_n run data modify storage zx:config obj_mv_n set value 1b

#   续火（法杖 · 稀有，2026-10-17 批 14 补技能）: 普攻命中累计
#     zx.rf_n = 已累计的普攻命中次数(0..2; 满 3 当场清零并回 1 点生命)
#     ★ 记在**玩家**身上、不认目标 —— 文案"切换武器后清空次数"是"自己的连续命中",
#       由 lib/second 每秒查主手(zx.rf_n=1.. 的玩家)清零。
execute unless data storage zx:config obj_rf_n run scoreboard objectives add zx.rf_n dummy
execute unless data storage zx:config obj_rf_n run data modify storage zx:config obj_rf_n set value 1b

#   空枕（头盔 · 稀有，2026-10-17 批 14 补技能）: 「静息」的计时
#     zx.ep_hit = **最近一次造成伤害**的绝对刻(internal/damage/deal 的钩子刷新)
#     ★ #now - ep_hit >= 80 刻(4 秒) 就发标签 zx.ep_rest; 兑现(附白昼梦)由 on_deal 做。
#     ★ 记在玩家身上, 必须进 event/player_reset 清单(重生后重新数 4 秒)。
execute unless data storage zx:config obj_ep_hit run scoreboard objectives add zx.ep_hit dummy
execute unless data storage zx:config obj_ep_hit run data modify storage zx:config obj_ep_hit set value 1b

#   位移检测（2026-10-17 批 14 补技能）: 踏灰 / 雨迹共用的"技能施放后有没有真位移"
#     zx.sm_t     = 检测窗口剩余刻(24 → 0; 只有刚放过技能且脚穿这两件之一的玩家有)
#                   ★ 2026-10-18：**位移还在继续就不倒数**（每刻续回 16），否则长位移
#                     技能（无息 20 刻 / 沉锚 / 影刃）会在中途窗口到期、标签被摘，
#                     后半段再也不撒水迹 —— 用户报的"中间断""后面一段没了"就是这个。
#     zx.sm_px/py/pz = **上一刻**的坐标 ×100（判断"这一课还在不在动"，续期用）
#     zx.sm_n     = 确认位移之后"还在动"的累计刻数（续期上限 56 刻 ≈ 2.8 秒，
#                   防止玩家一路狂奔导致窗口永不结束）
#     zx.sm_x/y/z = 施法刻的坐标 ×100(0.01 精度) —— lib/step 每刻拿它比当前 Pos
#     zx.sm_done  = 0/1, "这次窗口里已经确认过位移" —— 确认后终点每刻跟着玩家走,
#                   窗口到期由 step_finish 一次性兑现(这样持续位移也能被完整覆盖)
#     ★ 记录里要带**技能 id 字符串**(踏灰要用它减"这一个技能"的冷却), 计分项存不了,
#       所以技能 id 放 zx:step casts 的 storage(键 = UUID 四整数), 这里只放坐标。
execute unless data storage zx:config obj_sm_t run scoreboard objectives add zx.sm_t dummy
execute unless data storage zx:config obj_sm_t run data modify storage zx:config obj_sm_t set value 1b
execute unless data storage zx:config obj_sm_done run scoreboard objectives add zx.sm_done dummy
execute unless data storage zx:config obj_sm_done run data modify storage zx:config obj_sm_done set value 1b
execute unless data storage zx:config obj_sm_x run scoreboard objectives add zx.sm_x dummy
execute unless data storage zx:config obj_sm_x run data modify storage zx:config obj_sm_x set value 1b
execute unless data storage zx:config obj_sm_y run scoreboard objectives add zx.sm_y dummy
execute unless data storage zx:config obj_sm_y run data modify storage zx:config obj_sm_y set value 1b
execute unless data storage zx:config obj_sm_z run scoreboard objectives add zx.sm_z dummy
execute unless data storage zx:config obj_sm_z run data modify storage zx:config obj_sm_z set value 1b
execute unless data storage zx:config obj_sm_px run scoreboard objectives add zx.sm_px dummy
execute unless data storage zx:config obj_sm_px run data modify storage zx:config obj_sm_px set value 1b
execute unless data storage zx:config obj_sm_py run scoreboard objectives add zx.sm_py dummy
execute unless data storage zx:config obj_sm_py run data modify storage zx:config obj_sm_py set value 1b
execute unless data storage zx:config obj_sm_pz run scoreboard objectives add zx.sm_pz dummy
execute unless data storage zx:config obj_sm_pz run data modify storage zx:config obj_sm_pz set value 1b
execute unless data storage zx:config obj_sm_n run scoreboard objectives add zx.sm_n dummy
execute unless data storage zx:config obj_sm_n run data modify storage zx:config obj_sm_n set value 1b

#   踏灰（靴子 · 稀有，2026-10-17 批 14 补技能）
#     zx.ta_cd = 12 秒节流的"下次可触发刻"
execute unless data storage zx:config obj_ta_cd run scoreboard objectives add zx.ta_cd dummy
execute unless data storage zx:config obj_ta_cd run data modify storage zx:config obj_ta_cd set value 1b

#   雨迹（靴子 · 罕见，2026-10-17 批 14 补技能）
#     zx.rt_life     = 水迹点(item_display)的剩余刻(100 → 0, **记在实体自己身上**)
#     zx.rt_on       = 生物停留状态: 0 离开 / 1 停留中 / 2 本段已兑现
#     zx.rt_first    = 首次进入这段水迹的绝对刻
#     zx.rt_end      = 最后一次被覆盖的刻 + 8(容忍 0.4 秒走位抖动)
#     zx.rt_lx/ly/lz = **上一滴**的坐标 ×100(撒点的间距判据基准)
#                      ★ 2026-10-18 起由 dot_spawn 每生成一滴就同步成"那一滴的
#                        真实坐标", 间距固定 1.4 格(见 rain_trace/fill 的注释)。
#                        这样补点时"执行位置在连线中间"也能正确记账 ——
#                        用玩家 Pos 记账会把整条链往回拽(上一版的"补点全堆一处")。
#     zx.rt_ex/ey/ez = 旧版"位移终点"坐标 —— 2026-10-17 改成逐刻就地撒点后**不再写入**,
#                      只为兼容存档与 player_reset 清单而保留注册。
#     zx.rt_sn       = 旧版"上次撒点的绝对刻"(5 刻节流) —— 同上, 已不再写入。
#     ★ "最新水迹点"的锚点不用计分项, 用实体标签 **zx.rt_last**(全维度一个,
#       补点要靠它当 positioned 的参照物, 见 rain_trace/dot_spawn)。
#     ★ 起点锚点同理用 marker + 标签 **zx.rt_anchor**: step_observe 在施法刻留、
#       step_moved 撒完"起点那一摊"就 kill。
#     ★ 停留判定用"首次刻 vs 当前刻"的差, 不用每刻 +1 —— 相邻水迹点会同时覆盖
#       同一只生物, 每刻 +1 的写法会把计数叠成两倍速(2 秒变 1 秒)。
execute unless data storage zx:config obj_rt_ex run scoreboard objectives add zx.rt_ex dummy
execute unless data storage zx:config obj_rt_ex run data modify storage zx:config obj_rt_ex set value 1b
execute unless data storage zx:config obj_rt_ey run scoreboard objectives add zx.rt_ey dummy
execute unless data storage zx:config obj_rt_ey run data modify storage zx:config obj_rt_ey set value 1b
execute unless data storage zx:config obj_rt_ez run scoreboard objectives add zx.rt_ez dummy
execute unless data storage zx:config obj_rt_ez run data modify storage zx:config obj_rt_ez set value 1b
execute unless data storage zx:config obj_rt_lx run scoreboard objectives add zx.rt_lx dummy
execute unless data storage zx:config obj_rt_lx run data modify storage zx:config obj_rt_lx set value 1b
execute unless data storage zx:config obj_rt_ly run scoreboard objectives add zx.rt_ly dummy
execute unless data storage zx:config obj_rt_ly run data modify storage zx:config obj_rt_ly set value 1b
execute unless data storage zx:config obj_rt_lz run scoreboard objectives add zx.rt_lz dummy
execute unless data storage zx:config obj_rt_lz run data modify storage zx:config obj_rt_lz set value 1b
execute unless data storage zx:config obj_rt_sn run scoreboard objectives add zx.rt_sn dummy
execute unless data storage zx:config obj_rt_sn run data modify storage zx:config obj_rt_sn set value 1b
execute unless data storage zx:config obj_rt_life run scoreboard objectives add zx.rt_life dummy
execute unless data storage zx:config obj_rt_life run data modify storage zx:config obj_rt_life set value 1b
execute unless data storage zx:config obj_rt_on run scoreboard objectives add zx.rt_on dummy
execute unless data storage zx:config obj_rt_on run data modify storage zx:config obj_rt_on set value 1b
execute unless data storage zx:config obj_rt_first run scoreboard objectives add zx.rt_first dummy
execute unless data storage zx:config obj_rt_first run data modify storage zx:config obj_rt_first set value 1b
execute unless data storage zx:config obj_rt_end run scoreboard objectives add zx.rt_end dummy
execute unless data storage zx:config obj_rt_end run data modify storage zx:config obj_rt_end set value 1b

#   返照（头盔 · 史诗，2026-10-17 批 14 补技能）
#     zx.bk_wd = 「回照」到期绝对刻(5 秒)
#     zx.bk_cd = 20 秒节流的"下次可触发刻"
execute unless data storage zx:config obj_bk_wd run scoreboard objectives add zx.bk_wd dummy
execute unless data storage zx:config obj_bk_wd run data modify storage zx:config obj_bk_wd set value 1b
execute unless data storage zx:config obj_bk_cd run scoreboard objectives add zx.bk_cd dummy
execute unless data storage zx:config obj_bk_cd run data modify storage zx:config obj_bk_cd set value 1b

#   回旋（护腿 · 史诗，2026-10-17 批 14 补技能）
#     zx.gy_wd = 「旋步」到期绝对刻(6 秒)
#     zx.gy_cd = 12 秒节流的"下次可触发刻"
#     zx.gyr_st = 绕后过程的状态机（★ 2026-10-17 改"有过程"后的编号 ★）
#                 0    = 未激活（tick 选择器是 `1..`，0 不匹配 ⇒ 天然停摆）
#                 1..6 = 过程中的刻数（1/3/5 走一段弧，2/4/6 只出拖尾）
#                 7    = 走完 → arc_done 打 24 点并清回 0
#                 99   = 中途撞墙 → 立刻 arc_done
#     ★ 千万别再把"未激活"写成 0 又让 tick 从 0 起筛 —— 那会每刻死循环重放音效粒子
#       （2026-10-17 用户报"reload 后疯狂挥剑声 + 蓝色粒子"的根因）。
execute unless data storage zx:config obj_gy_wd run scoreboard objectives add zx.gy_wd dummy
execute unless data storage zx:config obj_gy_wd run data modify storage zx:config obj_gy_wd set value 1b
execute unless data storage zx:config obj_gy_cd run scoreboard objectives add zx.gy_cd dummy
execute unless data storage zx:config obj_gy_cd run data modify storage zx:config obj_gy_cd set value 1b
execute unless data storage zx:config obj_gyr_st run scoreboard objectives add zx.gyr_st dummy
execute unless data storage zx:config obj_gyr_st run data modify storage zx:config obj_gyr_st set value 1b

# 法球临时标记（2026-10-20 延迟修复）：原来是 tag，每刻 add/remove 会给生物
#   Entity.setChanged() -> chunk 脏 -> EntityStorage 每刻重写整个 chunk（连玩家
#   43KB 的 NBT 一起压缩）。JFR 实测保存吃掉 53% 的服务端时间。改成计分项后
#   数据只落在 scoreboard.dat，不再碰实体 NBT。
#   ★ 只覆盖"每刻(tick_target)"和"发射(fire)"两处；hit 的 zx.ball_hit 仍是 tag
#     —— 它要作为字符串塞进 {target:"@e[...]"}，带花括号会让整个函数不加载。
execute unless data storage zx:config obj_bt run scoreboard objectives add zx.bt dummy
execute unless data storage zx:config obj_bt run data modify storage zx:config obj_bt set value 1b
execute unless data storage zx:config obj_ball_touch run scoreboard objectives add zx.ball_touch dummy
execute unless data storage zx:config obj_ball_touch run data modify storage zx:config obj_ball_touch set value 1b

# 空枕的「本次受害者」标记（2026-10-20 同上）：原来 internal/damage/deal 每次伤害都
#   给受害者 add/remove zx.ep_vic —— 所有伤害来源（近战/弩/法球/技能）都走这里，
#   等于每一下攻击都写两次实体 NBT。改成分数后这条链不再产生脏 chunk。
#   on_deal 里原来那处 `{target:"@e[tag=zx.ep_vic,...]"}` 已改成 `execute as ... {target:"@s"}`，
#   避免字符串里出现花括号（见 check.py 的 set value 配平规则）。
execute unless data storage zx:config obj_ep_vic run scoreboard objectives add zx.ep_vic dummy
execute unless data storage zx:config obj_ep_vic run data modify storage zx:config obj_ep_vic set value 1b


# ============================================================
# 批一 10 件（2026-10-20 实装）：技能状态计分项
# ------------------------------------------------------------
# 【为什么全部用计分项而不是 tag】2026-10-20 定位到的延迟根因就是"每刻给生物
#   add/remove tag ⇒ Entity.setChanged ⇒ EntityStorage 每刻重写整个 chunk"。
#   这些新件的状态一律落在 scoreboard.dat 上，不碰实体 NBT。
# 【★ 每件都要在 player_reset 里清】跑 _gen_reset_scores.py --write
#   （它扫的是本文件里每一条"新建计分项"的完整命令）。
#
# 曳步 yebu：zx.yb  = 目标身上"本件给的缓慢"到期刻（0 = 没记过账，自愈）
#            zx.ybu = 上次升级刻 +80（4 秒内最多升一次）
execute unless data storage zx:config obj_yb run scoreboard objectives add zx.yb dummy
execute unless data storage zx:config obj_yb run data modify storage zx:config obj_yb set value 1b
execute unless data storage zx:config obj_ybu run scoreboard objectives add zx.ybu dummy
execute unless data storage zx:config obj_ybu run data modify storage zx:config obj_ybu set value 1b
# 曳步·超限（2026-10-23 批 K1）：缓慢Ⅲ 的叠加账 + 一次性的移速惩罚
#   zx.yb3   = 缓慢Ⅲ 的累计到期刻（叠时长叠它，上限 now+240 = 12 秒）
#   zx.ybm   = 1 = 这只生物已经吃过"基础移速 -50%"那一次（**每生物仅一次**，永不复位）
#   zx.yb_be = 移速惩罚的结束刻（ol_bind_sweep 每秒判到点摘属性）
execute unless data storage zx:config obj_yb3 run scoreboard objectives add zx.yb3 dummy
execute unless data storage zx:config obj_yb3 run data modify storage zx:config obj_yb3 set value 1b
execute unless data storage zx:config obj_ybm run scoreboard objectives add zx.ybm dummy
execute unless data storage zx:config obj_ybm run data modify storage zx:config obj_ybm set value 1b
execute unless data storage zx:config obj_yb_be run scoreboard objectives add zx.yb_be dummy
execute unless data storage zx:config obj_yb_be run data modify storage zx:config obj_yb_be set value 1b
#
# 站定检测 lib/still（驻足 / 冻土共用）
#   zx.st_n = 连续静止刻数（上限 200，移动归 0）；st_x/st_z = 上次采样坐标(×100)
#   st_i    = 是否已建立基准
execute unless data storage zx:config obj_st_n run scoreboard objectives add zx.st_n dummy
execute unless data storage zx:config obj_st_n run data modify storage zx:config obj_st_n set value 1b
execute unless data storage zx:config obj_st_x run scoreboard objectives add zx.st_x dummy
execute unless data storage zx:config obj_st_x run data modify storage zx:config obj_st_x set value 1b
execute unless data storage zx:config obj_st_z run scoreboard objectives add zx.st_z dummy
execute unless data storage zx:config obj_st_z run data modify storage zx:config obj_st_z set value 1b
execute unless data storage zx:config obj_st_i run scoreboard objectives add zx.st_i dummy
execute unless data storage zx:config obj_st_i run data modify storage zx:config obj_st_i set value 1b
#
# 驻足 zhuzu：zz_w=1 正在等这 1.5 秒；zz_t 剩余刻；zz_on=1 领域在场上；
#             zz_cd 冷却到期刻；zz_me 本件领域归属（UUID[0]）
execute unless data storage zx:config obj_zz_w run scoreboard objectives add zx.zz_w dummy
execute unless data storage zx:config obj_zz_w run data modify storage zx:config obj_zz_w set value 1b
execute unless data storage zx:config obj_zz_t run scoreboard objectives add zx.zz_t dummy
execute unless data storage zx:config obj_zz_t run data modify storage zx:config obj_zz_t set value 1b
execute unless data storage zx:config obj_zz_on run scoreboard objectives add zx.zz_on dummy
execute unless data storage zx:config obj_zz_on run data modify storage zx:config obj_zz_on set value 1b
execute unless data storage zx:config obj_zz_cd run scoreboard objectives add zx.zz_cd dummy
execute unless data storage zx:config obj_zz_cd run data modify storage zx:config obj_zz_cd set value 1b
execute unless data storage zx:config obj_zz_me run scoreboard objectives add zx.zz_me dummy
execute unless data storage zx:config obj_zz_me run data modify storage zx:config obj_zz_me set value 1b
# 领域 marker 上的 zx.zz_ft（剩余秒）与 zx.zz_own（归属）—— 同一批，一并登记
execute unless data storage zx:config obj_zz_ft run scoreboard objectives add zx.zz_ft dummy
execute unless data storage zx:config obj_zz_ft run data modify storage zx:config obj_zz_ft set value 1b
execute unless data storage zx:config obj_zz_own run scoreboard objectives add zx.zz_own dummy
execute unless data storage zx:config obj_zz_own run data modify storage zx:config obj_zz_own set value 1b
#
# 冻土 dongtu：dng_on=1 生效中；dng_l 剩余秒；dng_hp 每秒回复量；
#              dng_cd 冷却到期刻（从中断那刻起 20 秒）
execute unless data storage zx:config obj_dng_on run scoreboard objectives add zx.dng_on dummy
execute unless data storage zx:config obj_dng_on run data modify storage zx:config obj_dng_on set value 1b
execute unless data storage zx:config obj_dng_l run scoreboard objectives add zx.dng_l dummy
execute unless data storage zx:config obj_dng_l run data modify storage zx:config obj_dng_l set value 1b
execute unless data storage zx:config obj_dng_hp run scoreboard objectives add zx.dng_hp dummy
execute unless data storage zx:config obj_dng_hp run data modify storage zx:config obj_dng_hp set value 1b
execute unless data storage zx:config obj_dng_cd run scoreboard objectives add zx.dng_cd dummy
execute unless data storage zx:config obj_dng_cd run data modify storage zx:config obj_dng_cd set value 1b
#
# 回澜 huilan：hl_hp 上刻血量快照(×1000)；hl_dmg 这一下的量(×1000)；
#              hl_t 剩余刻；hl_on=1 有待结算
execute unless data storage zx:config obj_hl_hp run scoreboard objectives add zx.hl_hp dummy
execute unless data storage zx:config obj_hl_hp run data modify storage zx:config obj_hl_hp set value 1b
execute unless data storage zx:config obj_hl_dmg run scoreboard objectives add zx.hl_dmg dummy
execute unless data storage zx:config obj_hl_dmg run data modify storage zx:config obj_hl_dmg set value 1b
execute unless data storage zx:config obj_hl_t run scoreboard objectives add zx.hl_t dummy
execute unless data storage zx:config obj_hl_t run data modify storage zx:config obj_hl_t set value 1b
execute unless data storage zx:config obj_hl_on run scoreboard objectives add zx.hl_on dummy
execute unless data storage zx:config obj_hl_on run data modify storage zx:config obj_hl_on set value 1b
#
# ============ 批二 14 件（2026-10-20 实装）============
# 通用：hp_snap 上刻血量快照(×1000)，供反照/归途/息土算"这一下受了多少"
execute unless data storage zx:config obj_hp_snap run scoreboard objectives add zx.hp_snap dummy
execute unless data storage zx:config obj_hp_snap run data modify storage zx:config obj_hp_snap set value 1b
# 剖心 profane：pf_poke = 普攻延长噬心的下次可触发刻
execute unless data storage zx:config obj_pf_poke run scoreboard objectives add zx.pf_poke dummy
execute unless data storage zx:config obj_pf_poke run data modify storage zx:config obj_pf_poke set value 1b
# 剖心 profane：pf_slot = 施法那一刻剖心所在的快捷栏格(0..8); 超限的"前面武器 -10 秒"要用
#   layer-skip: 这是"快捷栏位置", 不是玩家要看的数值
execute unless data storage zx:config obj_pf_slot run scoreboard objectives add zx.pf_slot dummy
execute unless data storage zx:config obj_pf_slot run data modify storage zx:config obj_pf_slot set value 1b
# 饮霜 sip_frost：sf_acc 已攒治疗量；sf_cd = 下次可触发刻
execute unless data storage zx:config obj_sf_acc run scoreboard objectives add zx.sf_acc dummy
execute unless data storage zx:config obj_sf_acc run data modify storage zx:config obj_sf_acc set value 1b
execute unless data storage zx:config obj_sf_cd run scoreboard objectives add zx.sf_cd dummy
execute unless data storage zx:config obj_sf_cd run data modify storage zx:config obj_sf_cd set value 1b
# 反照 retro_shine：rt_cd = 下次可反弹刻
execute unless data storage zx:config obj_rt_cd run scoreboard objectives add zx.rt_cd dummy
execute unless data storage zx:config obj_rt_cd run data modify storage zx:config obj_rt_cd set value 1b
# 息土 breathing_soil：so_ft 领域剩余秒；so_cd 下次可触发刻；so_hc "受伤回1"的下次可触发刻
execute unless data storage zx:config obj_so_ft run scoreboard objectives add zx.so_ft dummy
execute unless data storage zx:config obj_so_ft run data modify storage zx:config obj_so_ft set value 1b
execute unless data storage zx:config obj_so_cd run scoreboard objectives add zx.so_cd dummy
execute unless data storage zx:config obj_so_cd run data modify storage zx:config obj_so_cd set value 1b
execute unless data storage zx:config obj_so_hc run scoreboard objectives add zx.so_hc dummy
execute unless data storage zx:config obj_so_hc run data modify storage zx:config obj_so_hc set value 1b
# 归途 way_back：wb_on=1 灯亮着；wb_t 剩余秒；wb_dmg 累计受伤(×1000)；wb_low=1 曾低于 50%
execute unless data storage zx:config obj_wb_on run scoreboard objectives add zx.wb_on dummy
execute unless data storage zx:config obj_wb_on run data modify storage zx:config obj_wb_on set value 1b
execute unless data storage zx:config obj_wb_t run scoreboard objectives add zx.wb_t dummy
execute unless data storage zx:config obj_wb_t run data modify storage zx:config obj_wb_t set value 1b
execute unless data storage zx:config obj_wb_dmg run scoreboard objectives add zx.wb_dmg dummy
execute unless data storage zx:config obj_wb_dmg run data modify storage zx:config obj_wb_dmg set value 1b
execute unless data storage zx:config obj_wb_low run scoreboard objectives add zx.wb_low dummy
execute unless data storage zx:config obj_wb_low run data modify storage zx:config obj_wb_low set value 1b
# 沉砣 sunken_weight: 层数 zx.sw_n (0..5, 每层 +2 固定伤害 / -4% 移速, 受伤清零)
execute unless data storage zx:config obj_sw_n run scoreboard objectives add zx.sw_n dummy
execute unless data storage zx:config obj_sw_n run data modify storage zx:config obj_sw_n set value 1b
# 决堤 burst_bank：bb_on=1 突进中；bb_left 剩余 0.5 格步数；bb_run 已走步数；bb_paid 本次消耗
execute unless data storage zx:config obj_bb_on run scoreboard objectives add zx.bb_on dummy
execute unless data storage zx:config obj_bb_on run data modify storage zx:config obj_bb_on set value 1b
execute unless data storage zx:config obj_bb_left run scoreboard objectives add zx.bb_left dummy
execute unless data storage zx:config obj_bb_left run data modify storage zx:config obj_bb_left set value 1b
execute unless data storage zx:config obj_bb_run run scoreboard objectives add zx.bb_run dummy
execute unless data storage zx:config obj_bb_run run data modify storage zx:config obj_bb_run set value 1b
execute unless data storage zx:config obj_bb_paid run scoreboard objectives add zx.bb_paid dummy
execute unless data storage zx:config obj_bb_paid run data modify storage zx:config obj_bb_paid set value 1b
# 决堤超限(批 K8): 水流地带的到期时刻 / 每秒伤害
execute unless data storage zx:config obj_bb_wt run scoreboard objectives add zx.bb_wt dummy
execute unless data storage zx:config obj_bb_wt run data modify storage zx:config obj_bb_wt set value 1b
execute unless data storage zx:config obj_bb_wd run scoreboard objectives add zx.bb_wd dummy
execute unless data storage zx:config obj_bb_wd run data modify storage zx:config obj_bb_wd set value 1b
#
# 锈犬 xiugou（marker 侧）：xg_ft 剩余秒；xg_n 已咬次数；xg_own 归属 UUID[0]
execute unless data storage zx:config obj_xg_ft run scoreboard objectives add zx.xg_ft dummy
execute unless data storage zx:config obj_xg_ft run data modify storage zx:config obj_xg_ft set value 1b
execute unless data storage zx:config obj_xg_n run scoreboard objectives add zx.xg_n dummy
execute unless data storage zx:config obj_xg_n run data modify storage zx:config obj_xg_n set value 1b
execute unless data storage zx:config obj_xg_own run scoreboard objectives add zx.xg_own dummy
execute unless data storage zx:config obj_xg_own run data modify storage zx:config obj_xg_own set value 1b
#
# 超限·锈犬 xiugou（2026-10-23 批 K4）：
#   marker 侧：zx.xg_hc = 对**当前目标**的连击数(0..4, 满 5 触发后归零)；
#             zx.xg_tg / zx.xg_th = 目标指纹(UUID[3] / UUID[0]) —— 换目标就清零。
#   生物侧：  zx.svul  = 「被召唤物攻击受到伤害 +30%」的剩余秒数(0 = 没有)。
#   ★ 连击记在**犬**身上(文案"锈犬每对一个生物"), 承伤 debuff 记在**生物**身上。
execute unless data storage zx:config obj_xg_hc run scoreboard objectives add zx.xg_hc dummy
execute unless data storage zx:config obj_xg_hc run data modify storage zx:config obj_xg_hc set value 1b
execute unless data storage zx:config obj_xg_tg run scoreboard objectives add zx.xg_tg dummy
execute unless data storage zx:config obj_xg_tg run data modify storage zx:config obj_xg_tg set value 1b
execute unless data storage zx:config obj_xg_th run scoreboard objectives add zx.xg_th dummy
execute unless data storage zx:config obj_xg_th run data modify storage zx:config obj_xg_th set value 1b
execute unless data storage zx:config obj_svul run scoreboard objectives add zx.svul dummy
execute unless data storage zx:config obj_svul run data modify storage zx:config obj_svul set value 1b
#
# 钩丝 gousi（玩家侧）：gs_st 剩余步数(12 起步，0=空闲)；gs_own 锁定的 tag 后缀
execute unless data storage zx:config obj_gs_st run scoreboard objectives add zx.gs_st dummy
execute unless data storage zx:config obj_gs_st run data modify storage zx:config obj_gs_st set value 1b
execute unless data storage zx:config obj_gs_own run scoreboard objectives add zx.gs_own dummy
execute unless data storage zx:config obj_gs_own run data modify storage zx:config obj_gs_own set value 1b
#
# 超限·钩丝 gousi（玩家侧, 2026-10-23 批 K3）：
#   zx.gs3   = 本次施法走的是超限三目标闭环(1)；0 = 空闲。
#              pull_go 靠它分流, ol_done 收尾清零, cast 出手时也按 ol 标记重置。
#   zx.gs3p  = 「下三次技能伤害」的百分点(0/10/20/30, 封顶 30)。每拉到一个 +10。
#              ★ 三层**共享**三次, 不是每层各三次(已定口径)。
#   zx.gs3n  = 这份加成还剩几次技能(0..3)。
#   zx.gs3lt = 上次消费的绝对刻 —— 同一次施法里可能连算好几遍 calc(剖心就三遍),
#              不去重会把"下三次"一次吃光(先例 zx.mm_add_lt)。
execute unless data storage zx:config obj_gs3 run scoreboard objectives add zx.gs3 dummy
execute unless data storage zx:config obj_gs3 run data modify storage zx:config obj_gs3 set value 1b
execute unless data storage zx:config obj_gs3p run scoreboard objectives add zx.gs3p dummy
execute unless data storage zx:config obj_gs3p run data modify storage zx:config obj_gs3p set value 1b
execute unless data storage zx:config obj_gs3n run scoreboard objectives add zx.gs3n dummy
execute unless data storage zx:config obj_gs3n run data modify storage zx:config obj_gs3n set value 1b
execute unless data storage zx:config obj_gs3lt run scoreboard objectives add zx.gs3lt dummy
execute unless data storage zx:config obj_gs3lt run data modify storage zx:config obj_gs3lt set value 1b
#
# 铁蒺藜 tiejili（marker 侧）：tjl_ft 剩余秒
execute unless data storage zx:config obj_tjl_ft run scoreboard objectives add zx.tjl_ft dummy
execute unless data storage zx:config obj_tjl_ft run data modify storage zx:config obj_tjl_ft set value 1b
#
# 履霜 lvshuang：lsh_i 已建基准；lsh_px/pz 上次撒点坐标(×100)；lsh_ft 霜片剩余秒
execute unless data storage zx:config obj_lsh_i run scoreboard objectives add zx.lsh_i dummy
execute unless data storage zx:config obj_lsh_i run data modify storage zx:config obj_lsh_i set value 1b
execute unless data storage zx:config obj_lsh_px run scoreboard objectives add zx.lsh_px dummy
execute unless data storage zx:config obj_lsh_px run data modify storage zx:config obj_lsh_px set value 1b
execute unless data storage zx:config obj_lsh_pz run scoreboard objectives add zx.lsh_pz dummy
execute unless data storage zx:config obj_lsh_pz run data modify storage zx:config obj_lsh_pz set value 1b
execute unless data storage zx:config obj_lsh_ft run scoreboard objectives add zx.lsh_ft dummy
execute unless data storage zx:config obj_lsh_ft run data modify storage zx:config obj_lsh_ft set value 1b



# 长明灯灵：显示与状态计分项（2026-10-14）
function sweetdream:equipment/tool/everlit/visual/load

function sweetdream:equipment/sword/flame_brokenbody/visual/load
function sweetdream:equipment/axe/anchor/visual/load
function sweetdream:equipment/bow/burst_dawn/visual/load
execute unless data storage zx:config obj_hurt_evt run scoreboard objectives add zx.hurt_evt dummy
execute unless data storage zx:config obj_hurt_evt run data modify storage zx:config obj_hurt_evt set value 1b
execute unless data storage zx:config obj_hurt_at run scoreboard objectives add zx.hurt_at dummy
execute unless data storage zx:config obj_hurt_at run data modify storage zx:config obj_hurt_at set value 1b
execute unless data storage zx:config obj_sf_hp run scoreboard objectives add zx.sf_hp dummy
execute unless data storage zx:config obj_sf_hp run data modify storage zx:config obj_sf_hp set value 1b
data modify storage zx:work shot_stack set value []
execute unless data storage zx:config obj_nb_extra run scoreboard objectives add zx.nb_extra dummy
execute unless data storage zx:config obj_nb_extra run data modify storage zx:config obj_nb_extra set value 1b
execute unless data storage zx:config obj_tjl_end run scoreboard objectives add zx.tjl_end dummy
execute unless data storage zx:config obj_tjl_end run data modify storage zx:config obj_tjl_end set value 1b
execute unless data storage zx:config obj_tjl_next run scoreboard objectives add zx.tjl_next dummy
execute unless data storage zx:config obj_tjl_next run data modify storage zx:config obj_tjl_next set value 1b
execute unless data storage zx:config obj_tjl_id run scoreboard objectives add zx.tjl_id dummy
execute unless data storage zx:config obj_tjl_id run data modify storage zx:config obj_tjl_id set value 1b
scoreboard players add #tjl_serial zx.meta 0
data modify storage zx:work damage_stack set value []
scoreboard players set #15 zx.meta 15
execute unless data storage zx:config obj_rt_hit run scoreboard objectives add zx.rt_hit dummy
execute unless data storage zx:config obj_rt_hit run data modify storage zx:config obj_rt_hit set value 1b
execute unless data storage zx:config obj_hurt_total run scoreboard objectives add zx.hurt_total minecraft.custom:minecraft.damage_taken
execute unless data storage zx:config obj_hurt_total run data modify storage zx:config obj_hurt_total set value 1b
execute unless data storage zx:config obj_hurt_seen run scoreboard objectives add zx.hurt_seen dummy
execute unless data storage zx:config obj_hurt_seen run data modify storage zx:config obj_hurt_seen set value 1b

# ===== 碎骨(2026-10-25 批 14): 「碎刀」三把旋转刀刃 =====
#   zx.bb_own  = 刀刃属于谁(主人的 UUID 第 0 个整数, 用来判"自己场上还有没有碎刀")
#   zx.bb_life = 还剩几刻(8 秒 = 160 刻)
#   zx.bb_a    = 当前角度档位(0..23, 每刻 +1)
#   zx.bb_dmg  = 这一把刀造成的伤害 ×1000(基础攻击力 ×0.3, 每 20 刻跟着面板重算)
execute unless data storage zx:config obj_bb_own run scoreboard objectives add zx.bb_own dummy
execute unless data storage zx:config obj_bb_own run data modify storage zx:config obj_bb_own set value 1b
execute unless data storage zx:config obj_bb_life run scoreboard objectives add zx.bb_life dummy
execute unless data storage zx:config obj_bb_life run data modify storage zx:config obj_bb_life set value 1b
execute unless data storage zx:config obj_bb_a run scoreboard objectives add zx.bb_a dummy
execute unless data storage zx:config obj_bb_a run data modify storage zx:config obj_bb_a set value 1b
execute unless data storage zx:config obj_bb_dmg run scoreboard objectives add zx.bb_dmg dummy
execute unless data storage zx:config obj_bb_dmg run data modify storage zx:config obj_bb_dmg set value 1b
#    24 = 角度档位数(每档 15°); 没 set 过的常数一律是 0, `operation -= #24` 会白减
scoreboard players set #24 zx.meta 24
#    重载 / 换存档时把上一局的刀清干净(临时表现实体, 不该跨局留着)
kill @e[tag=zx.bb_blade]
kill @e[tag=zx.bb_new]

# ===== 明烛(2026-10-25 批 14): 「烛火」 =====
#   zx.bc_life = 烛火还剩几秒(10 秒)
#   zx.bc_own  = 烛火属于谁(主人的 UUID 第 0 个整数)
#   zx.bc_gate = 主人"下次可以再召唤烛火"的绝对 tick(8 秒节流)
#   zx.bc_dw   = 生物在烛火圈里的**累计**停留秒数(记在生物身上 —— 见下方清洗)
execute unless data storage zx:config obj_bc_life run scoreboard objectives add zx.bc_life dummy
execute unless data storage zx:config obj_bc_life run data modify storage zx:config obj_bc_life set value 1b
execute unless data storage zx:config obj_bc_own run scoreboard objectives add zx.bc_own dummy
execute unless data storage zx:config obj_bc_own run data modify storage zx:config obj_bc_own set value 1b
execute unless data storage zx:config obj_bc_gate run scoreboard objectives add zx.bc_gate dummy
execute unless data storage zx:config obj_bc_gate run data modify storage zx:config obj_bc_gate set value 1b
execute unless data storage zx:config obj_bc_dw run scoreboard objectives add zx.bc_dw dummy
execute unless data storage zx:config obj_bc_dw run data modify storage zx:config obj_bc_dw set value 1b
#    ★★ 临时分数打在生物身上会**永久留在存档** ⇒ 三维度兜底全清(铁律 ④)。
#       这条分数只用于计时、不挂任何判死逻辑, 残留不会误杀, 但仍必须清。
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.bc_dw
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.bc_dw
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.bc_dw
kill @e[tag=zx.bc_fire]
kill @e[tag=zx.bc_new]

# ===== 借火(2026-10-25 批 14) =====
#   zx.bf_rdy  = 充能(1 = 下一次平A 会触发借火)
#   zx.bf_end  = 目标身上"削减到点"的绝对 tick
#   zx.bf_oend = 玩家身上"增益到点"的绝对 tick
#   zx.bf_mana = 套装 +100 上限的账本(到点按它退还)
execute unless data storage zx:config obj_bf_rdy run scoreboard objectives add zx.bf_rdy dummy
execute unless data storage zx:config obj_bf_rdy run data modify storage zx:config obj_bf_rdy set value 1b
execute unless data storage zx:config obj_bf_end run scoreboard objectives add zx.bf_end dummy
execute unless data storage zx:config obj_bf_end run data modify storage zx:config obj_bf_end set value 1b
execute unless data storage zx:config obj_bf_oend run scoreboard objectives add zx.bf_oend dummy
execute unless data storage zx:config obj_bf_oend run data modify storage zx:config obj_bf_oend set value 1b
execute unless data storage zx:config obj_bf_mana run scoreboard objectives add zx.bf_mana dummy
execute unless data storage zx:config obj_bf_mana run data modify storage zx:config obj_bf_mana set value 1b
#    250 = 剩余燃烧时间(刻) -> 伤害×1000 的换算系数(÷20 换秒 ×5 = ×0.25 ⇒ ×250 定点)
#    50  = 2% 的定点除数(×1000 ÷ 50 = ×0.02 ×1000)
scoreboard players set #250 zx.meta 250
scoreboard players set #50 zx.meta 50
#    重载时把上一局没撤干净的 modifier 与标签清一遍(modifier 存在实体上, 会跨局留着)
execute as @a run attribute @s minecraft:armor modifier remove sweetdream:bf_a_up
execute as @a run attribute @s minecraft:armor_toughness modifier remove sweetdream:bf_t_up
execute as @e[tag=zx.bf_strip,distance=0..] run attribute @s minecraft:armor modifier remove sweetdream:bf_a_dn
execute as @e[tag=zx.bf_strip,distance=0..] run attribute @s minecraft:armor_toughness modifier remove sweetdream:bf_t_dn
tag @e[tag=zx.bf_strip,distance=0..] remove zx.bf_strip

# ===== 心脉(2026-10-25 批 14): 「泵动」 =====
#   zx.hv_cd   = 玩家"受击上噬心"的下次可触发绝对 tick(6 秒节流, 打在玩家身上)
#   zx.hv_t    = 「泵动」剩余刻数(记在生物身上)
#   zx.hv_gate = 移动结算的 0.5 秒闸门(记在生物身上)
#   zx.hv_px/py/pz = 上一次结算时的锚点坐标 ×100(记在生物身上)
#   zx.hv_u0..u3   = 这一份泵动属于哪个玩家(UUID 四个 int, 记在生物身上)
execute unless data storage zx:config obj_hv_cd run scoreboard objectives add zx.hv_cd dummy
execute unless data storage zx:config obj_hv_cd run data modify storage zx:config obj_hv_cd set value 1b
execute unless data storage zx:config obj_hv_t run scoreboard objectives add zx.hv_t dummy
execute unless data storage zx:config obj_hv_t run data modify storage zx:config obj_hv_t set value 1b
execute unless data storage zx:config obj_hv_gate run scoreboard objectives add zx.hv_gate dummy
execute unless data storage zx:config obj_hv_gate run data modify storage zx:config obj_hv_gate set value 1b
execute unless data storage zx:config obj_hv_px run scoreboard objectives add zx.hv_px dummy
execute unless data storage zx:config obj_hv_px run data modify storage zx:config obj_hv_px set value 1b
execute unless data storage zx:config obj_hv_py run scoreboard objectives add zx.hv_py dummy
execute unless data storage zx:config obj_hv_py run data modify storage zx:config obj_hv_py set value 1b
execute unless data storage zx:config obj_hv_pz run scoreboard objectives add zx.hv_pz dummy
execute unless data storage zx:config obj_hv_pz run data modify storage zx:config obj_hv_pz set value 1b
execute unless data storage zx:config obj_hv_u0 run scoreboard objectives add zx.hv_u0 dummy
execute unless data storage zx:config obj_hv_u0 run data modify storage zx:config obj_hv_u0 set value 1b
execute unless data storage zx:config obj_hv_u1 run scoreboard objectives add zx.hv_u1 dummy
execute unless data storage zx:config obj_hv_u1 run data modify storage zx:config obj_hv_u1 set value 1b
execute unless data storage zx:config obj_hv_u2 run scoreboard objectives add zx.hv_u2 dummy
execute unless data storage zx:config obj_hv_u2 run data modify storage zx:config obj_hv_u2 set value 1b
execute unless data storage zx:config obj_hv_u3 run scoreboard objectives add zx.hv_u3 dummy
execute unless data storage zx:config obj_hv_u3 run data modify storage zx:config obj_hv_u3 set value 1b
#    ★★ 前 9 个（除 hv_cd）全打在**生物**身上 ⇒ 永久留存档, 三维度兜底全清(铁律 ④)。
#       它们只用于计时/锚点/归属, 不挂任何判死逻辑, 残留不会误杀, 但仍必须清。
execute in minecraft:overworld as @e[distance=0..] run function sweetdream:equipment/armor/heart_vein/pump_end
execute in minecraft:the_nether as @e[distance=0..] run function sweetdream:equipment/armor/heart_vein/pump_end
execute in minecraft:the_end as @e[distance=0..] run function sweetdream:equipment/armor/heart_vein/pump_end

# ===== 剖面 + 魔力花费账本(2026-10-25 批 14) =====
#   zx.pm_sum = 玩家累计**实际花掉**的魔力(魔力 ×1000; 由 lib/mana/pay 记账)
#   zx.pf_mul = 剖面"+20%"的百分点 / zx.pf_mn = 剩余次数 / zx.pf_mt = 窗口到期绝对 tick
#   zx.pf_lt  = 同刻去重(玩家)
#   zx.pf_hit = 这只生物被穿剖面的人打了几次(记在生物身上)
#   zx.pf_hl  = 同刻同目标去重(记在生物身上)
#   zx.pf_cd  = 每只生物"兑现"的 8 秒节流 / zx.pf_scd = 套装的 10 秒节流(记在生物身上)
execute unless data storage zx:config obj_pm_sum run scoreboard objectives add zx.pm_sum dummy
execute unless data storage zx:config obj_pm_sum run data modify storage zx:config obj_pm_sum set value 1b
execute unless data storage zx:config obj_pf_mul run scoreboard objectives add zx.pf_mul dummy
execute unless data storage zx:config obj_pf_mul run data modify storage zx:config obj_pf_mul set value 1b
execute unless data storage zx:config obj_pf_mn run scoreboard objectives add zx.pf_mn dummy
execute unless data storage zx:config obj_pf_mn run data modify storage zx:config obj_pf_mn set value 1b
execute unless data storage zx:config obj_pf_mt run scoreboard objectives add zx.pf_mt dummy
execute unless data storage zx:config obj_pf_mt run data modify storage zx:config obj_pf_mt set value 1b
execute unless data storage zx:config obj_pf_lt run scoreboard objectives add zx.pf_lt dummy
execute unless data storage zx:config obj_pf_lt run data modify storage zx:config obj_pf_lt set value 1b
execute unless data storage zx:config obj_pf_hit run scoreboard objectives add zx.pf_hit dummy
execute unless data storage zx:config obj_pf_hit run data modify storage zx:config obj_pf_hit set value 1b
execute unless data storage zx:config obj_pf_hl run scoreboard objectives add zx.pf_hl dummy
execute unless data storage zx:config obj_pf_hl run data modify storage zx:config obj_pf_hl set value 1b
execute unless data storage zx:config obj_pf_cd run scoreboard objectives add zx.pf_cd dummy
execute unless data storage zx:config obj_pf_cd run data modify storage zx:config obj_pf_cd set value 1b
execute unless data storage zx:config obj_pf_scd run scoreboard objectives add zx.pf_scd dummy
execute unless data storage zx:config obj_pf_scd run data modify storage zx:config obj_pf_scd set value 1b
#    ★★ pf_hit / pf_hl / pf_cd / pf_scd 打在**生物**身上 ⇒ 永久留存档, 三维度兜底全清。
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.pf_hit
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.pf_hit
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.pf_hit
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.pf_hl
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.pf_hl
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.pf_hl
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.pf_cd
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.pf_cd
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.pf_cd
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.pf_scd
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.pf_scd
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.pf_scd

# ===== 折潮(2026-10-25 批 14): 水墙 =====
#   —— 记在**墙 marker** 身上（活 10 秒, 到寿由 wall_end 自己清）
#   zx.tf_life = 剩余刻数 / zx.tf_fx = 粒子间隔计数 / zx.tf_id = 墙编号(0..3)
#   zx.tf_u0..u3 = 立墙的人(UUID 四个 int)
#   —— 记在**生物/玩家**身上（★ 永久留存档, 三维度兜底清）
#   zx.tf_cw = 上次穿过的墙编号 / zx.tf_ct = 那次节流的到期绝对 tick
#   zx.tf_mg = 主人回蓝的 2 秒闸门(到期绝对 tick)
#   —— 记在玩家身上
#   zx.tf_sum = 累计实际花掉的魔力(魔力 ×1000; 攒够 150000 立一面墙)
execute unless data storage zx:config obj_tf_life run scoreboard objectives add zx.tf_life dummy
execute unless data storage zx:config obj_tf_life run data modify storage zx:config obj_tf_life set value 1b
execute unless data storage zx:config obj_tf_fx run scoreboard objectives add zx.tf_fx dummy
execute unless data storage zx:config obj_tf_fx run data modify storage zx:config obj_tf_fx set value 1b
execute unless data storage zx:config obj_tf_id run scoreboard objectives add zx.tf_id dummy
execute unless data storage zx:config obj_tf_id run data modify storage zx:config obj_tf_id set value 1b
execute unless data storage zx:config obj_tf_u0 run scoreboard objectives add zx.tf_u0 dummy
execute unless data storage zx:config obj_tf_u0 run data modify storage zx:config obj_tf_u0 set value 1b
execute unless data storage zx:config obj_tf_u1 run scoreboard objectives add zx.tf_u1 dummy
execute unless data storage zx:config obj_tf_u1 run data modify storage zx:config obj_tf_u1 set value 1b
execute unless data storage zx:config obj_tf_u2 run scoreboard objectives add zx.tf_u2 dummy
execute unless data storage zx:config obj_tf_u2 run data modify storage zx:config obj_tf_u2 set value 1b
execute unless data storage zx:config obj_tf_u3 run scoreboard objectives add zx.tf_u3 dummy
execute unless data storage zx:config obj_tf_u3 run data modify storage zx:config obj_tf_u3 set value 1b
execute unless data storage zx:config obj_tf_cw run scoreboard objectives add zx.tf_cw dummy
execute unless data storage zx:config obj_tf_cw run data modify storage zx:config obj_tf_cw set value 1b
execute unless data storage zx:config obj_tf_ct run scoreboard objectives add zx.tf_ct dummy
execute unless data storage zx:config obj_tf_ct run data modify storage zx:config obj_tf_ct set value 1b
execute unless data storage zx:config obj_tf_mg run scoreboard objectives add zx.tf_mg dummy
execute unless data storage zx:config obj_tf_mg run data modify storage zx:config obj_tf_mg set value 1b
execute unless data storage zx:config obj_tf_sum run scoreboard objectives add zx.tf_sum dummy
execute unless data storage zx:config obj_tf_sum run data modify storage zx:config obj_tf_sum set value 1b
#    ★★ tf_cw / tf_ct / tf_mg 打在**生物**身上 ⇒ 永久留存档(铁律), 三维度兜底全清。
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.tf_cw
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.tf_cw
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.tf_cw
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.tf_ct
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.tf_ct
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.tf_ct
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.tf_mg
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.tf_mg
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.tf_mg
#    墙是纯表现 marker, 重载直接清场(走 wall_end, 顺手把分数也 reset 掉)
execute in minecraft:overworld as @e[tag=zx.tf_wall,distance=0..] at @s run function sweetdream:equipment/armor/tide_fold/wall_end
execute in minecraft:the_nether as @e[tag=zx.tf_wall,distance=0..] at @s run function sweetdream:equipment/armor/tide_fold/wall_end
execute in minecraft:the_end as @e[tag=zx.tf_wall,distance=0..] at @s run function sweetdream:equipment/armor/tide_fold/wall_end
scoreboard players set #tf_seq zx.meta 0

# ===== 返汐(2026-10-25 批 14): 海浪 =====
#   —— 记在**海浪 marker** 身上（活 5 秒, 到寿/被顶掉由 wave_end 清）
#   zx.et_life = 剩余刻数 / zx.et_fx = 粒子间隔 / zx.et_wid = 属于哪只渊海生物
#   —— 记在**生物**身上（★ 永久留存档, 三维度兜底清）
#   zx.et_e  = 移速削减档位(0..30, 每档 -1%)
#   zx.et_du = "减速 modifier 是否已经挂上"的账本(0/1)
#   zx.et_on = "这一秒在不在浪上"的戳(存的是 #now)
#   zx.et_wid= 这只生物自己的海浪编号(稳定, 用于"旧片被新片顶掉")
#   zx.et_ok = 位移锚点建过没有 / zx.et_px/py/pz = 上次补片锚点(坐标 ×100)
#   —— 记在**玩家**身上
#   zx.et_s  = 自身移速加成档位(0..20, 每档 +1%)
#   zx.et_su = "加速 modifier 是否已经挂上"的账本(0/1)
#   zx.et_b  = 靴子本体 +10% 移速的账本(0/1)
#   zx.et_sa = 补片采样的 0.5 秒闸门(到期绝对 tick)
execute unless data storage zx:config obj_et_life run scoreboard objectives add zx.et_life dummy
execute unless data storage zx:config obj_et_life run data modify storage zx:config obj_et_life set value 1b
execute unless data storage zx:config obj_et_fx run scoreboard objectives add zx.et_fx dummy
execute unless data storage zx:config obj_et_fx run data modify storage zx:config obj_et_fx set value 1b
execute unless data storage zx:config obj_et_wid run scoreboard objectives add zx.et_wid dummy
execute unless data storage zx:config obj_et_wid run data modify storage zx:config obj_et_wid set value 1b
execute unless data storage zx:config obj_et_e run scoreboard objectives add zx.et_e dummy
execute unless data storage zx:config obj_et_e run data modify storage zx:config obj_et_e set value 1b
execute unless data storage zx:config obj_et_du run scoreboard objectives add zx.et_du dummy
execute unless data storage zx:config obj_et_du run data modify storage zx:config obj_et_du set value 1b
execute unless data storage zx:config obj_et_on run scoreboard objectives add zx.et_on dummy
execute unless data storage zx:config obj_et_on run data modify storage zx:config obj_et_on set value 1b
execute unless data storage zx:config obj_et_ok run scoreboard objectives add zx.et_ok dummy
execute unless data storage zx:config obj_et_ok run data modify storage zx:config obj_et_ok set value 1b
execute unless data storage zx:config obj_et_px run scoreboard objectives add zx.et_px dummy
execute unless data storage zx:config obj_et_px run data modify storage zx:config obj_et_px set value 1b
execute unless data storage zx:config obj_et_py run scoreboard objectives add zx.et_py dummy
execute unless data storage zx:config obj_et_py run data modify storage zx:config obj_et_py set value 1b
execute unless data storage zx:config obj_et_pz run scoreboard objectives add zx.et_pz dummy
execute unless data storage zx:config obj_et_pz run data modify storage zx:config obj_et_pz set value 1b
execute unless data storage zx:config obj_et_s run scoreboard objectives add zx.et_s dummy
execute unless data storage zx:config obj_et_s run data modify storage zx:config obj_et_s set value 1b
execute unless data storage zx:config obj_et_su run scoreboard objectives add zx.et_su dummy
execute unless data storage zx:config obj_et_su run data modify storage zx:config obj_et_su set value 1b
execute unless data storage zx:config obj_et_b run scoreboard objectives add zx.et_b dummy
execute unless data storage zx:config obj_et_b run data modify storage zx:config obj_et_b set value 1b
execute unless data storage zx:config obj_et_sa run scoreboard objectives add zx.et_sa dummy
execute unless data storage zx:config obj_et_sa run data modify storage zx:config obj_et_sa set value 1b
#    ★★ et_e / et_du / et_on / et_wid / et_ok / et_px/py/pz 打在**生物**身上 ⇒ 永久留存档
execute in minecraft:overworld as @e[distance=0..] run function sweetdream:equipment/armor/ebb_tide/entity_reset
execute in minecraft:the_nether as @e[distance=0..] run function sweetdream:equipment/armor/ebb_tide/entity_reset
execute in minecraft:the_end as @e[distance=0..] run function sweetdream:equipment/armor/ebb_tide/entity_reset
#    海浪是纯表现 marker, 重载直接清场
execute in minecraft:overworld as @e[tag=zx.et_wave,distance=0..] at @s run function sweetdream:equipment/armor/ebb_tide/wave_end
execute in minecraft:the_nether as @e[tag=zx.et_wave,distance=0..] at @s run function sweetdream:equipment/armor/ebb_tide/wave_end
execute in minecraft:the_end as @e[tag=zx.et_wave,distance=0..] at @s run function sweetdream:equipment/armor/ebb_tide/wave_end
scoreboard players set #et_wid zx.meta 0
#    脱下靴子时把身上残留的两条 modifier 摘掉(重载 = 一次全量重挂)
execute as @a run scoreboard players set @s zx.et_b 0
execute as @a[scores={zx.et_su=1}] run attribute @s minecraft:movement_speed modifier remove sweetdream:et_up
execute as @a run scoreboard players set @s zx.et_su 0

# ===== 浮光(2026-10-25 ★按用户 16:53 原稿重写★): 红 / 绿 / 黄 三色 + 白 =====
#   ★★ 上一版(碎光 / 棱镜残片 / 合光 / 白光束)与"优先补齐缺色"都是我自编的, 已全部
#      作废 —— 用户原稿是"随机获得一种光效"。别再复活。
#   —— 记在**玩家**身上
#   zx.gl_r / gl_g / gl_y = 是否拥有该色(0/1); **三个都 1 就是"白"**(不另设白光标志位)
#   zx.gl_lh   = 上次"受伤 or 发了一道光"的时刻 —— 8 秒(160 刻)的门槛
#   zx.gl_hp   = 上一刻的生命值(zx.hp_c); 变小 ⇒ 失去全部光效
#   zx.gl_hacc = 毫血累加器(绿 1%/白 3% 每秒只有 0.2~0.6 点, 整数除法会整个吃掉)
#   zx.gl_spd  = 自身移速 modifier 账本(0 没挂 / 1 = 黄 +20% / 2 = 白 +30%)
#   zx.gl_cd   = 白·群体白昼梦的下次可触发时刻(3 秒节流)
#   —— 记在**生物**身上(★ 永久留存档, 三维度兜底清)
#   zx.gl_slt  = 被浮光减速的剩余刻(2 秒缓冲; 到期自己摘 modifier)
#   zx.gl_fv   = 该生物当前挂着哪一档减速(0 / 40 / 45)
execute unless data storage zx:config obj_gl_r run scoreboard objectives add zx.gl_r dummy
execute unless data storage zx:config obj_gl_r run data modify storage zx:config obj_gl_r set value 1b
execute unless data storage zx:config obj_gl_g run scoreboard objectives add zx.gl_g dummy
execute unless data storage zx:config obj_gl_g run data modify storage zx:config obj_gl_g set value 1b
execute unless data storage zx:config obj_gl_y run scoreboard objectives add zx.gl_y dummy
execute unless data storage zx:config obj_gl_y run data modify storage zx:config obj_gl_y set value 1b
execute unless data storage zx:config obj_gl_lh run scoreboard objectives add zx.gl_lh dummy
execute unless data storage zx:config obj_gl_lh run data modify storage zx:config obj_gl_lh set value 1b
execute unless data storage zx:config obj_gl_hp run scoreboard objectives add zx.gl_hp dummy
execute unless data storage zx:config obj_gl_hp run data modify storage zx:config obj_gl_hp set value 1b
execute unless data storage zx:config obj_gl_hacc run scoreboard objectives add zx.gl_hacc dummy
execute unless data storage zx:config obj_gl_hacc run data modify storage zx:config obj_gl_hacc set value 1b
execute unless data storage zx:config obj_gl_spd run scoreboard objectives add zx.gl_spd dummy
execute unless data storage zx:config obj_gl_spd run data modify storage zx:config obj_gl_spd set value 1b
execute unless data storage zx:config obj_gl_cd run scoreboard objectives add zx.gl_cd dummy
execute unless data storage zx:config obj_gl_cd run data modify storage zx:config obj_gl_cd set value 1b
execute unless data storage zx:config obj_gl_slt run scoreboard objectives add zx.gl_slt dummy
execute unless data storage zx:config obj_gl_slt run data modify storage zx:config obj_gl_slt set value 1b
execute unless data storage zx:config obj_gl_fv run scoreboard objectives add zx.gl_fv dummy
execute unless data storage zx:config obj_gl_fv run data modify storage zx:config obj_gl_fv set value 1b
#    ★★ 生物侧的 gl_slt / gl_fv 必须**连 modifier 一起撤** —— 只清分数的话
#       那条 -40%/-45% 移速会永远留在怪身上(实体数据, 不是效果)。
#    摘 modifier 时两条都试: 挂 40 的那只 remove 45 会失败, 但两行各自独立, 无副作用。
execute in minecraft:overworld as @e[tag=zx.gl_sl,distance=0..] run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow40
execute in minecraft:overworld as @e[tag=zx.gl_sl,distance=0..] run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow45
execute in minecraft:overworld as @e[tag=zx.gl_sl,distance=0..] run tag @s remove zx.gl_sl
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.gl_slt
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.gl_fv
execute in minecraft:the_nether as @e[tag=zx.gl_sl,distance=0..] run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow40
execute in minecraft:the_nether as @e[tag=zx.gl_sl,distance=0..] run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow45
execute in minecraft:the_nether as @e[tag=zx.gl_sl,distance=0..] run tag @s remove zx.gl_sl
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.gl_slt
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.gl_fv
execute in minecraft:the_end as @e[tag=zx.gl_sl,distance=0..] run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow40
execute in minecraft:the_end as @e[tag=zx.gl_sl,distance=0..] run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_slow45
execute in minecraft:the_end as @e[tag=zx.gl_sl,distance=0..] run tag @s remove zx.gl_sl
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.gl_slt
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.gl_fv
#    玩家侧: 重载清光(否则重进世界会带着上一局的三色), 移速 modifier 也要摘
#    ★ 必须先按账本摘再 reset 账本 —— 顺序反过来就再也找不到"挂过没有"了。
execute as @a[scores={zx.gl_spd=1..}] run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_spd
execute as @a run scoreboard players reset @s zx.gl_r
execute as @a run scoreboard players reset @s zx.gl_g
execute as @a run scoreboard players reset @s zx.gl_y
execute as @a run scoreboard players reset @s zx.gl_lh
execute as @a run scoreboard players reset @s zx.gl_hp
execute as @a run scoreboard players reset @s zx.gl_hacc
execute as @a run scoreboard players reset @s zx.gl_spd
execute as @a run scoreboard players reset @s zx.gl_cd
execute as @a run scoreboard players reset @s zx.gl_slt
execute as @a run scoreboard players reset @s zx.gl_fv

# ===== 迟暮(2026-10-25 ★按用户 16:53 原稿重写★): 「回光」+ 5 秒伤害记录 =====
#   ★★ 上一版(暮账 / 暮痕 / 背水)是我自编的, 已全部作废 —— 别再复活。
#   —— 记在**玩家**身上
#   zx.ld_s  = 「回光」层数(自身被附加白昼梦时 +1, 15 秒统一到期)
#   zx.ld_t  = 回光到期时刻(#now + 300)
#   zx.ld_c  = 累计消耗**次数**(到 3 ⇒ 抗性提升Ⅴ, 随即归零重新数; 不是可攒资源)
#   zx.ld_r5 = 抗性提升Ⅴ的到期时刻(≥1 = 这个抗性是我们给的, 受伤即清)
#   —— 记在**生物**身上(★ 永久留存档, 三维度兜底清)
#   zx.ld_rt = 伤害记录窗口剩余刻(100 = 5 秒)
#   zx.ld_rec= 窗口内累计伤害(×1000 定点)
#   zx.ld_u0..u3 = 这笔账算谁的(攻击者 UUID; 结算时投递用)
execute unless data storage zx:config obj_ld_s run scoreboard objectives add zx.ld_s dummy
execute unless data storage zx:config obj_ld_s run data modify storage zx:config obj_ld_s set value 1b
execute unless data storage zx:config obj_ld_t run scoreboard objectives add zx.ld_t dummy
execute unless data storage zx:config obj_ld_t run data modify storage zx:config obj_ld_t set value 1b
execute unless data storage zx:config obj_ld_c run scoreboard objectives add zx.ld_c dummy
execute unless data storage zx:config obj_ld_c run data modify storage zx:config obj_ld_c set value 1b
execute unless data storage zx:config obj_ld_r5 run scoreboard objectives add zx.ld_r5 dummy
execute unless data storage zx:config obj_ld_r5 run data modify storage zx:config obj_ld_r5 set value 1b
execute unless data storage zx:config obj_ld_rt run scoreboard objectives add zx.ld_rt dummy
execute unless data storage zx:config obj_ld_rt run data modify storage zx:config obj_ld_rt set value 1b
execute unless data storage zx:config obj_ld_rec run scoreboard objectives add zx.ld_rec dummy
execute unless data storage zx:config obj_ld_rec run data modify storage zx:config obj_ld_rec set value 1b
execute unless data storage zx:config obj_ld_u0 run scoreboard objectives add zx.ld_u0 dummy
execute unless data storage zx:config obj_ld_u0 run data modify storage zx:config obj_ld_u0 set value 1b
execute unless data storage zx:config obj_ld_u1 run scoreboard objectives add zx.ld_u1 dummy
execute unless data storage zx:config obj_ld_u1 run data modify storage zx:config obj_ld_u1 set value 1b
execute unless data storage zx:config obj_ld_u2 run scoreboard objectives add zx.ld_u2 dummy
execute unless data storage zx:config obj_ld_u2 run data modify storage zx:config obj_ld_u2 set value 1b
execute unless data storage zx:config obj_ld_u3 run scoreboard objectives add zx.ld_u3 dummy
execute unless data storage zx:config obj_ld_u3 run data modify storage zx:config obj_ld_u3 set value 1b
#    生物侧: 记录窗口的分数三维度兜底清 + 摘标签
#    ★ 只清分数不摘标签的话, core/tick 会一直对着一只"带标签但窗口已关"的怪空转。
execute in minecraft:overworld as @e[distance=0..] run tag @s remove zx.ld_rec_on
execute in minecraft:the_nether as @e[distance=0..] run tag @s remove zx.ld_rec_on
execute in minecraft:the_end as @e[distance=0..] run tag @s remove zx.ld_rec_on
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.ld_rt
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.ld_rt
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.ld_rt
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.ld_rec
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.ld_rec
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.ld_rec
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.ld_u0
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.ld_u0
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.ld_u0
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.ld_u1
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.ld_u1
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.ld_u1
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.ld_u2
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.ld_u2
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.ld_u2
execute in minecraft:overworld as @e[distance=0..] run scoreboard players reset @s zx.ld_u3
execute in minecraft:the_nether as @e[distance=0..] run scoreboard players reset @s zx.ld_u3
execute in minecraft:the_end as @e[distance=0..] run scoreboard players reset @s zx.ld_u3
#    玩家侧: 回光/累计/抗性标记清零（不该跨重载或重进世界留存）
execute as @a run scoreboard players reset @s zx.ld_s
execute as @a run scoreboard players reset @s zx.ld_t
execute as @a run scoreboard players reset @s zx.ld_c
execute as @a run scoreboard players reset @s zx.ld_r5

execute unless data storage zx:config obj_gl_wt run scoreboard objectives add zx.gl_wt dummy
data modify storage zx:config obj_gl_wt set value 1b
execute unless data storage zx:config obj_regen_milli run scoreboard objectives add zx.regen_milli dummy
data modify storage zx:config obj_regen_milli set value 1b
execute unless data storage zx:config obj_regen_last_m run scoreboard objectives add zx.regen_last_m dummy
data modify storage zx:config obj_regen_last_m set value 1b
execute unless data storage zx:config obj_et_stack_t run scoreboard objectives add zx.et_stack_t dummy
data modify storage zx:config obj_et_stack_t set value 1b

execute unless data storage zx:config obj_hv_hacc run scoreboard objectives add zx.hv_hacc dummy
data modify storage zx:config obj_hv_hacc set value 1b
execute unless data storage zx:config obj_bc_touch run scoreboard objectives add zx.bc_touch dummy
data modify storage zx:config obj_bc_touch set value 1b

execute unless data storage zx:config obj_tf_exp run scoreboard objectives add zx.tf_exp dummy
data modify storage zx:config obj_tf_exp set value 1b

execute in minecraft:overworld run kill @e[tag=zx.bc_contact,distance=0..]

execute in minecraft:the_nether run kill @e[tag=zx.bc_contact,distance=0..]

execute in minecraft:the_end run kill @e[tag=zx.bc_contact,distance=0..]

execute in minecraft:overworld run kill @e[tag=zx.tf_prev,distance=0..]
execute in minecraft:overworld run kill @e[tag=zx.lr_record,distance=0..]
execute in minecraft:overworld as @e[tag=zx.lr_watch,distance=0..] run tag @s remove zx.lr_watch

execute in minecraft:the_nether run kill @e[tag=zx.tf_prev,distance=0..]
execute in minecraft:the_nether run kill @e[tag=zx.lr_record,distance=0..]
execute in minecraft:the_nether as @e[tag=zx.lr_watch,distance=0..] run tag @s remove zx.lr_watch

execute in minecraft:the_end run kill @e[tag=zx.tf_prev,distance=0..]
execute in minecraft:the_end run kill @e[tag=zx.lr_record,distance=0..]
execute in minecraft:the_end as @e[tag=zx.lr_watch,distance=0..] run tag @s remove zx.lr_watch

execute unless data storage zx:config obj_bc_end run scoreboard objectives add zx.bc_end dummy
data modify storage zx:config obj_bc_end set value 1b
execute unless data storage zx:config obj_bc_far run scoreboard objectives add zx.bc_far dummy
data modify storage zx:config obj_bc_far set value 1b
execute unless data storage zx:config obj_bc_fx run scoreboard objectives add zx.bc_fx dummy
data modify storage zx:config obj_bc_fx set value 1b
execute unless data storage zx:config obj_bc_id run scoreboard objectives add zx.bc_id dummy
data modify storage zx:config obj_bc_id set value 1b
execute unless data storage zx:config obj_bc_near run scoreboard objectives add zx.bc_near dummy
data modify storage zx:config obj_bc_near set value 1b
execute unless data storage zx:config obj_bc_next run scoreboard objectives add zx.bc_next dummy
data modify storage zx:config obj_bc_next set value 1b
execute unless data storage zx:config obj_bc_parent run scoreboard objectives add zx.bc_parent dummy
data modify storage zx:config obj_bc_parent set value 1b
execute unless data storage zx:config obj_bc_target run scoreboard objectives add zx.bc_target dummy
data modify storage zx:config obj_bc_target set value 1b
execute unless data storage zx:config obj_hv_path_v run scoreboard objectives add zx.hv_path_v dummy
data modify storage zx:config obj_hv_path_v set value 1b
execute unless data storage zx:config obj_hv_walk run scoreboard objectives add zx.hv_walk dummy
data modify storage zx:config obj_hv_walk set value 1b
execute unless data storage zx:config obj_lr_ab run scoreboard objectives add zx.lr_ab dummy
data modify storage zx:config obj_lr_ab set value 1b
execute unless data storage zx:config obj_lr_end run scoreboard objectives add zx.lr_end dummy
data modify storage zx:config obj_lr_end set value 1b
execute unless data storage zx:config obj_lr_hp run scoreboard objectives add zx.lr_hp dummy
data modify storage zx:config obj_lr_hp set value 1b
execute unless data storage zx:config obj_lr_live run scoreboard objectives add zx.lr_live dummy
data modify storage zx:config obj_lr_live set value 1b
execute unless data storage zx:config obj_lr_sum run scoreboard objectives add zx.lr_sum dummy
data modify storage zx:config obj_lr_sum set value 1b
execute unless data storage zx:config obj_nh_ab run scoreboard objectives add zx.nh_ab dummy
data modify storage zx:config obj_nh_ab set value 1b
execute unless data storage zx:config obj_nh_hp run scoreboard objectives add zx.nh_hp dummy
data modify storage zx:config obj_nh_hp set value 1b
execute unless data storage zx:config obj_nh_stamp run scoreboard objectives add zx.nh_stamp dummy
data modify storage zx:config obj_nh_stamp set value 1b
execute unless data storage zx:config obj_sid run scoreboard objectives add zx.sid dummy
data modify storage zx:config obj_sid set value 1b
execute unless data storage zx:config obj_tf_born run scoreboard objectives add zx.tf_born dummy
data modify storage zx:config obj_tf_born set value 1b
execute unless data storage zx:config obj_tf_cx run scoreboard objectives add zx.tf_cx dummy
data modify storage zx:config obj_tf_cx set value 1b
execute unless data storage zx:config obj_tf_cy run scoreboard objectives add zx.tf_cy dummy
data modify storage zx:config obj_tf_cy set value 1b
execute unless data storage zx:config obj_tf_cz run scoreboard objectives add zx.tf_cz dummy
data modify storage zx:config obj_tf_cz set value 1b
execute unless data storage zx:config obj_tf_end run scoreboard objectives add zx.tf_end dummy
data modify storage zx:config obj_tf_end set value 1b
execute unless data storage zx:config obj_tf_nx run scoreboard objectives add zx.tf_nx dummy
data modify storage zx:config obj_tf_nx set value 1b
execute unless data storage zx:config obj_tf_nz run scoreboard objectives add zx.tf_nz dummy
data modify storage zx:config obj_tf_nz set value 1b
execute unless data storage zx:config obj_tf_seen run scoreboard objectives add zx.tf_seen dummy
data modify storage zx:config obj_tf_seen set value 1b

execute unless data storage zx:config obj_native_gen run scoreboard objectives add zx.native_gen dummy
data modify storage zx:config obj_native_gen set value 1b
