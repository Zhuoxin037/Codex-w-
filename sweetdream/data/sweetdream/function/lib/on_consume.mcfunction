# ============================================================
# sweetdream:lib/on_consume —— 一个通用标签**真被消耗掉**之后的装备被动派发
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
function sweetdream:lib/mark_ember

# ② 回潮扣(副手): 技能消耗「渊海」-> 把被消耗那只 2 格内最多 2 个其他生物拉近 0.75 格
#    ★ 需要"被消耗的那只"当圆心 ⇒ 这一件要读 mc.target(字符串选择器), 交给宏叶子。
$execute as $(by) if data storage zx:work mc{mark:"yuanhai",src:"skill"} if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["tide_buckle"]}] run function sweetdream:equipment/tool/tide_buckle/pull with storage zx:work mc

# ③ 烛跬(靴子): 技能消耗「夜火」-> 回 18 魔力; 消耗「流火」-> 回 8 魔力
$execute as $(by) if data storage zx:work mc{mark:"yehuo",src:"skill"} if items entity @s armor.feet *[minecraft:custom_data~{zx:["candle_step"]}] run function sweetdream:equipment/armor/candle_step/consume
$execute as $(by) if data storage zx:work mc{mark:"liuhuo",src:"skill"} if items entity @s armor.feet *[minecraft:custom_data~{zx:["candle_step"]}] run function sweetdream:equipment/armor/candle_step/consume

# ④ 杂纹(护腿, 2026-10-17 批 15-7): 记录"这一轮消费过哪几种状态", 满 3 种兑现
#    【文案(lore 逐字)】"从自身第一次成功消费状态标签开始，记录接下来 8 秒内消费过的
#      不同种类：流火、夜火、噬心、渊海、白昼梦。同一种类只计一次。累计消耗 3 种后，
#      清空记录，立即恢复 20 点魔力值……"
#    ★ 这一件**不按 src 过滤**：文案写的是"消费状态标签", 没有限定"技能消耗",
#      所以 技能消耗 / 装备被动顺手消耗(归息・殓丝・失血) 都算。
#    ★ 传的是整份 mc（含 mark）—— consume 是宏叶子, 要拼 zx.mv.$(mark) 标签名。
$execute as $(by) if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"]}] run function sweetdream:equipment/armor/mottle_vein/consume with storage zx:work mc

# ⑤ 回旋(护腿, 2026-10-17 批 14 补技能): 技能消费「渊海」-> 获得「旋步」6 秒
#    【文案(逐字)】"自身技能成功消费一个生物的「渊海」后，为自身获得持续 6 秒的
#      「旋步」。该效果 12 秒内最多触发一次。"
#    ★ src:"skill" —— 文案写的是"自身**技能**成功消费", 装备被动顺手消耗不算。
$execute as $(by) if data storage zx:work mc{mark:"yuanhai",src:"skill"} if items entity @s armor.legs *[minecraft:custom_data~{zx:["gyre"]}] run function sweetdream:equipment/armor/gyre/get
