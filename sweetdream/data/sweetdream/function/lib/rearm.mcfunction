# ============================================================
# sweetdream:lib/rearm —— 把"自撤销型"进度整体归零(安全网)
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick 的**第一行**(即每游戏刻一次)。
#   ★ 不要改挂 lib/second(每秒) ★ —— 那次真实事故恰恰就发生在"每秒"这一拍
#     没轮到的 tick 上; 每刻跑才能真正兜住。多出来的开销可忽略(见下)。
#
# 【为什么要它】包里的技术类进度(打到/打死/使用物品/射箭/tick)都是**一次性**的:
#   奖励函数第一行 `advancement revoke @s only <自己>` 撤销自己, 下次才能再触发。
#   但这条链有个致命弱点 —— **奖励函数没跑起来, 撤销就不会发生**:
#     · 该刻命令预算打满(日志: "Command execution stopped due to limit
#       (executed 65536 commands)") → 奖励函数被整段跳过;
#     · 或者函数在第 N 行 return 了, 而 revoke 写在第 N+1 行(顺序错)。
#   进度一旦"卡住已授予", 那个触发条件**永远**不会再授予 → 对应效果永久失效,
#   而且一个字都不报(真实事故: 2026-10-04 04:08:55 一次命令爆量, 把
#   upgrade/attack 卡住 → 魔力增殖 α/β/Ω 的攻击回魔从此全死, 玩家以为"升级失效了")。
#
# 【怎么做】每刻对所有玩家撤销一遍这 32 条。
#   · 正常情况: 进度早被奖励函数自己撤掉了, 这里全是**空操作**(撤销一条未授予的
#     进度什么都不发生), 所以本文件在健康状态下不产生任何行为变化;
#   · 只有"奖励函数被跳过"这个死角里, 它才是唯一的救兵 —— 下一 tick 事件
#     就能重新授予, 效果恢复(最多晚 1 tick, 玩家察觉不到)。
#   · 成本: 32 条 revoke / tick, 相对预算 65536 可忽略。
#
# 【★ 新增自撤销型进度时, 必须同步加到这里 ★】
#   判据 = "奖励函数的第一个非注释行是 advancement revoke @s only 自己"
#   (也就是 check.py 规则 5 认的那一类)。忘了加 → 那个进度迟早会卡死,
#   而且是静默的。check.py 规则 27 专门盯这件事 + 盯 revoke 有没有排在 return 后面。
# ============================================================

advancement revoke @a only sweetdream:equipment/armor/dionysus_helmet
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill_mark
advancement revoke @a only sweetdream:equipment/armor/immolate_hurt
advancement revoke @a only sweetdream:equipment/armor/iridescent_hurt
advancement revoke @a only sweetdream:equipment/armor/mirage_attack
advancement revoke @a only sweetdream:equipment/armor/mirage_hit_dream
advancement revoke @a only sweetdream:equipment/armor/mirage_hurt
advancement revoke @a only sweetdream:equipment/armor/spine_symbiote_kill
advancement revoke @a only sweetdream:equipment/armor/stellar_elegy
advancement revoke @a only sweetdream:equipment/axe/charge
advancement revoke @a only sweetdream:equipment/axe/charge_hit
advancement revoke @a only sweetdream:equipment/bow/cold_crow
advancement revoke @a only sweetdream:equipment/staff/wind_ontheground
advancement revoke @a only sweetdream:equipment/sword/deepsea_echo
advancement revoke @a only sweetdream:equipment/sword/flame_brokenbody
advancement revoke @a only sweetdream:equipment/sword/hengdao
advancement revoke @a only sweetdream:equipment/sword/liaoyuan
advancement revoke @a only sweetdream:equipment/sword/liuguang
advancement revoke @a only sweetdream:equipment/sword/sickle_dreams
advancement revoke @a only sweetdream:equipment/tool/look
advancement revoke @a only sweetdream:itembackup/consume
advancement revoke @a only sweetdream:itembackup/mainhand
advancement revoke @a only sweetdream:itembackup/summon
advancement revoke @a only sweetdream:overlimit/liuguang
advancement revoke @a only sweetdream:upgrade/attack
advancement revoke @a only sweetdream:upgrade/mana_gain_a
advancement revoke @a only sweetdream:upgrade/mana_gain_b
advancement revoke @a only sweetdream:upgrade/mana_gain_o
advancement revoke @a only sweetdream:upgrade/mana_up_a
advancement revoke @a only sweetdream:upgrade/mana_up_b
advancement revoke @a only sweetdream:upgrade/mana_up_o
