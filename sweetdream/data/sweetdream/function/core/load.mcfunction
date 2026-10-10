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
#   zx.rb_rep = 主动技能"还要重复打几次"(0..3, 起手 = 层数)
#   zx.rb_t   = 距离下一次打击的剩余刻数(起手 7 = 0.35 秒; 0/无分数 = 不在重复中)
#     ★ 这两个是"每 0.35 秒重复一次"的计时器, 由 core/tick 驱动 rebound/tick_step。
execute unless data storage zx:config obj_rb_rep run scoreboard objectives add zx.rb_rep dummy
execute unless data storage zx:config obj_rb_rep run data modify storage zx:config obj_rb_rep set value 1b
execute unless data storage zx:config obj_rb_t run scoreboard objectives add zx.rb_t dummy
execute unless data storage zx:config obj_rb_t run data modify storage zx:config obj_rb_t set value 1b

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
#   dd_t1 击杀基础(+200) / dd_t2 击杀带标签额外(+100) / dd_app 已经加了多少(差值账本) /
#   dd_know 用来判断"两条进度是不是同一次击杀"
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
execute unless data storage zx:config obj_em_seen run scoreboard objectives add zx.em_seen dummy
execute unless data storage zx:config obj_em_seen run data modify storage zx:config obj_em_seen set value 1b
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
execute unless data storage zx:config obj_mr_atk1 run scoreboard objectives add zx.mr_atk1 dummy
execute unless data storage zx:config obj_mr_atk1 run data modify storage zx:config obj_mr_atk1 set value 1b
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
#   zx.pl_ct = 超限版 0.5 秒闸的计数器(10 刻 = 一次结算)
execute unless data storage zx:config obj_pl_ol run scoreboard objectives add zx.pl_ol dummy
execute unless data storage zx:config obj_pl_ol run data modify storage zx:config obj_pl_ol set value 1b
execute unless data storage zx:config obj_pl_ct run scoreboard objectives add zx.pl_ct dummy
execute unless data storage zx:config obj_pl_ct run data modify storage zx:config obj_pl_ct set value 1b
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
execute unless data storage zx:config obj_ap_cur run scoreboard objectives add zx.ap_cur dummy
execute unless data storage zx:config obj_ap_cur run data modify storage zx:config obj_ap_cur set value 1b
# 枯枝园(withered_garden):
#   zx.gd_mana = 魔力上限账本(已加了多少, 穿 +300 / 脱 -300)
#   zx.gd_n    = 12 格内朽木数(抗性提升层数, 上限 3)
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

# ---- 回手(消耗型武器)的持久记账(2026-10-10, 修 R01 / R06) ----
#   ★ 为什么用【计分项】而不是实体 tag:
#       tag 随实体消失 —— 玩家在"消耗 -> 回手"这 1 tick 之间掉线/死亡重生,
#       tag 就没了, 每秒那条兜底(internal/itembackup/recover)会判错手,
#       于是把备份那把刀写进错误的槽位。计分项是挂在玩家名下的持久数据,
#       重连/重生都还在, 兜底才能做出正确判断。
#   zx.ret_slot = **这一下是从哪一格消耗掉的**, 取值:
#        0..8  = 主手, 值为消耗那一刻的快捷栏下标(SelectedItemSlot)
#        -1    = 这一下是副手放的(副手没有"选中格"概念, 写回 weapon.offhand)
#        -2    = 没有待归还(回手成功或倒计时放弃后复位)
#   ★ 老版本没有它, 回手写 weapon.mainhand(= **当前选中**的快捷栏格) ——
#     消耗后 1 tick 内滚轮切一下格子, 武器就会被塞进新选中的那一格,
#     **把那一格原有的物品直接顶掉**(item replace 不掉落, 凭空消失)。见 R01。
execute unless data storage zx:config obj_ret_slot run scoreboard objectives add zx.ret_slot dummy
execute unless data storage zx:config obj_ret_slot run data modify storage zx:config obj_ret_slot set value 1b

#   zx.ret_pend = 待归还**倒计时(单位: 秒)**。
#        0      = 没有待归还
#        1..20  = 还有待归还, 每秒由 recover 重试一次, 归零就放弃
#   ★ 为什么要有倒计时而不是一直重试: 万一某个极端时序让目标格长期占用,
#     不加倒计时的话这个标记会永久挂着, 之后每秒都白扫一遍这个玩家。
#     20 秒足够覆盖"掉线重连 / 死亡重生 / 临时挪走占位的物品"这几种情况。
execute unless data storage zx:config obj_ret_pend run scoreboard objectives add zx.ret_pend dummy
execute unless data storage zx:config obj_ret_pend run data modify storage zx:config obj_ret_pend set value 1b
