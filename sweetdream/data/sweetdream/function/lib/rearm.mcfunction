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
# 【怎么做】每刻对所有玩家撤销一遍这 79 条。
#   · 正常情况: 进度早被奖励函数自己撤掉了, 这里全是**空操作**(撤销一条未授予的
#     进度什么都不发生), 所以本文件在健康状态下不产生任何行为变化;
#   · 只有"奖励函数被跳过"这个死角里, 它才是唯一的救兵 —— 下一 tick 事件
#     就能重新授予, 效果恢复(最多晚 1 tick, 玩家察觉不到)。
#   · 成本: 79 条 revoke / tick, 相对预算 65536 可忽略。
#
# 【★ 新增自撤销型进度时, 必须同步加到这里 ★】
#   判据 = "奖励函数的第一个非注释行是 advancement revoke @s only 自己"
#   (也就是 check.py 规则 5 认的那一类)。忘了加 → 那个进度迟早会卡死,
#   而且是静默的。check.py 规则 27 专门盯这件事 + 盯 revoke 有没有排在 return 后面。
# ============================================================

advancement revoke @a only sweetdream:equipment/armor/brain_leech_attack
advancement revoke @a only sweetdream:equipment/armor/dionysus_helmet
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill_mark
advancement revoke @a only sweetdream:equipment/armor/furnace_core_hit
advancement revoke @a only sweetdream:equipment/armor/immolate_hurt
advancement revoke @a only sweetdream:equipment/armor/iridescent_hurt
advancement revoke @a only sweetdream:equipment/armor/mirage_attack
advancement revoke @a only sweetdream:equipment/armor/mirage_hit_dream
advancement revoke @a only sweetdream:equipment/armor/mirage_hurt
advancement revoke @a only sweetdream:equipment/armor/spine_symbiote_kill
advancement revoke @a only sweetdream:equipment/armor/stellar_elegy
advancement revoke @a only sweetdream:equipment/armor/styx_walk_hit
advancement revoke @a only sweetdream:equipment/armor/lethe_shore_hit
advancement revoke @a only sweetdream:equipment/axe/agony
advancement revoke @a only sweetdream:equipment/axe/charge
advancement revoke @a only sweetdream:equipment/axe/charge_hit
advancement revoke @a only sweetdream:equipment/axe/angel_core
advancement revoke @a only sweetdream:equipment/axe/angel_core_hit
advancement revoke @a only sweetdream:equipment/axe/anion
advancement revoke @a only sweetdream:equipment/axe/chenyuan
advancement revoke @a only sweetdream:equipment/axe/chenyuan_hit
advancement revoke @a only sweetdream:equipment/axe/meteor
advancement revoke @a only sweetdream:equipment/axe/meteor_hit
advancement revoke @a only sweetdream:equipment/axe/skyvault
advancement revoke @a only sweetdream:equipment/axe/skyvault_hit
advancement revoke @a only sweetdream:equipment/bow/cold_crow
advancement revoke @a only sweetdream:equipment/bow/bone_erode
advancement revoke @a only sweetdream:equipment/bow/sculk_echo
advancement revoke @a only sweetdream:equipment/bow/lucid_dream
advancement revoke @a only sweetdream:equipment/bow/rainbow
advancement revoke @a only sweetdream:equipment/staff/apocalypse
advancement revoke @a only sweetdream:equipment/staff/delusion
advancement revoke @a only sweetdream:equipment/staff/fallen_dream
advancement revoke @a only sweetdream:equipment/staff/final_revelation
advancement revoke @a only sweetdream:equipment/staff/polarized_light
advancement revoke @a only sweetdream:equipment/staff/wind_ontheground
# ---- 批3 · 法杖(2026-10-07) ----
advancement revoke @a only sweetdream:equipment/staff/chime
advancement revoke @a only sweetdream:equipment/staff/palette
advancement revoke @a only sweetdream:equipment/staff/begonia
advancement revoke @a only sweetdream:equipment/staff/gu_poison
advancement revoke @a only sweetdream:equipment/staff/twilight
advancement revoke @a only sweetdream:equipment/staff/sail
# ---- 批3 · 盔甲(2026-10-07) ----
advancement revoke @a only sweetdream:equipment/armor/flesh_mill_hurt
advancement revoke @a only sweetdream:equipment/armor/blaze_armor_hurt
advancement revoke @a only sweetdream:equipment/sword/deepsea_echo
advancement revoke @a only sweetdream:equipment/sword/everfrost
advancement revoke @a only sweetdream:equipment/sword/flame_brokenbody
advancement revoke @a only sweetdream:equipment/sword/hengdao
advancement revoke @a only sweetdream:equipment/sword/hush
advancement revoke @a only sweetdream:equipment/sword/rebound
advancement revoke @a only sweetdream:equipment/sword/rebound_hit
advancement revoke @a only sweetdream:equipment/sword/rogue_star
advancement revoke @a only sweetdream:equipment/sword/liaoyuan
advancement revoke @a only sweetdream:equipment/sword/liuguang
advancement revoke @a only sweetdream:equipment/sword/sickle_dreams
advancement revoke @a only sweetdream:equipment/sword/aurora_dream
advancement revoke @a only sweetdream:equipment/sword/myriad
advancement revoke @a only sweetdream:equipment/sword/myriad_hit
advancement revoke @a only sweetdream:equipment/sword/qiansan
advancement revoke @a only sweetdream:equipment/sword/remelt
advancement revoke @a only sweetdream:equipment/sword/remelt_hit
advancement revoke @a only sweetdream:equipment/sword/shadow_blade
advancement revoke @a only sweetdream:equipment/sword/shadow_blade_kill
advancement revoke @a only sweetdream:equipment/sword/tinder_hit
advancement revoke @a only sweetdream:equipment/sword/verdict
advancement revoke @a only sweetdream:equipment/sword/verdict_hit
# ---- 批2 · 斧(2026-10-07) ----
#   ★ 判据 = 奖励函数第一个非注释行是 `advancement revoke @s only 自己`。
#   崩裂 / 释梦 / 饮鸩 / 葬火 / 歌谣 / 威霆 / 红莲 / 苍蓝星 —— 共 13 条。
advancement revoke @a only sweetdream:equipment/axe/fissure
advancement revoke @a only sweetdream:equipment/axe/dream_reader
advancement revoke @a only sweetdream:equipment/axe/dream_reader_hit
advancement revoke @a only sweetdream:equipment/axe/draught
advancement revoke @a only sweetdream:equipment/axe/pyre
advancement revoke @a only sweetdream:equipment/axe/pyre_hit
advancement revoke @a only sweetdream:equipment/axe/ballad
advancement revoke @a only sweetdream:equipment/axe/ballad_hit
advancement revoke @a only sweetdream:equipment/axe/ballad_kill
advancement revoke @a only sweetdream:equipment/axe/thunderclap_hit
advancement revoke @a only sweetdream:equipment/axe/red_lotus
advancement revoke @a only sweetdream:equipment/axe/azure_star
advancement revoke @a only sweetdream:equipment/axe/azure_star_hit
advancement revoke @a only sweetdream:equipment/tool/blaze_plume_hit
advancement revoke @a only sweetdream:equipment/tool/look
advancement revoke @a only sweetdream:itembackup/consume
advancement revoke @a only sweetdream:itembackup/mainhand
advancement revoke @a only sweetdream:itembackup/summon
advancement revoke @a only sweetdream:overlimit/brain_leech
advancement revoke @a only sweetdream:overlimit/liuguang
advancement revoke @a only sweetdream:overlimit/spine_symbiote
advancement revoke @a only sweetdream:upgrade/attack
advancement revoke @a only sweetdream:upgrade/coolant_a
advancement revoke @a only sweetdream:upgrade/coolant_b
advancement revoke @a only sweetdream:upgrade/coolant_o
advancement revoke @a only sweetdream:upgrade/harden_a
advancement revoke @a only sweetdream:upgrade/harden_b
advancement revoke @a only sweetdream:upgrade/harden_o
advancement revoke @a only sweetdream:upgrade/mana_gain_a
advancement revoke @a only sweetdream:upgrade/mana_gain_b
advancement revoke @a only sweetdream:upgrade/mana_gain_o
advancement revoke @a only sweetdream:upgrade/mana_surge_a
advancement revoke @a only sweetdream:upgrade/mana_surge_b
advancement revoke @a only sweetdream:upgrade/mana_surge_o
advancement revoke @a only sweetdream:upgrade/mana_up_a
advancement revoke @a only sweetdream:upgrade/mana_up_b
advancement revoke @a only sweetdream:upgrade/mana_up_o
advancement revoke @a only sweetdream:upgrade/vision_a
advancement revoke @a only sweetdream:upgrade/vision_b
advancement revoke @a only sweetdream:upgrade/vision_o
advancement revoke @a only sweetdream:upgrade/uncolor
advancement revoke @a only sweetdream:upgrade/torch
advancement revoke @a only sweetdream:upgrade/boil
advancement revoke @a only sweetdream:upgrade/night_vision
advancement revoke @a only sweetdream:upgrade/life_up_a
advancement revoke @a only sweetdream:upgrade/life_up_b
advancement revoke @a only sweetdream:upgrade/life_up_o
advancement revoke @a only sweetdream:overlimit/stellar_elegy
advancement revoke @a only sweetdream:overlimit/dusk_dawn
advancement revoke @a only sweetdream:overlimit/myriad
