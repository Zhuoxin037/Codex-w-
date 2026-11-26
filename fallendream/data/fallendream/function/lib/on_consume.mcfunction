# ============================================================
# fallendream:lib/on_consume —— 一个通用标签**真被消耗掉**之后的装备被动派发
# ------------------------------------------------------------
# 【谁调用它】lib/mark_take ④（只在「永恒」没把标签补回来 = 真的摘掉了时才跑）
# 【宏参数】zx:work mc {target, mark, by, src, ok:1b, done:0b}
#   · target : 被消耗标签的那只（选择器字符串）
#   · mark   : 刚被消耗的标签名（liuhuo/yehuo/shixin/yuanhai/dream）
#   · by     : **消耗者**（技能发起的那个玩家；默认 "@s"）
#   · src    : "skill"（默认）/ "equip" —— 见 lib/mark_consume ①.5
# 【★ 两种身份都要照顾到, 顺序不能换 ★】
#   ① 余烬(lib/mark_ember)：**只认 @s**（原执行者）—— 它的语义是"消耗者身上穿的装备",
#      而这个 @s 就是调用点本人; 换身份会让它认错人。
#   ② 下面这些：认的是**消耗者**(mc.by)。技能往往在"以射手身份"的上下文里发起消耗
#      (比如弩的 fire 用 as 射手 跑), 那时 @s 与 by 是同一人; 但"目标身上的标签被吞"
#      (虹彩/清醒梦)那类, by 是反查出来的施法者 —— 必须按 by 走。
#   ⇒ 所以这里**先给余烬**, 再换成 by 的身份逐件派发。
# 【★ 为什么逐件门控写在这一层、不许再往下拆一层 ★】
#   ① check.py 的 equipgate 规则**只看一层**: mark_take 直接调用的那个函数体里
#      必须出现 `items entity @s`。所以门控必须落在这个文件里, 不能塞进子文件
#      (曾经拆成 on_consume → on_consume_go, 结果规则立刻报了出来)。
#   ② 门控必须在函数体内判**穿着** —— 这里的 @s 是消耗者, 他穿没穿完全取决于玩家,
#      不判就会"没穿也生效"(静默), 而这层比别的还狠: 会**白扣魔力**。
#      (真实事故 2026-10-06: eternity/reclaim 与 lib/mark_ember 初版都漏了门控。)
# 【★ src 过滤 ★】回潮扣 / 烛跬 的文案写的是"自身**技能**消耗…" ⇒ 加 `src:"skill"`;
#   装备被动自己消耗的那一次(归息/殓丝 发的 src:"equip")不算。
# 【本文件是宏函数】要 `execute as $(by)`; 而"目标/标签名"是字符串, 拼选择器也得靠宏。
# ============================================================

# ① 余烬（既有契约不变: 只认 @s）
function fallendream:lib/mark_ember

# ② 回潮扣(副手): 技能消耗「渊海」-> 把被消耗那只 2 格内最多 2 个其他生物拉近 0.75 格
#    ★ 需要"被消耗的那只"当圆心 ⇒ 这一件要读 mc.target(字符串选择器), 交给宏叶子。
$execute as $(by) if data storage zx:work mc{mark:"yuanhai",src:"skill"} if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["tide_buckle"]}] run function fallendream:equipment/tool/tide_buckle/pull

# ③ 烛跬(靴子): 技能消耗「夜火」-> 回 18 魔力; 消耗「流火」-> 回 8 魔力
$execute as $(by) if data storage zx:work mc{mark:"yehuo",src:"skill"} if items entity @s armor.feet *[minecraft:custom_data~{zx:["candle_step"]}] run function fallendream:equipment/armor/candle_step/consume
$execute as $(by) if data storage zx:work mc{mark:"liuhuo",src:"skill"} if items entity @s armor.feet *[minecraft:custom_data~{zx:["candle_step"]}] run function fallendream:equipment/armor/candle_step/consume

# ④ 杂纹(护腿, 2026-10-17 批 15-7): 记录"这一轮消费过哪几种状态", 满 3 种兑现
#    【文案(lore 逐字)】"从自身第一次成功消费状态标签开始，记录接下来 8 秒内消费过的
#      不同种类：流火、夜火、噬心、渊海、白昼梦。同一种类只计一次。累计消耗 3 种后，
#      清空记录，立即恢复 20 点魔力值……"
#    ★ 这一件**不按 src 过滤**：文案写的是"消费状态标签", 没有限定"技能消耗",
#      所以 技能消耗 / 装备被动顺手消耗(归息・殓丝・失血) 都算。
#    ★ 传的是整份 mc（含 mark）—— consume 是宏叶子, 要拼 zx.mv.$(mark) 标签名。
$execute as $(by) if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"]}] run function fallendream:equipment/armor/mottle_vein/consume with storage zx:work mc

# ⑤ 回旋(护腿, 2026-10-17 批 14 补技能): 技能消费「渊海」-> 获得「旋步」6 秒
#    【文案(逐字)】"自身技能成功消费一个生物的「渊海」后，为自身获得持续 6 秒的
#      「旋步」。该效果 12 秒内最多触发一次。"
#    ★ src:"skill" —— 文案写的是"自身**技能**成功消费", 装备被动顺手消耗不算。
$execute as $(by) if data storage zx:work mc{mark:"yuanhai",src:"skill"} if items entity @s armor.legs *[minecraft:custom_data~{zx:["gyre"]}] run function fallendream:equipment/armor/gyre/get

# ⑥ 心脉(胸甲, 2026-10-25 批 14): 自身消耗「噬心」-> 给它附加「泵动」5 秒(上限 12 秒)
#    【文案(逐字)】"若自身消耗了「噬心」效果则使其附加持续 5 秒的「泵动」（最多 12 秒）。"
#    ★ 不按 src 过滤: 文案只写"自身消耗了", 不限定"技能消耗"（与 ④ 杂纹同口径）。
#    ★ 已带泵动的那一次由 heart_vein/consume 内部走"叠加 + 立即 ×0.08"分支。
#    ★ 「泵动」是私有资源, 不进标签词表。
$execute as $(by) if data storage zx:work mc{mark:"shixin"} if items entity @s armor.chest *[minecraft:custom_data~{zx:["heart_vein"]}] run function fallendream:equipment/armor/heart_vein/consume with storage zx:work mc

# ⑦ 折潮(头盔, 2026-10-25 批 14): 消耗「渊海」-> 在自身位置立一面水墙
#    【文案(逐字)】"自身在消耗「渊海」或消耗了 150 魔力值后在自身位置生成一面长 8 格
#      持续 10 秒的水墙，水墙同时只能存在 4 个。"
#    ★ 不按 src 过滤: 设计稿 §六 明确"指本包里**任意一次**对渊海的消费成功
#      (不限哪个装备消费的)" ⇒ 装备被动顺手消费的也算(与 ④ 杂纹同口径)。
$execute as $(by) if data storage zx:work mc{mark:"yuanhai"} if items entity @s armor.head *[minecraft:custom_data~{zx:["tide_fold"]}] run function fallendream:equipment/armor/tide_fold/new

# ⑧ 燧帽(头盔, 2026-11-22 超限): 自身成功消耗「流火」→ 节流立刻结束 + 下一次点上的
#    「流火」额外让目标基础护甲 −50%。
#    【文案(逐字)】"自身成功消耗「流火」后，则该效果冷却立刻结束并获得加强：普通近战
#      命中了未附有「流火」且仍存活的生物后则使其附加「流火」，之后使本次附加的
#      「流火」效果强化为使其基础护甲值降低 50%。"
#    ★ 不按 src 过滤: 文案只写"自身成功消耗", 没限定技能消耗(与 ④ 杂纹 / ⑥ 心脉同口径)。
#    ★ 认的是**消耗者**(by): 技能在"以射手身份"的上下文里发起消耗时 @s 与 by 同人。
$execute as $(by) if data storage zx:work mc{mark:"liuhuo"} if items entity @s armor.head *[minecraft:custom_data~{zx:["flint_hat"],ol:"flint_hat"}] run function fallendream:equipment/armor/flint_hat/empower

# ⑨ 候潮(胸甲, 2026-11-22 超限): 由**本件**附加的「渊海」被自身消耗 -> 回 2% 最大魔力
#    + 抗性提升Ⅱ 4 秒 + 3 格内生物击退一格。
#    【文案(逐字)】"由本件附加的「渊海」被自身消耗后，自身恢复 2% 最大魔力值并获得
#      4 秒抗性提升Ⅱ，之后使自身 3 格内的生物被击退一格。"
#    ★ 不按 src 过滤: 文案只写"被自身消耗", 没限定技能消耗(与 ④ 杂纹 / ⑥ 心脉同口径)。
#    ★ 认的是**消耗者**(by)。"是不是本件贴的"由 mark_take 摘标签前的 zx.tw_src 快照判;
#      这一行只是先挡掉"根本没穿超限候潮"的绝大多数情况(连快照都不用查)。
$execute as $(by) if data storage zx:work mc{mark:"yuanhai"} if items entity @s armor.chest *[minecraft:custom_data~{zx:["tide_watch"],ol:"tide_watch"}] if entity @e[tag=zx.tw_src,distance=0..] run function fallendream:equipment/armor/tide_watch/ol_consume

# ⑩ 滩纹(护腿, 2026-11-23 超限): 自身消耗「渊海」-> 护甲加成保留 6 秒；
#    若此时魔力 <50% 额外恢复一次 3% 最大魔力。
#    【文案(逐字)】"自身消耗「渊海」后且范围内没有附有「渊海」的生物时，上述护甲加成
#      继续保留 6 秒。且若此时魔力值低于最大魔力值的50%，则额外恢复一次 3% 魔力值。"
#    ★ 不按 src 过滤: 文案只写"自身消耗", 没限定技能消耗(与 ⑨ 候潮同口径)。
#    ★ 认消耗者(by)。"范围内还有没有渊海"由 ol_consume 内部现判——有的话 armor_sync
#      本来就会给 +4，窗口只是让它掉了以后不立刻撤。
$execute as $(by) if data storage zx:work mc{mark:"yuanhai"} if items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"],ol:"beach_vein"}] run function fallendream:equipment/armor/beach_vein/ol_consume

# ⑪ 镜寐(护腿, 2026-11-23 超限): 由**本件**附加的「白昼梦」被消耗 -> 3 格内其他生物
#    附加 8 秒白昼梦 + 自身回 1% 最大魔力。
#    【文案(逐字)】"本次附加的「白昼梦」若被消耗则使被消耗的生物的 3 格内的其他生物
#      被附加一次持续 8 秒的「白昼梦」，之后使自身恢复 1% 魔力值。"
#    ★ "是不是本件附加的"由 mark_take 摘标签前的 zx.ms_src 快照判;
#      这一行先挡掉"根本没穿超限镜寐"的绝大多数情况。
$execute as $(by) if data storage zx:work mc{mark:"dream"} if items entity @s armor.legs *[minecraft:custom_data~{zx:["mirror_sleep"],ol:"mirror_sleep"}] if entity @e[tag=zx.ms_src,distance=0..] run function fallendream:equipment/armor/mirror_sleep/ol_consume

# [batch22] ---- 2026-11-07 批 22：长愿领域内被消耗的通用标签 ----
#   外层只看"场上有没有领域"(纯性能门控)；"被消耗者是否真在 8 格领域内"
#   由 on_consume 叶子自己判。转移/伤害与消耗者手上拿什么无关。
execute if entity @e[tag=zx.lw_field,limit=1] run function fallendream:equipment/staff/long_wish/on_consume with storage zx:work mc
