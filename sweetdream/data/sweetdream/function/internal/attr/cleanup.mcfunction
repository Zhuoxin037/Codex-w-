# ============================================================
# sweetdream:internal/attr/cleanup —— 重置前的"本包原版属性 + 状态标签"全面清理
# ------------------------------------------------------------
# 【谁调用它】event/player_prepare_new(建档前摘旧属性)与 event/player_reset 的第一行。
#   本函数不改分数/存储; 建档前先摘属性, 迁移/清账仍在登记之后进行(S02)。
# 【执行者】被重置 / 刚注册的那个玩家本人(@s)。
# ------------------------------------------------------------
# 【★★ A04(2026-10-11 三审) ★★】
#   原版属性修饰符是**实体数据**, 它的"到期回收"由各技能的心跳
#   (passive/second/tick)驱动。player_reset 把计时分数(zx.mt_on / zx.lt_end …)清掉
#   之后, 那些心跳选择器不再命中 ⇒ **收尾函数永不执行** ⇒ 修饰符永久残留:
#     · 熔星: `sweetdream:meteor`(attack_speed ×2) —— 攻速永久变大;
#     · 残念: `sweetdream:lethe_speed`(+100%) + 状态标签 zx.lethe。
#   当时只收拾了这两件"状态型", 并特意**不碰**装备型 —— 理由是"装备型是常驻的,
#   会按账本自己重算加回"。
# 【★★ Q04(2026-10-11 四审): 那个理由不成立 ★★】
#   "会自己重算加回"只在**账本还在**时成立, 而 player_reset 的清账清单
#   (N06, 见 event/player_reset)恰恰会把装备账本一起清掉: zx.power_hp / zx.set_hp /
#   zx.set_mana / …。清完之后按"重置那一刻穿没穿"分岔:
#     · 穿着   -> want=N, 账本=0 ⇒ #diff=N ⇒ 调 apply_hp ⇒ 加回来(值正确) ✓
#     · **没穿** -> want=0, 账本=0 ⇒ #diff=0 ⇒ **跳过 apply_hp** ⇒ 那份修饰符留在身上;
#       而且 apply_hp 自己的"先按旧账摘"门(`if score @s zx.power_hp matches 1..`)
#       随着账本归零一起失效 ⇒ **以后再也摘不掉** ⇒ 永久 +8 生命上限(报告 Q04 例)。
#   ⇒ 正解 = 重置时把**本包挂的全部修饰符一律摘干净**, 再用"已清零的账本"让被动按
#     当前穿戴重算: 穿着 ⇒ 重新挂上(值正确); 没穿 ⇒ 保持干净。重置的语义本来就是
#     "把这个人恢复成新玩家", 身上不该残留任何本包给的东西。
# ------------------------------------------------------------
# 【★ 为什么要连"状态标签"一起清 ★】
#   部分修饰符由**标签**驱动(不是分数):
#     · zx.freeze        <-> sweetdream:freeze        (lib/freeze_hold 每 tick 认这个标签)
#     · zx.status.liuhuo <-> sweetdream:tag_liuhuo    (tag/mark_one 施加时挂)
#     · zx.status.dream  <-> sweetdream:tag_dream_atk
#     · zx.rm_melt       <-> sweetdream:remelt        (remelt/second 每秒认这个标签)
#     · zx.tw_tgt        <-> sweetdream:tw_armor / tw_tough
#     · zx.lethe         <-> sweetdream:lethe_speed
#   只摘修饰符、留标签 = 留下"不一致"(标签还在 ⇒ 一堆读标签的逻辑继续误判:
#   spirit_sight 发光 / dusk_dawn 击杀计数 / burned_out 判定 …), 而且 freeze_hold 这种
#   每 tick 的还会把状态续上。所以**成对清**: 每个被摘的"标签驱动型"修饰符,
#   它的标签也一并去掉。范围就是下表这 6 对, 不做"海量 tag 全清"(那是另一件事)。
# 【★ 升级属性 ★】`upg_*`(升级/超限给的)也算装备型 —— 一并摘掉后按穿戴重算, 见第二段。
# 【★ `modifier remove` 撞空会不会出事（2026-10-16 更正）★】
#   ★ 旧注释写的是"对不存在的 id 是空操作" —— **不准**。wiki `/attribute` 的 Result 表
#     把"不存在具有指定命名空间ID的修饰符"明确列为**执行失败**。
#   ★ 但**失败不会中断函数**: 本包 lib/unfreeze_one 就是"无条件 remove 后面还接着
#     4 条命令"(含摘 zx.freeze 标签), 而那条 remove 常常撞空 —— 功能一直正常, 说明
#     后面的命令照跑。所以这里可以不判存在, 一路 remove 下去。
#   ★ 另一种风格是加门控(armor_hp/passive: `execute if score … matches 1.. run …remove`),
#     两者都对; 差别只是"撞空时要不要白报一次失败"。
# ============================================================

# ---- 一) 状态型修饰符(施法/命中时挂, 靠分数或标签到点摘) ----
# 熔星(陨星): 攻速倍率        (zx.mt_on 被清零 ⇒ end 永不跑)
attribute @s minecraft:attack_speed modifier remove sweetdream:meteor
# 残念(沉溺忘川彼岸): 速度倍率 + 状态标签
#   标签必须一起摘: 每秒回魔与"到期解除"都只看标签/到期刻 —— 留着标签就等于
#   速度翻倍 + 每秒 +20 魔力"永久"续下去(zx.lt_end 已被清, 到期判定永不成立)。
attribute @s minecraft:movement_speed modifier remove sweetdream:lethe_speed
tag @s remove zx.lethe
# 冰冻(lib/freeze): 速度压到 0 + 冻结续期标签
#   (freeze_hold / unfreeze_dim 本来有"计时被清 ⇒ 兜底解冻"那条自愈路, 这里顺手
#    即时解冻, 免得先被补满 TicksFrozen、下一 tick 才解, 白抖一帧)
attribute @s minecraft:movement_speed modifier remove sweetdream:freeze
tag @s remove zx.freeze
# 熔蚀(remelt): 护甲乘区压到 0   (zx.rm_t 被清 ⇒ melt_end 永不跑)
attribute @s minecraft:armor modifier remove sweetdream:remelt
tag @s remove zx.rm_melt
# 暮光锁链(twilight): 护甲/韧性减半   (倒计时分数被清 ⇒ tw_tick 卡在"还在")
attribute @s minecraft:armor modifier remove sweetdream:tw_armor
attribute @s minecraft:armor_toughness modifier remove sweetdream:tw_tough
tag @s remove zx.tw_tgt
# 状态标签类(tag/mark_one 施加时挂, 撤销只在 tag/unmark_one):
#   流火 -> 护甲 -20%; 白昼梦 -> 攻击力 -20%。
#   ★ reset 清掉 zx.tt.liuhuo / zx.tt.dream 之后, ttl_tick 的 `matches ..0` 判定
#     再也不成立 ⇒ unmark_one 永远不会被调用 ⇒ 修饰符与标签双双残留。
attribute @s minecraft:armor modifier remove sweetdream:tag_liuhuo
attribute @s minecraft:attack_damage modifier remove sweetdream:tag_dream_atk
tag @s remove zx.status.liuhuo
tag @s remove zx.status.dream

# ---- 一·五) 回血原语的**临时**上限(2026-10-16 加) ----
#   lib/heal_up 会把 max_health 临时压低(修饰符 `sweetdream:heal_cap`), 正常由 core/tick
#   在两拍后摘掉。这里兜底那个窗口: 重置/建档**恰好卡在"压低之后、摘掉之前"**时,
#   计时标签会被清、修饰符就永远留着(血条变短, 且再也摘不掉)。
#   ★ 两个标签(heal_p / heal_on)必须一起摘: 它们是 lib/heal_up ① 的门控,
#     留着会让"下一轮"误以为"已经挂着", 从而去摘一个不存在的修饰符。
attribute @s minecraft:max_health modifier remove sweetdream:heal_cap
tag @s remove zx.heal_p
tag @s remove zx.heal_on

# ---- 二) 装备型修饰符(常驻; 按穿戴 / 升级等级持续存在) ----
#   摘掉之后由各装备的每秒被动按"已清零的账本"重算: 穿着 ⇒ 重新挂上(值正确),
#   没穿 ⇒ 保持干净(Q04 要的正是后者)。**(别再写回"装备型不摘")**
# 生命上限: 体外供能 / 体外套装 / 熔炉核心 / 脊共生 / 升级
attribute @s minecraft:max_health modifier remove sweetdream:eqp_power_hp
attribute @s minecraft:max_health modifier remove sweetdream:eqp_set_hp
attribute @s minecraft:max_health modifier remove sweetdream:eqp_fc_hp
attribute @s minecraft:max_health modifier remove sweetdream:eqp_ss_hp
attribute @s minecraft:max_health modifier remove sweetdream:upg_hp
# 护甲: 脊共生 / 升级
attribute @s minecraft:armor modifier remove sweetdream:eqp_ss_armor
attribute @s minecraft:armor modifier remove sweetdream:upg_armor
# 护甲韧性: 升级
attribute @s minecraft:armor_toughness modifier remove sweetdream:upg_tough
# 攻击力: 脑蛭 / 无光之海 / 蜃楼套装
attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_bl_atk
attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_ls_atk
attribute @s minecraft:attack_damage modifier remove sweetdream:eqp_mr_set_atk
