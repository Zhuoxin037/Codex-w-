# ============================================================
# sweetdream:lib/skill_mul/def —— 「技能倍率口径表」(由 core/load 调用一次)
# ------------------------------------------------------------
# 【这是干嘛的】
#   框架把技能倍率拆成了三条通道(manacore/internal/damage/calc):
#       max_mana_mul = 最大魔力值技能倍率
#       attack_mul   = 基础攻击力倍率
#       other_mul    = 其他倍率(基数默认当前魔力)
#   每个技能在**自己的文件里**声明走哪条 —— 那是"结算"的真相。
#   但 debug/stats 要在面板上把"在身装备给这三条通道各加了多少"分开列出来,
#   就得先知道"手里这把武器用它自己哪几条通道"。这张表就是为这一件事服务的。
#
# 【★ 它只影响显示, 不影响结算 ★】
#   结算永远以技能文件里写的那条通道为准(所以同一把武器不同技能各走各的也不会串)。
#   这里的标记只在"某把武器的技能确实分属两条通道"时写成两条(目前只有风行)。
#   如果哪天改了某个技能的通道口径 —— 记得同步这一行, 否则面板会把它归错列。
#
# 【字段】{mm:0b/1b, atk:0b/1b, oth:0b/1b} —— 1b = 这把武器的技能会用到该通道
# 【为什么用复合体而不是列表】宏占位符能安全地出现在引号键里, 但不能当数组下标
#   (formations[$(i)] 那种写法会让整个函数加载失败, 见 core/boot 的说明)。
#   复合体还顺便让"判某一条通道"写成 if data ...{mm:1b}, 一次到位。
#
# 【以后加了有伤害技能的武器】在下面补一行即可; 不补 = 面板上它的超限伤害
#   不会出现在任何一条通道里(不会报错, 只是少显示), check.py 会校验 id 是否登记过。
# ============================================================

data modify storage zx:config wchan set value {}

# ---- 剑 ----
# 流光: 以基础攻击力结算(×2 / ×4)
data modify storage zx:config wchan.liuguang set value {mm:0b,atk:1b,oth:0b}
# 横刀: 最大魔力 ×0.08
data modify storage zx:config wchan.hengdao set value {mm:1b,atk:0b,oth:0b}
# 引梦镰: 最大魔力 ×0.05 / ×0.2
data modify storage zx:config wchan.sickle_dreams set value {mm:1b,atk:0b,oth:0b}
# 深海的回响: 当前魔力 ×0.15
data modify storage zx:config wchan.deepsea_echo set value {mm:0b,atk:0b,oth:1b}
# 烈火, 残躯: 最大魔力 ×0.1 / ×0.2
data modify storage zx:config wchan.flame_brokenbody set value {mm:1b,atk:0b,oth:0b}
# 燎原: 最大魔力 ×0.04
data modify storage zx:config wchan.liaoyuan set value {mm:1b,atk:0b,oth:0b}
# 影刃: 基础伤害 ×2(基础攻击力通道)
data modify storage zx:config wchan.shadow_blade set value {mm:0b,atk:1b,oth:0b}
# 热熔: 基础攻击力 ×2(熔解状态每击同步那次)
data modify storage zx:config wchan.remelt set value {mm:0b,atk:1b,oth:0b}
# 无息(2026-10-07 批1): 突击往返两段 = 最大魔力 ×0.1 / ×0.2(都是 mm)
data modify storage zx:config wchan.hush set value {mm:1b,atk:0b,oth:0b}
# 游星(2026-10-07 批1): 锁定 3 秒后 2 格 AOE = 基础攻击力 ×4(atk)
data modify storage zx:config wchan.rogue_star set value {mm:0b,atk:1b,oth:0b}
# 永霜(2026-10-07 批1): 冰后结算 = **当前剩余魔力** ×0.1(other 通道基数默认当前魔力)
data modify storage zx:config wchan.everfrost set value {mm:0b,atk:0b,oth:1b}
# 神裁(2026-10-07 批1): 被动 基础攻击力 ×2(atk) + 主动 最大魔力 ×0.1(mm) + 领域 基础攻击力 ×3(atk)
#   -> 两段分属 mm / atk 两条通道, 所以标两条(和天使核心/天穹同款)。
data modify storage zx:config wchan.verdict set value {mm:1b,atk:1b,oth:0b}
# 火种(2026-10-07 批1): 燃烧态攻击 = **当前剩余魔力** ×0.1(other); 反噬是固定值(最大生命×0.3, 不走通道)
data modify storage zx:config wchan.tinder set value {mm:0b,atk:0b,oth:1b}
# 回锋(2026-10-07 批1): 前方 3×5 = 基础攻击力 ×2(atk)
data modify storage zx:config wchan.rebound set value {mm:0b,atk:1b,oth:0b}

# ---- 斧 / 弓 / 法杖 ----
# 超·负·荷: 当前魔力 ×0.05(other)
#   ★ 超限(2026-10-09 批 F1)又多了两条: ②落点追加 = 基础攻击力 ×3(atk),
#     ③所以现在是 oth + atk 两条通道(面板要把两边都列出来)。
data modify storage zx:config wchan.charge set value {mm:0b,atk:1b,oth:1b}
# 沉渊: 无增益 = 当前魔力 ×0.08(other), 有增益 = 最大魔力 ×0.08(mm) -> 两条都走
data modify storage zx:config wchan.chenyuan set value {mm:1b,atk:0b,oth:1b}
# 天使核心: 第一段 基础攻击力 ×8(atk), 第二段 最大魔力 ×0.08(mm)
data modify storage zx:config wchan.angel_core set value {mm:1b,atk:1b,oth:0b}
# 陨星: 陨石伤害 = 基础攻击力 ×4
data modify storage zx:config wchan.meteor set value {mm:0b,atk:1b,oth:0b}
# 天穹: 俯冲冲击 = 最大魔力 ×0.12(mm), 每层升痕额外 基础攻击力 ×2(atk)
data modify storage zx:config wchan.skyvault set value {mm:1b,atk:1b,oth:0b}
# 寒鸦: 最大魔力 ×0.1 / ×0.25
data modify storage zx:config wchan.cold_crow set value {mm:1b,atk:0b,oth:0b}
# 风行于大地之上: 普攻 = 当前魔力 ×0.04(其他), 爆发/回响 = 最大魔力 ×0.07 / ×0.04
#   —— 这是唯一一把横跨两条通道的武器, 所以标两条。
data modify storage zx:config wchan.wind_ontheground set value {mm:1b,atk:0b,oth:1b}

# ---- 第五批(2026-10-05)第一批效果 ----
# 万念: 基础技能 = 当前魔力 ×0.1(other); 超限特殊技能(special_go)按手里那把分流:
#   千散 -> 基础攻击力 ×3(atk) / 万念 -> 最大魔力 ×0.12(mm) => 三条都标。
#   (和神裁/风行同款: 一个技能文件里出现多条通道, 就登记多条。)
data modify storage zx:config wchan.myriad set value {mm:1b,atk:1b,oth:1b}
# 千散: 基础版 ×2 / 超限版 ×3(都是基础攻击力倍率)
data modify storage zx:config wchan.qiansan set value {mm:0b,atk:1b,oth:0b}

# ---- 第五批(2026-10-05)第二批: 4 把弩 ----
# 蚀骨: 本次射击消耗魔力 ×0.4(固定值, 不走倍率通道; 登记只为让 check 覆盖到)
data modify storage zx:config wchan.bone_erode set value {mm:0b,atk:0b,oth:0b}
# 幽匿残响: 命中范围伤 = 基础攻击力 ×悲鸣 ×0.1(走 attack_mul 通道)
data modify storage zx:config wchan.sculk_echo set value {mm:0b,atk:1b,oth:0b}
# 虹彩: 吞噬/结束伤害 = 最大生命值 ×0.1 / ×0.2(固定值, 不走倍率通道; 登记只为覆盖)
data modify storage zx:config wchan.rainbow set value {mm:0b,atk:0b,oth:0b}
# 清醒梦: 当前魔力 ×0.X / 最大魔力 ×0.0X(走 mm + oth 通道)
data modify storage zx:config wchan.lucid_dream set value {mm:1b,atk:0b,oth:1b}

# ---- 第五批(2026-10-05)第三批: 斧 1 + 法杖 4 ----
# 苦痛: 锁定 DoT = 被锁者基础攻击力 ×2(读目标面板, 不走三条通道; 登记只为覆盖)
data modify storage zx:config wchan.agony set value {mm:0b,atk:0b,oth:0b}
# 偏振光: 普攻固定 6 点; 光束 = 当前魔力 ×0.05(其他倍率)
data modify storage zx:config wchan.polarized_light set value {mm:0b,atk:0b,oth:1b}
# 惑梦: 普攻 = 最大魔力 ×0.02, 分支 A = 最大魔力 ×0.1(都是 mm)
data modify storage zx:config wchan.delusion set value {mm:1b,atk:0b,oth:0b}
# 堕梦: 普攻 = 最大魔力 ×0.03(mm); 命中回调是固定数值(fdmg, 不走通道)
data modify storage zx:config wchan.fallen_dream set value {mm:1b,atk:0b,oth:0b}
# 启示录: 普攻 = 最大魔力 ×0.03(mm); 灾示是固定数值(页记录, 不走通道)
data modify storage zx:config wchan.apocalypse set value {mm:1b,atk:0b,oth:0b}

# ---- 第五批(2026-10-05)第四批: 盔甲 2 ----
# 枯枝园: 朽木 DoT = 释放者最大魔力 ×0.08(mm)
data modify storage zx:config wchan.withered_garden set value {mm:1b,atk:0b,oth:0b}
# 无光海: 套装 DoT = 释放者最大魔力 ×0.1(mm)
data modify storage zx:config wchan.lightless_sea set value {mm:1b,atk:0b,oth:0b}

# ---- 盔甲(有伤害技能的) ----
#   面板扫描只看主手, 盔甲这两条**不影响显示**, 列在这里是为了让 check 的
#   "口径表 vs 技能文件"反向校验能覆盖到(表里没有就会报错)。
# 群星坠落之挽歌: 当前魔力 ×0.02
data modify storage zx:config wchan.stellar_elegy set value {mm:0b,atk:0b,oth:1b}
# 共振: 每术阵 +10% 技能伤害, 走 damage_calc 事件乘最终 r.damage(数学上 ≡ 三条通道各 ×k),
#   面板在 scan_mul 里把 k 乘进三条 smul 通道显示。这里标三条都走, 让 check 的
#   "口径表 vs 技能文件"覆盖到(names 里已有 resonance)。
data modify storage zx:config wchan.resonance set value {mm:1b,atk:1b,oth:1b}

# ---- 第一批效果(2026-10-06 晚): 盔甲被动伤害 ----
#   这两条同样是"盔甲被动", 面板扫不到, 登记只为让 check 的反向校验覆盖到。
# 漫步冥河之上: 「暗海」每秒伤害 = 释放者最大魔力 ×0.06(mm)
data modify storage zx:config wchan.styx_walk set value {mm:1b,atk:0b,oth:0b}
# 沉溺忘川彼岸: 解除「残念」的爆发 = 自身最大魔力 ×0.06(mm)
data modify storage zx:config wchan.lethe_shore set value {mm:1b,atk:0b,oth:0b}

# ---- 第二批效果(2026-10-06 晚): 副手道具的伤害 ----
#   同样是"装备被动", 面板扫不到, 登记只为让 check 的"口径表 vs 技能文件"反向校验覆盖到。
# 雷鸣: 第二道闪电的额外伤害 = 自身最大魔力 ×0.03(mm)
data modify storage zx:config wchan.thunder set value {mm:1b,atk:0b,oth:0b}

# ---- 第三批效果(2026-10-06 晚): 负离子(斧) ----
# 负离子: 主动 = 自身**当前**魔力 ×0.1(other_mul, 基数默认就是当前魔力)
#   ★ 超限(2026-10-09 批 F1): ①主伤 → 当前魔力 ×0.12(other);
#     ②1 秒后那道雷 = **最大**魔力 ×0.08(mm) —— 所以现在是 oth + mm 两条通道。
#     ③"8 秒雷劲"的落点追加也是当前魔力 ×0.1(other), 与 ① 同一条通道。
data modify storage zx:config wchan.anion set value {mm:1b,atk:0b,oth:1b}

# ---- 第三批效果(2026-10-06 晚): 终末天启(法杖) ----
# 终末天启: 普攻是固定 20 点(不走通道); 光柱每秒 最大魔力 ×0.1 / 收尾 ×0.2 都是 mm
data modify storage zx:config wchan.final_revelation set value {mm:1b,atk:0b,oth:0b}

# ---- 第三批效果(2026-10-06 晚): 炽天使之翼 / 愠怒(副手) ----
#   两个都是**按通道区分**的装备加成, 但落点不同(2026-10-06 二次修正):
#     · 加算(共振 / 漫步 / 炽天使): hook 只往加算池 zx:work add 写百分比,
#       由 lib/dmg_add_apply 统一乘一次 —— 面板同款(lib/skill_mul/padd_apply)。
#     · 独立乘区(愠怒): 乘在加算之后(排 dmg_add_apply **后面**), 面板折
#       pl.independent_multiplier。
#   都在副手槽, 面板 gear 段(只看主手)扫不到 —— 登记只为让 check 的
#   "口径表 vs 技能文件"反向校验覆盖到。
# 炽天使之翼: 有关**基础攻击力**的技能 +50%(加算) -> 只吃 atk 通道
data modify storage zx:config wchan.seraph_wing set value {mm:0b,atk:1b,oth:0b}
# 愠怒: 血量<20% 时有关**最大魔力值**的技能 +20%(**独立乘区**) —— 判"本次技能走不走
#   mm 通道", 走则**整体**乘(三条通道求和 + 加算池之后再乘)。
#   ★ 这里标 mm:1b 表达的是**判据**(要判技能有没有走 mm 通道), 不是"并进 mm 通道"。
#   面板折的是 pl.independent_multiplier(「独立乘区」行), **不折** smul_mm。
data modify storage zx:config wchan.wrath set value {mm:1b,atk:0b,oth:0b}

# ---- 批2 · 斧(2026-10-07): 8 件里 6 件有伤害 ----
# 崩裂: 立即段 基础攻击力 ×5 / 裂缝每秒段 基础攻击力 ×1 -> 都是 atk
data modify storage zx:config wchan.fissure set value {mm:0b,atk:1b,oth:0b}
# 释梦: 主动首段 = **当前魔力** ×0.1(other 通道基数默认当前魔力) -> oth
data modify storage zx:config wchan.dream_reader set value {mm:0b,atk:0b,oth:1b}
# 葬火 / 饮鸩: **没有**走倍率通道的伤害
#   · 葬火: 伤害是"放空的魔力值 X"这个**绝对点数**(api/damage 直接给 damage),
#     不乘任何基数 -> 不登记(登记了反而会让面板算出一条不存在的通道加成)。
#   · 饮鸩: 没伤害(血量换基础攻击力), 更没有通道。
# 歌谣: 基础攻击力 ×(9-X), 下限 ×1 -> atk
data modify storage zx:config wchan.ballad set value {mm:0b,atk:1b,oth:0b}
# 威霆: 每道闪电 = 最大魔力值 ×0.1 -> mm
data modify storage zx:config wchan.thunderclap set value {mm:1b,atk:0b,oth:0b}
# 红莲: 每层「流火」基础攻击力 ×1 / 每层「夜火」×3 -> atk
data modify storage zx:config wchan.red_lotus set value {mm:0b,atk:1b,oth:0b}
# 苍蓝星: 最近一只 最大魔力值 ×0.5 / 其 2 格内 ×0.1 -> mm
#   ★ 被动"翻倍"折的也是 mm(见 azure_star/scan_mul 的 @panel: smul_mm)。
data modify storage zx:config wchan.azure_star set value {mm:1b,atk:0b,oth:0b}

# ---- 批3 · 法杖(2026-10-07) ----
# 共鸣: 普攻是**固定 7 点**(不走通道); 水晶每 2 秒 ×0.03 / "法术穿过" ×0.05 都是 mm
data modify storage zx:config wchan.chime set value {mm:1b,atk:0b,oth:0b}
# 调色盘: 普攻固定 1 点(不走通道); “色彩”命中 = 最大魔力 ×0.1×(1+红数) -> mm
data modify storage zx:config wchan.palette set value {mm:1b,atk:0b,oth:0b}
# 海棠: 普攻 = 当前魔力 ×0.02 -> oth; 漩涡结束 = 最大魔力 ×0.15 -> mm
data modify storage zx:config wchan.begonia set value {mm:1b,atk:0b,oth:1b}
# 蛊毒: 普攻 = 当前魔力 ×0.04 -> oth; 主动每秒 = 最大生命 ×0.1 -> 生命系数(非三通道)
data modify storage zx:config wchan.gu_poison set value {mm:0b,atk:0b,oth:1b}
# 暮光: 普攻 = 最大魔力 ×0.03 -> mm(补发的那一发也是同一数值); 主动无伤害
data modify storage zx:config wchan.twilight set value {mm:1b,atk:0b,oth:0b}
# 风帆: 普攻固定 1 点(不走通道); 主动只产标记/吸引, 无伤害
data modify storage zx:config wchan.sail set value {mm:0b,atk:0b,oth:0b}

# ---- 批3 · 弩(2026-10-07) ----
# 电弧: 配对放电 = 基础攻击力 ×2 + 当前魔力 ×0.03 -> atk + oth(两条通道都走)
data modify storage zx:config wchan.arc set value {mm:0b,atk:1b,oth:1b}
