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
# 【怎么做】每刻对所有玩家撤销一遍这 178 条。
#   · 正常情况: 进度早被奖励函数自己撤掉了, 这里全是**空操作**(撤销一条未授予的
#     进度什么都不发生), 所以本文件在健康状态下不产生任何行为变化;
#   · 只有"奖励函数被跳过"这个死角里, 它才是唯一的救兵 —— 下一 tick 事件
#     就能重新授予, 效果恢复(最多晚 1 tick, 玩家察觉不到)。
#   · 成本: 178 条 revoke / tick, 相对预算 65536 可忽略。
#
# 【★ 新增自撤销型进度时, 必须同步加到这里 ★】
#   判据 = "奖励函数的第一个非注释行是 advancement revoke @s only 自己"
#   (也就是 check.py 规则 5 认的那一类)。忘了加 → 那个进度迟早会卡死,
#   而且是静默的。check.py 规则 27 专门盯这件事 + 盯 revoke 有没有排在 return 后面。
#
# 【★ 审查报告 O01 的核对结论(2026-10-10): 一条都不能删 ★】
#   报告说"很多奖励函数本身已经先撤销自己的进度, 这类每 tick 兜底冗余" ——
#   但按本包契约, **全部 178 条**的奖励函数都自撤销(规则 5 强制), 所以"自撤销"
#   不构成删减依据: 这个文件的职责恰恰是兜住"自撤销没跑成"的那次(预算爆量 /
#   排序错), 删了 = 复现 2026-10-04 的事故类别。
#   · 真能省的只有"频率/位置"(每 2 tick 交替两半 / 改每秒), 但那是在拿
#     "卡死后的恢复延迟"(1 tick -> 2 tick / 1 秒)换开销 —— 属于安全网改造,
#     必须先有 profiler 数据(O02)证明它真是热点, 再经用户点头。
#   · 按武器/状态过滤 @a 同样否决: 选择器判假(状态晚一拍)⇒ 那条进度永久卡死,
#     正是本文件要防的事。
# ============================================================

advancement revoke @a only sweetdream:equipment/armor/brain_leech_attack
advancement revoke @a only sweetdream:equipment/armor/dionysus_helmet
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill_mark_dream
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill_mark_liuhuo
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill_mark_shixin
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill_mark_yehuo
advancement revoke @a only sweetdream:equipment/armor/dusk_dawn_kill_mark_yuanhai
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
#   (电弧 equipment/bow/arc 补于 2026-10-12: 原先只有附魔回调、没有射击进度,
#    这次补上 shot 才成为"自撤销型", 按契约必须登记到这里。)
advancement revoke @a only sweetdream:equipment/bow/arc
#   (弩三件 2026-10-12: 龙舌/云迹/爆裂黎明 与其余 6 把弩同款 —— 射击进度 + shot
#    扣蓝, shot 首行自撤销, 按契约必须登记到这里。)
advancement revoke @a only sweetdream:equipment/bow/dragon_tongue
advancement revoke @a only sweetdream:equipment/bow/cloudtrail
advancement revoke @a only sweetdream:equipment/bow/burst_dawn
#   (批 13 2026-10-13: 退弦(弩·射击) / 引雷针(法杖·右键) / 冰鉴(副手·受击)
#    三条进度同样是"自撤销型", 按契约登记到这里。)
advancement revoke @a only sweetdream:equipment/bow/backstring
#   (批 15-1 2026-10-15: 眠羽/烬弦/逆弦/黯日 四把弩接上命中结算 —— 各自新增
#    "射击进度 + shot 扣蓝", shot 首行 `advancement revoke @s only <自己>`,
#    属自撤销型, 按契约登记到这里。)
advancement revoke @a only sweetdream:equipment/bow/feather_sleep
advancement revoke @a only sweetdream:equipment/bow/ember_string
advancement revoke @a only sweetdream:equipment/bow/reverse_string
advancement revoke @a only sweetdream:equipment/bow/dark_sun
#   (批 15-2 2026-10-15: 归息(胸甲·近战命中) / 殓丝(副手·受击) 两条新进度同样是
#    "自撤销型", 按契约登记到这里。)
advancement revoke @a only sweetdream:equipment/armor/last_breath_hit
advancement revoke @a only sweetdream:equipment/tool/coffin_silk_hurt
#   (批 15-3 2026-10-15: 刺纹(近战命中) / 沸痕(受火伤) / 轻枕·渡梦(受近战) 四条新进度
#    同样是"自撤销型", 按契约登记到这里。)
advancement revoke @a only sweetdream:equipment/armor/thorn_vein_hit
advancement revoke @a only sweetdream:equipment/armor/boil_trace_hurt
advancement revoke @a only sweetdream:equipment/armor/light_pillow_hurt
advancement revoke @a only sweetdream:equipment/armor/cross_dream_hurt
advancement revoke @a only sweetdream:equipment/staff/thunderrod
advancement revoke @a only sweetdream:equipment/tool/frostmirror_hurt
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
#   (itembackup/mainhand 与 itembackup/summon 两条每刻进度循环已随 O03 改造删除:
#    备份改走 storage 快照 + effect_1 精确时机 + lib/second 每秒安全网, 见
#    internal/itembackup/backup.mcfunction 头注释。)
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
# ---- 批 9 · 神经衰弱(2026-10-12) ----
advancement revoke @a only sweetdream:upgrade/neuro_a
advancement revoke @a only sweetdream:upgrade/neuro_b
advancement revoke @a only sweetdream:upgrade/neuro_o
advancement revoke @a only sweetdream:overlimit/stellar_elegy
advancement revoke @a only sweetdream:overlimit/dusk_dawn
advancement revoke @a only sweetdream:overlimit/myriad
# ---- 批 E1 · 超限·剑(2026-10-08) ----
advancement revoke @a only sweetdream:overlimit/rogue_star
advancement revoke @a only sweetdream:overlimit/shadow_blade
advancement revoke @a only sweetdream:overlimit/deepsea_echo
advancement revoke @a only sweetdream:overlimit/everfrost
advancement revoke @a only sweetdream:overlimit/flame_brokenbody
advancement revoke @a only sweetdream:overlimit/sickle_dreams
advancement revoke @a only sweetdream:overlimit/hengdao
advancement revoke @a only sweetdream:overlimit/red_lotus
advancement revoke @a only sweetdream:overlimit/charge
advancement revoke @a only sweetdream:overlimit/anion
# ---- 批 F2 · 超限·斧弩(2026-10-10) ----
advancement revoke @a only sweetdream:overlimit/cold_crow
advancement revoke @a only sweetdream:overlimit/bone_erode
advancement revoke @a only sweetdream:overlimit/sculk_echo
advancement revoke @a only sweetdream:overlimit/dream_reader
# ---- 批 G/H · 超限·法杖/盔甲(2026-10-10) ----
advancement revoke @a only sweetdream:overlimit/begonia
advancement revoke @a only sweetdream:overlimit/polarized_light
advancement revoke @a only sweetdream:overlimit/dionysus_helmet
advancement revoke @a only sweetdream:overlimit/furnace_core
# ---- 批 I1 · 超限·电弧/火种/崩裂/共鸣(2026-10-12) ----
advancement revoke @a only sweetdream:overlimit/arc
advancement revoke @a only sweetdream:overlimit/tinder
advancement revoke @a only sweetdream:overlimit/fissure
advancement revoke @a only sweetdream:overlimit/chime
advancement revoke @a only sweetdream:equipment/armor/dionysus_helmet_hit
# ---- 批 11 · 剑(2026-10-12): 潮痕 / 灰度 / 缺月(主动 + 被动) ----
advancement revoke @a only sweetdream:equipment/sword/tidemark
advancement revoke @a only sweetdream:equipment/sword/grayscale
advancement revoke @a only sweetdream:equipment/sword/crescent
advancement revoke @a only sweetdream:equipment/sword/crescent_hit
# ---- 批 11 · 斧(2026-10-12): 圣骸(主动 + 击杀/命中两条被动) / 沉锚(主动 + 命中被动) / 焦骨 ----
advancement revoke @a only sweetdream:equipment/axe/sacred_relic
advancement revoke @a only sweetdream:equipment/axe/sacred_relic_hit
advancement revoke @a only sweetdream:equipment/axe/sacred_relic_kill
advancement revoke @a only sweetdream:equipment/axe/anchor
advancement revoke @a only sweetdream:equipment/axe/anchor_hit
advancement revoke @a only sweetdream:equipment/axe/scorch_bone
# ---- 批 12 · 法杖(2026-10-13): 五世恶咒 / 很冰的斧 ----
advancement revoke @a only sweetdream:equipment/staff/five_curses
advancement revoke @a only sweetdream:equipment/staff/triad
#   (批 15-4 2026-10-16: 燧行/缝心/浅梦 三套里的四条"近战命中"进度同样是自撤销型 ——
#    燧帽 点火 / 烟履 收割 / 针眠 点噬心 / 镜寐 每 3 次计数, 均按契约登记到这里。
#    ★ 本批其余六件(候潮/焦衣/绯缝 的单件与三套的套装段)走的是 **damage 钩子**
#      (internal/damage/one), 不是进度, 因此**不进**这个清单。)
advancement revoke @a only sweetdream:equipment/armor/flint_hat_hit
advancement revoke @a only sweetdream:equipment/armor/smoke_step_hit
advancement revoke @a only sweetdream:equipment/armor/needle_sleep_hit
advancement revoke @a only sweetdream:equipment/armor/mirror_sleep_hit
# ---- 批 15-5 · 术阵/领域/召唤物(2026-10-16): 重溟(主动 + 平A命中被动) / 长夜(右键分派) ----
advancement revoke @a only sweetdream:equipment/axe/deep_brine
advancement revoke @a only sweetdream:equipment/axe/deep_brine_hit
advancement revoke @a only sweetdream:equipment/staff/long_night
#   凝壳(胸甲)的"受伤"进度同样是自撤销型(entity_hurt_player -> on_hurt 首行 revoke),
#   按契约登记到这里, 否则 /reload 后玩家的受伤进度会卡在已完成状态、再也不触发。
advancement revoke @a only sweetdream:equipment/armor/condensed_shell_hurt
#   迟庭(法杖)走的是右键分派(consume_item -> cast 首行 revoke), 同契约登记。
advancement revoke @a only sweetdream:equipment/staff/late_court
#   雷楔(剑)两条都登记: 右键主动(consume_item) + 平A命中被动(player_hurt_entity)。
advancement revoke @a only sweetdream:equipment/sword/thunder_wedge
advancement revoke @a only sweetdream:equipment/sword/thunder_wedge_hit
# ---- 批 15-6 · 范围主动 + 连锁(2026-10-17) ----
#   退汐(剑)右键主动(consume_item -> cast 首行 revoke), 同契约登记。
advancement revoke @a only sweetdream:equipment/sword/backflow_tide
#   盲烛(剑)两条都登记: 右键主动(consume_item) + 平A命中(player_hurt_entity)。
advancement revoke @a only sweetdream:equipment/sword/blind_candle
advancement revoke @a only sweetdream:equipment/sword/blind_candle_hit
#   丧铃(斧)右键主动(consume_item -> cast 首行 revoke), 同契约登记。
advancement revoke @a only sweetdream:equipment/axe/death_bell
#   剜霜(斧)右键主动(consume_item -> cast 首行 revoke), 同契约登记。
advancement revoke @a only sweetdream:equipment/axe/frost_carve
#   醒梦钟(法杖)右键分派(consume_item -> cast 首行 revoke)。
advancement revoke @a only sweetdream:equipment/staff/wake_bell
#   折径(法杖)右键分派(consume_item -> cast 首行 revoke)。
advancement revoke @a only sweetdream:equipment/staff/bent_ray
#   命缕(法杖)右键分派(consume_item -> cast 首行 revoke)。
#   ★ 原来的 fate_thread_hit(player_hurt_entity) 已删(2026-10-17): 连丝反伤改走
#     core/tick 每刻血量轮询, 覆盖"全部伤害来源", 不再需要事件进度。
advancement revoke @a only sweetdream:equipment/staff/fate_thread
# ---- 批 15-7 · 连接/转化/资源(2026-10-17) ----
#   彼岸(法杖)右键分派(consume_item -> cast 首行 revoke)。
advancement revoke @a only sweetdream:equipment/staff/other_shore
#   失血(剑)两条都登记: 右键主动(consume_item) + 平A命中(player_hurt_entity)。
advancement revoke @a only sweetdream:equipment/sword/blood_loss
advancement revoke @a only sweetdream:equipment/sword/blood_loss_hit
#   杂纹(护腿)的"下一次攻击时停"靠一个全包共用的 player_hurt_entity 进度
#   (不认武器), 同样是自撤销型 -> 必须登记, 否则 /reload 后永远不触发。
advancement revoke @a only sweetdream:equipment/armor/mottle_vein_hit
# ---- 批 14 补技能(2026-10-17): 断页 / 续火 ----
#   两件都是自撤销型进度(consume_item -> cast 首行 revoke) => 必须登记,
#   否则 /reload 之后永远不再触发。
advancement revoke @a only sweetdream:equipment/axe/broken_page
advancement revoke @a only sweetdream:equipment/staff/renew_fire
# ---- 批 14 补技能(2026-10-17): 返照 / 回旋 ----
#   两件都是**全包共用**的 player_hurt_entity 进度(不认武器) => 自撤销型, 必须登记,
#   否则 /reload 之后"近战命中"永远不再触发它们。
advancement revoke @a only sweetdream:equipment/armor/backlight_hit
advancement revoke @a only sweetdream:equipment/armor/gyre_hit
# ---- 批 14 补技能(2026-10-17): 空枕的近战命中 ----
#   空枕的「造成伤害」原本只挂 internal/damage/deal（技能/法球/弩），
#   原版近战普攻不走 deal ⇒ 平A 永远不附「白昼梦」。补这条 player_hurt_entity。
#   自撤销型进度(首行 revoke) => 必须登记，否则 /reload 后平A 不再触发。
advancement revoke @a only sweetdream:equipment/armor/empty_pillow_hit
