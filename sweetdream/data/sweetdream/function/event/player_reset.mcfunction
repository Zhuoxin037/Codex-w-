# ============================================================
# sweetdream:event/player_reset —— 应用层"已加成账本"逐项清空清单
# ------------------------------------------------------------
# 【谁抛它】
#   ① manacore:debug/reset_all(逐个在线玩家抛一次) —— 见 manacore:internal/debug/
#      reset_notify; 标签在 manacore:event/player_reset(sweetdream 侧往里追加本函数)。
#   ② manacore:internal/join/new —— 新玩家首次注册 / reset_all 之后**离线玩家**的
#      "第一次上线"; 标签在 manacore:event/player_first_join(见 event/player_first_join)。
# 【执行者】被重置 / 刚注册的那个玩家本人(@s 一定是玩家; 离线玩家两条都抛不到)。
# 【★★ 为什么需要它(2026-10-10 修 F16)★★】
#   manacore 只清它自己的 players 记录(属性/术阵/冷却)。而 sweetdream 的装备被动
#   是"账本式"加成的: 它们记着"我已经把 +N 加进面板了"(zx.am_mana / zx.em_mana /
#   zx.chg_atk / zx.chg_mm / zx.im_mk …), 下一轮只补 (想要 - 账本) 的差额。
#   底层属性被重置后, 面板回到默认, 但**账本还在** ⇒ 差额 = 0 ⇒ 穿着的装备
#   在本次重置后**不会把加成加回来**, 玩家看到"面板少了一截, 脱了再穿才好"。
# 【★★ N06(2026-10-11): 逐项清单, 不再无范围全清 ★★】
#   旧写法是一条 `scoreboard players reset @s`(**不带 objective**)= 抹掉该玩家在
#   **所有**计分项上的分数 —— 连**别的数据包**的分一起清。本包目录里就住着第二个
#   数据包 `sweetdream/data/naturewind`(nw.anim / nw.cast_t) ⇒ 旧写法会把它一起清掉。
#   现在改成**逐项清单**: 只 reset 本包涉及的 zx.* 计分项。
# 【清单从哪来 / 怎么维护】
#   命令段由 .workbuddy/_gen_reset_scores.py 从"源码里所有 scoreboard objectives
#   add zx.*"**自动生成**(单一真源 = 源码)。所以:
#     · 新增账本**不用手改本文件**, 但要 `python .workbuddy/_gen_reset_scores.py --write`
#       重跑一次生成器(否则 check.py 的 `resetset` 规则会报"清单缺项");
#     · `@@GEN-SCORES-BELOW@@` 与 `@@GEN-SCORES-ABOVE@@` 之间由脚本托管, 勿手改。
# 【离线玩家】`@s` 只可能是在线玩家, 所以 reset_all 那一次清不到离线的人; 他在下次
#   上线走 join/new 时会触发 player_first_join ⇒ 走同一份清单补清(这就是 N05 的修法)。
# ============================================================
# 【★ A04(2026-10-11 三审) -> Q04(2026-10-11 四审) 扩范围 ★】
#   熔星攻速 / 残念速度这类修饰符的"到期回收"全靠**计时分数驱动的每秒心跳**;
#   本函数把计时分数清掉之后就再也没人摘它们了 ⇒ 永久残留。必须先清理。
#   ★ 四审 Q04: 连**装备型**(eqp_* / upg_*)也一并摘 —— 因为下面的清账清单会把
#     装备账本(zx.power_hp / zx.set_hp / …)一起清零, 而"重置那一刻没穿装备"时
#     want=0 / 账本=0 ⇒ 差额 0 ⇒ 跳过 apply_* ⇒ 那份修饰符再也摘不掉。
#     详见 internal/attr/cleanup 头部(含"重置 = 恢复成新玩家"的语义论证)。
execute if entity @s[tag=zx.fb_cast] at @s run function sweetdream:equipment/sword/flame_brokenbody/visual/end
function sweetdream:internal/attr/cleanup
function sweetdream:equipment/axe/anchor/cancel
# @@GEN-SCORES-BELOW@@
scoreboard players reset @s zx.ab_age
scoreboard players reset @s zx.ab_t
scoreboard players reset @s zx.ac_d
scoreboard players reset @s zx.ac_lt
scoreboard players reset @s zx.acvf
scoreboard players reset @s zx.ad_bell
scoreboard players reset @s zx.ad_cast
scoreboard players reset @s zx.ad_idle
scoreboard players reset @s zx.ad_pulse
scoreboard players reset @s zx.ad_wait
scoreboard players reset @s zx.ag_end
scoreboard players reset @s zx.am_mana
scoreboard players reset @s zx.an_2nd
scoreboard players reset @s zx.an_boost
scoreboard players reset @s zx.an_lt
scoreboard players reset @s zx.an_ol
scoreboard players reset @s zx.an_pull
scoreboard players reset @s zx.ap_cur
scoreboard players reset @s zx.ap_done
scoreboard players reset @s zx.ap_n
scoreboard players reset @s zx.ap_on
scoreboard players reset @s zx.ap_p1
scoreboard players reset @s zx.ap_p2
scoreboard players reset @s zx.ap_p3
scoreboard players reset @s zx.ap_pre
scoreboard players reset @s zx.ap_t3
scoreboard players reset @s zx.ap_t4
scoreboard players reset @s zx.apv
scoreboard players reset @s zx.apvc
scoreboard players reset @s zx.apvi
scoreboard players reset @s zx.arc_dt
scoreboard players reset @s zx.arc_ol
scoreboard players reset @s zx.arc_wt
scoreboard players reset @s zx.as_d
scoreboard players reset @s zx.as_db
scoreboard players reset @s zx.as_lt
scoreboard players reset @s zx.as_x2
scoreboard players reset @s zx.atk_gt
scoreboard players reset @s zx.atk_lt
scoreboard players reset @s zx.atk_ok
scoreboard players reset @s zx.av_dim
scoreboard players reset @s zx.av_hand
scoreboard players reset @s zx.av_life
scoreboard players reset @s zx.av_phase
scoreboard players reset @s zx.av_slot
scoreboard players reset @s zx.av_t
scoreboard players reset @s zx.ball_dist
scoreboard players reset @s zx.bd_cd
scoreboard players reset @s zx.bd_ft
scoreboard players reset @s zx.bd_lt
scoreboard players reset @s zx.bd_mode
scoreboard players reset @s zx.bd_on
scoreboard players reset @s zx.bd_paid
scoreboard players reset @s zx.bd_song
scoreboard players reset @s zx.bd_tune
scoreboard players reset @s zx.bg_n
scoreboard players reset @s zx.bg_ol
scoreboard players reset @s zx.bg_t
scoreboard players reset @s zx.bl_atk
scoreboard players reset @s zx.bl_gm
scoreboard players reset @s zx.bl_gu
scoreboard players reset @s zx.bl_lt
scoreboard players reset @s zx.bl_mana
scoreboard players reset @s zx.bl_regen
scoreboard players reset @s zx.bl_rv
scoreboard players reset @s zx.bl_ta
scoreboard players reset @s zx.bl_te
scoreboard players reset @s zx.bs_n
scoreboard players reset @s zx.bs_paid
scoreboard players reset @s zx.bs_ready
scoreboard players reset @s zx.cc_fx
scoreboard players reset @s zx.cc_ice
scoreboard players reset @s zx.cc_vis
scoreboard players reset @s zx.cdr
scoreboard players reset @s zx.ch_cd
scoreboard players reset @s zx.ch_end
scoreboard players reset @s zx.chg_atk
scoreboard players reset @s zx.chg_mm
scoreboard players reset @s zx.chg_mode
scoreboard players reset @s zx.chg_ol
scoreboard players reset @s zx.chg_on
scoreboard players reset @s zx.cr_b
scoreboard players reset @s zx.cr_lt
scoreboard players reset @s zx.cr_t
scoreboard players reset @s zx.ct_ft
scoreboard players reset @s zx.ct_paid
scoreboard players reset @s zx.ct_seek
scoreboard players reset @s zx.dash
scoreboard players reset @s zx.dbg_cd
scoreboard players reset @s zx.dbg_diff
scoreboard players reset @s zx.dbg_fadd
scoreboard players reset @s zx.dbg_fdel
scoreboard players reset @s zx.dbg_give
scoreboard players reset @s zx.dbg_mana
scoreboard players reset @s zx.dbg_menu
scoreboard players reset @s zx.dbg_raw
scoreboard players reset @s zx.dbg_stats
scoreboard players reset @s zx.dbg_worn
scoreboard players reset @s zx.dc_last
scoreboard players reset @s zx.dd_app
scoreboard players reset @s zx.dd_know
scoreboard players reset @s zx.dd_mana
scoreboard players reset @s zx.dd_n
scoreboard players reset @s zx.dd_set
scoreboard players reset @s zx.dd_t1
scoreboard players reset @s zx.dd_t2
scoreboard players reset @s zx.dd_temp
scoreboard players reset @s zx.de_cast
scoreboard players reset @s zx.de_t
scoreboard players reset @s zx.de_wave
scoreboard players reset @s zx.deaths
scoreboard players reset @s zx.dg_buf
scoreboard players reset @s zx.dg_on
scoreboard players reset @s zx.dio_emp
scoreboard players reset @s zx.dio_ih
scoreboard players reset @s zx.dio_mana
scoreboard players reset @s zx.dio_ramt
scoreboard players reset @s zx.dio_regen
scoreboard players reset @s zx.dio_wine
scoreboard players reset @s zx.dr_life
scoreboard players reset @s zx.dt_paid
scoreboard players reset @s zx.el_attack
scoreboard players reset @s zx.el_cd
scoreboard players reset @s zx.el_clock
scoreboard players reset @s zx.el_dim
scoreboard players reset @s zx.el_last
scoreboard players reset @s zx.el_mana
scoreboard players reset @s zx.el_state
scoreboard players reset @s zx.el_time
scoreboard players reset @s zx.em_conv
scoreboard players reset @s zx.em_gate
scoreboard players reset @s zx.em_mana
scoreboard players reset @s zx.em_mana50
scoreboard players reset @s zx.em_scan
scoreboard players reset @s zx.em_seen
scoreboard players reset @s zx.et_mana
scoreboard players reset @s zx.fb_dim
scoreboard players reset @s zx.fb_frame
scoreboard players reset @s zx.fb_fx_t
scoreboard players reset @s zx.fb_hand
scoreboard players reset @s zx.fb_lava
scoreboard players reset @s zx.fb_mode
scoreboard players reset @s zx.fb_ol
scoreboard players reset @s zx.fb_refresh
scoreboard players reset @s zx.fb_slot
scoreboard players reset @s zx.fb_until
scoreboard players reset @s zx.fc_ash
scoreboard players reset @s zx.fc_atk
scoreboard players reset @s zx.fc_hold
scoreboard players reset @s zx.fc_hp
scoreboard players reset @s zx.fc_mana
scoreboard players reset @s zx.fc_t
scoreboard players reset @s zx.fcv_rec
scoreboard players reset @s zx.fcv_st
scoreboard players reset @s zx.fcv_t
scoreboard players reset @s zx.fcv_t4
scoreboard players reset @s zx.fcv_u0
scoreboard players reset @s zx.fcv_u1
scoreboard players reset @s zx.fcv_u2
scoreboard players reset @s zx.fcv_u3
scoreboard players reset @s zx.fd_t
scoreboard players reset @s zx.fi_ft
scoreboard players reset @s zx.floor_mana
scoreboard players reset @s zx.fm_cd
scoreboard players reset @s zx.fm_t
scoreboard players reset @s zx.fr_auto
scoreboard players reset @s zx.fr_light
scoreboard players reset @s zx.fr_ref
scoreboard players reset @s zx.fr_t
scoreboard players reset @s zx.fz_end
scoreboard players reset @s zx.gd_mana
scoreboard players reset @s zx.gd_n
scoreboard players reset @s zx.gp_t
scoreboard players reset @s zx.gw_anim
scoreboard players reset @s zx.gw_end
scoreboard players reset @s zx.hd_ol
scoreboard players reset @s zx.hp_c
scoreboard players reset @s zx.hp_show
scoreboard players reset @s zx.hush
scoreboard players reset @s zx.hush_bk
scoreboard players reset @s zx.icon_fade
scoreboard players reset @s zx.icon_id
scoreboard players reset @s zx.icon_mask
scoreboard players reset @s zx.icon_ttl
scoreboard players reset @s zx.im_buff
scoreboard players reset @s zx.im_buff_mk
scoreboard players reset @s zx.im_ignite
scoreboard players reset @s zx.im_mk
scoreboard players reset @s zx.im_set20
scoreboard players reset @s zx.ir_mana
scoreboard players reset @s zx.ld_dream
scoreboard players reset @s zx.ld_end
scoreboard players reset @s zx.ld_u0
scoreboard players reset @s zx.ld_u1
scoreboard players reset @s zx.ld_u2
scoreboard players reset @s zx.ld_u3
scoreboard players reset @s zx.ld_x
scoreboard players reset @s zx.lk
scoreboard players reset @s zx.lk_mode
scoreboard players reset @s zx.ls_anim
scoreboard players reset @s zx.ls_buf
scoreboard players reset @s zx.ls_end
scoreboard players reset @s zx.ls_mana
scoreboard players reset @s zx.ls_t
scoreboard players reset @s zx.lt_end
scoreboard players reset @s zx.lt_mana
scoreboard players reset @s zx.lt_n
scoreboard players reset @s zx.lt_need
scoreboard players reset @s zx.lt_reset
scoreboard players reset @s zx.ly_aura
scoreboard players reset @s zx.ly_timer
scoreboard players reset @s zx.ly_times
scoreboard players reset @s zx.meta
scoreboard players reset @s zx.mm_add
scoreboard players reset @s zx.mm_add_lt
scoreboard players reset @s zx.mp_mana
scoreboard players reset @s zx.mq_base
scoreboard players reset @s zx.mq_dir
scoreboard players reset @s zx.mq_fa
scoreboard players reset @s zx.mq_ft
scoreboard players reset @s zx.mq_h5
scoreboard players reset @s zx.mq_hl
scoreboard players reset @s zx.mq_jb
scoreboard players reset @s zx.mq_ju
scoreboard players reset @s zx.mq_ol
scoreboard players reset @s zx.mq_sa
scoreboard players reset @s zx.mq_soul
scoreboard players reset @s zx.mq_wait
scoreboard players reset @s zx.mq_win
scoreboard players reset @s zx.mr_a0
scoreboard players reset @s zx.mr_a1
scoreboard players reset @s zx.mr_a2
scoreboard players reset @s zx.mr_a3
scoreboard players reset @s zx.mr_a4
scoreboard players reset @s zx.mr_a5
scoreboard players reset @s zx.mr_atk
scoreboard players reset @s zx.mr_atk1
scoreboard players reset @s zx.mr_atk2
scoreboard players reset @s zx.mr_b0
scoreboard players reset @s zx.mr_b1
scoreboard players reset @s zx.mr_b2
scoreboard players reset @s zx.mr_b3
scoreboard players reset @s zx.mr_b4
scoreboard players reset @s zx.mr_b5
scoreboard players reset @s zx.mr_b6
scoreboard players reset @s zx.mr_b7
scoreboard players reset @s zx.mr_b8
scoreboard players reset @s zx.mr_mana
scoreboard players reset @s zx.msp_c
scoreboard players reset @s zx.mt_lt
scoreboard players reset @s zx.mt_on
scoreboard players reset @s zx.mt_rk
scoreboard players reset @s zx.noai_bak
scoreboard players reset @s zx.ol_c
scoreboard players reset @s zx.ol_d
scoreboard players reset @s zx.ol_m
scoreboard players reset @s zx.pal_blu
scoreboard players reset @s zx.pal_c1
scoreboard players reset @s zx.pal_c2
scoreboard players reset @s zx.pal_hit
scoreboard players reset @s zx.pal_id
scoreboard players reset @s zx.pal_mul
scoreboard players reset @s zx.pal_n
scoreboard players reset @s zx.pal_rng
scoreboard players reset @s zx.pal_thr
scoreboard players reset @s zx.pl_ct
scoreboard players reset @s zx.pl_ol
scoreboard players reset @s zx.pl_t
scoreboard players reset @s zx.power_hp
scoreboard players reset @s zx.pump_mana
scoreboard players reset @s zx.pv_age
scoreboard players reset @s zx.pv_c1
scoreboard players reset @s zx.pv_c2
scoreboard players reset @s zx.pv_f
scoreboard players reset @s zx.pv_idle
scoreboard players reset @s zx.pv_spin
scoreboard players reset @s zx.pv_wait
scoreboard players reset @s zx.py_d
scoreboard players reset @s zx.py_lt
scoreboard players reset @s zx.py_rdy
scoreboard players reset @s zx.py_x
scoreboard players reset @s zx.rb_blade
scoreboard players reset @s zx.rb_born
scoreboard players reset @s zx.rb_end
scoreboard players reset @s zx.rb_lt
scoreboard players reset @s zx.rb_rep
scoreboard players reset @s zx.rb_t
scoreboard players reset @s zx.rb_u0
scoreboard players reset @s zx.rb_u1
scoreboard players reset @s zx.rb_u2
scoreboard players reset @s zx.rb_u3
scoreboard players reset @s zx.regen_extra
scoreboard players reset @s zx.regen_last
scoreboard players reset @s zx.ret_pend
scoreboard players reset @s zx.ret_slot
scoreboard players reset @s zx.ret_wait
scoreboard players reset @s zx.rl_ol
scoreboard players reset @s zx.rl_rain
scoreboard players reset @s zx.rl_rep
scoreboard players reset @s zx.rl_t
scoreboard players reset @s zx.rm_lt
scoreboard players reset @s zx.rm_on
scoreboard players reset @s zx.rm_t
scoreboard players reset @s zx.rs_mana
scoreboard players reset @s zx.sb_end
scoreboard players reset @s zx.sb_ol
scoreboard players reset @s zx.sd_id
scoreboard players reset @s zx.sd_leave
scoreboard players reset @s zx.sd_lock
scoreboard players reset @s zx.sd_ol
scoreboard players reset @s zx.sd_t
scoreboard players reset @s zx.se_cry
scoreboard players reset @s zx.se_mana
scoreboard players reset @s zx.se_regen
scoreboard players reset @s zx.se_t
scoreboard players reset @s zx.sea_anim
scoreboard players reset @s zx.sea_cap
scoreboard players reset @s zx.sea_end
scoreboard players reset @s zx.set_hp
scoreboard players reset @s zx.set_mana
scoreboard players reset @s zx.sh_t
scoreboard players reset @s zx.sl_a
scoreboard players reset @s zx.sl_m
scoreboard players reset @s zx.sl_mask
scoreboard players reset @s zx.sl_ok
scoreboard players reset @s zx.sl_p
scoreboard players reset @s zx.sl_t
scoreboard players reset @s zx.sl_u0
scoreboard players reset @s zx.sl_u1
scoreboard players reset @s zx.sl_u2
scoreboard players reset @s zx.sl_u3
scoreboard players reset @s zx.sl_vt
scoreboard players reset @s zx.slva
scoreboard players reset @s zx.slve
scoreboard players reset @s zx.slvf
scoreboard players reset @s zx.slvi
scoreboard players reset @s zx.slvm
scoreboard players reset @s zx.sr_ft
scoreboard players reset @s zx.sr_lt
scoreboard players reset @s zx.sr_next
scoreboard players reset @s zx.sr_on
scoreboard players reset @s zx.sr_wt
scoreboard players reset @s zx.srm_b
scoreboard players reset @s zx.srm_d
scoreboard players reset @s zx.srm_end
scoreboard players reset @s zx.srm_f
scoreboard players reset @s zx.srm_last
scoreboard players reset @s zx.srm_p
scoreboard players reset @s zx.srv_frame
scoreboard players reset @s zx.srv_i
scoreboard players reset @s zx.srv_pulse
scoreboard players reset @s zx.srv_start
scoreboard players reset @s zx.ss_armor
scoreboard players reset @s zx.ss_hp
scoreboard players reset @s zx.ss_mana
scoreboard players reset @s zx.ss_ta
scoreboard players reset @s zx.ss_te
scoreboard players reset @s zx.staff_gcd
scoreboard players reset @s zx.stg
scoreboard players reset @s zx.stg_t
scoreboard players reset @s zx.sv_launch
scoreboard players reset @s zx.sv_rise
scoreboard players reset @s zx.sv_step
scoreboard players reset @s zx.sw_cd
scoreboard players reset @s zx.sw_last
scoreboard players reset @s zx.sw_mana
scoreboard players reset @s zx.sw_st
scoreboard players reset @s zx.tc_ang
scoreboard players reset @s zx.tc_bc
scoreboard players reset @s zx.tc_bs
scoreboard players reset @s zx.tc_end
scoreboard players reset @s zx.tc_ft
scoreboard players reset @s zx.tc_lt
scoreboard players reset @s zx.tc_n
scoreboard players reset @s zx.tc_on
scoreboard players reset @s zx.td_lt
scoreboard players reset @s zx.td_on
scoreboard players reset @s zx.th_due
scoreboard players reset @s zx.tr_due
scoreboard players reset @s zx.tri_form
scoreboard players reset @s zx.tri_hit
scoreboard players reset @s zx.tri_next
scoreboard players reset @s zx.tri_nores
scoreboard players reset @s zx.tri_strong
scoreboard players reset @s zx.tri_u0
scoreboard players reset @s zx.tri_u1
scoreboard players reset @s zx.tri_u2
scoreboard players reset @s zx.tri_u3
scoreboard players reset @s zx.ts_end
scoreboard players reset @s zx.tt.dream
scoreboard players reset @s zx.tt.liuhuo
scoreboard players reset @s zx.tt.shixin
scoreboard players reset @s zx.tt.yehuo
scoreboard players reset @s zx.tt.yuanhai
scoreboard players reset @s zx.tw_t
scoreboard players reset @s zx.up_armor
scoreboard players reset @s zx.up_at
scoreboard players reset @s zx.up_atks
scoreboard players reset @s zx.up_hp
scoreboard players reset @s zx.up_lt
scoreboard players reset @s zx.up_mana
scoreboard players reset @s zx.vd_ft
scoreboard players reset @s zx.vd_lt
scoreboard players reset @s zx.vfx_t
scoreboard players reset @s zx.wg_aura
scoreboard players reset @s zx.wg_burst
scoreboard players reset @s zx.wg_mana
scoreboard players reset @s zx.wg_sound

# @@GEN-SCORES-ABOVE@@
# ---- ★ Q02(2026-10-11 四审): 清完账, 按"返还队列"重建镜像 ★ ----
#   上面那份逐项清单把 zx.ret_pend / zx.ret_slot / zx.ret_wait 一起 reset 了 ——
#   但待归还的**真相**不在计分板上, 而在存储里的队列 zx:ret p."<uuid>".q(A02 起)。
#   只清镜像、留着队列 ⇒ recover 的选择器 `@a[scores={zx.ret_pend=1..}]` 一个都选不到
#   ⇒ 那笔返还彻底失去驱动, 物品卡死在队列里。
#   ⇒ 这里按队列把镜像**重建**一遍(幂等; 双向: q 空则复位成干净态)。语义 =
#     **重置不打断返还事务**: 重置只清账本/计时, 不动"已经欠玩家的实物"。
#   ★ 必须排在清单**之后** —— 放前面的话刚建的镜像会被清单立刻 reset 掉。
#   ★ 本行与上面的清单之间用尾标记 `@@GEN-SCORES-ABOVE@@` 隔开:
#     _gen_reset_scores.py 只托管两标记**之间**的清单, 尾标记之下是手写区, 不会被覆盖。
function sweetdream:internal/itembackup/resync_go
