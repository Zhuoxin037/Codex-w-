# ============================================================
# sweetdream:lib/skill_mul/scan —— 算"在身装备给三条技能倍率通道各加了多少"
# ------------------------------------------------------------
# 【执行者】玩家本人   【读】主手物品 + 超限数据表
# 【出参】zx:work pl 上三个 double(直接给 debug/stats 当"倍率"显示):
#     smul_mm  = 最大魔力值技能倍率  (1.25 = ×1.25)
#     smul_atk = 基础攻击力倍率
#     smul_oth = 其他倍率
#   没加成 = 1.0。**技能自身那条基率不算进来** —— 这里只算"装备乘区"。
#   ★ 例外: 口径是**独立乘区**的装备加成(愠怒)折 pl.independent_multiplier ——
#     面板上那是「伤害参数」节里独立的一行, 不是这三条通道倍率。
#   ⚠️ smul_mm 额外折进了「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸套装 /
#      无效), 见 ②¾¾¾ 与 lib/mm_add/scan_mul —— 它此刻就是真实生效的乘区。
#
# 【★ "加算类"装备加成怎么进这三条 ★(2026-10-06 重做)】
#   共振 / 漫步冥河 / 炽天使之翼 都是**加算**, 走同一条流水线:
#     ②¼ lib/dmg_add_clear   清空加算池 zx:work add {mm,atk,oth}
#     ②½~②¾¾ 各 scan_mul    只往池子里**写自己那份百分比**(不再各自乘 smul_*)
#     ②⅞ lib/skill_mul/padd_apply  统一乘一次: smul_<c> ×(1 + Σ池子)
#   为什么不能各自乘: 那是乘法(独立乘区)的算术, 共振×漫步 会得到 ×1.43,
#   而实伤是 ×1.40 —— 面板就变成"说假话"了。
#   伤害侧是同一套: lib/dmg_add_clear -> hook 写池子 -> lib/dmg_add_apply 统一乘。
#
# 【★ 为什么只算超限, 不算升级 dmg ★】
#   面板的第一原则是"显示的必须是真实生效的"(否则就是永久误报, 2026-10-03 栽过)。
#   现在真正乘进技能倍率通道的装备乘区只有**超限伤害**(overlimit/api/mod, 按通道分流)。
#   升级定义表里的 dmg(锐利 +10%)目前既没有实物材料、也没接到任何武器的伤害上
#   —— 显示它会是一句假话, 所以这里不算。等哪天把升级 dmg 接进伤害, 记得回来补。
#
# 【口径从哪来】lib/skill_mul/def 的表(只影响显示; 结算以技能文件里写的通道为准)。
# 【拆成四个文件】
#   · scan(本文件) —— 只做"默认值 + 判断要不要算装备乘区"的主干,
#     ★ 里面**一个 return 都不能有** ★(一 return 就跳过后面那些 scan_mul)。
#   · gear      —— 装备乘区(主手武器 + 超限), 允许提前 return。
#   · apply     —— 按口径表写通道(全行带 $ 的宏)。
#   · mm_add/scan_mul —— 折「最大魔力值技能倍率」通用加成(风声/忘川彼岸/无效)。
#   表要用 $(id) 当宏路径 -> 必须有 $ 前缀的宏函数; 而主干要跑非宏逻辑,
#   混在一个文件里会让"带 $ 的行"和"不带的"互相牵连(一行解析不了整个函数作废)。
# ============================================================

# ① 默认 ×1.0
data modify storage zx:work pl.smul_mm set value 1.0
data modify storage zx:work pl.smul_atk set value 1.0
data modify storage zx:work pl.smul_oth set value 1.0

# ② "装备乘区"那一段(看主手武器 + 超限)挪进了 lib/skill_mul/gear ——
#    ★ 本文件里**绝对不能出现 return** ★
#    那段里有两处"拿不到就收工"的提前 return, 而下面 ③ 折的风声是**玩家身上的
#    buff**(换不换武器、敲没敲超限都还在)。以前 return 写在本文件里, 于是没敲超限
#    时连风声一起被跳过 -> 放完风行技能, 面板还是 ×1(2026-10-04 用户实际反馈)。
data remove storage zx:work sm
scoreboard players set #sm_n zx.meta 0
execute store result score #sm_n zx.meta run data get entity @s SelectedItem.components."minecraft:custom_data".zx
execute if score #sm_n zx.meta matches 1.. run function sweetdream:lib/skill_mul/gear

# ②¼ 清空"加算池"(zx:work add)。
#    ★ 从下面 ②½ 到 ②¾¾ 的几条 scan_mul **只往池子里写百分比**(不再各自乘 smul_*),
#      最后由 ②⅞ 的 padd_apply 统一乘一次 —— 这才是"加算"(先合并再乘),
#      否则共振 +10%/阵 与漫步 +30% 会被算成 ×1.1×1.3 = ×1.43(实伤是 ×1.40)。
#    ★ 必须排在所有 scan_mul **之前**, 别和伤害侧那份弄混:
#      两处用的是同一个节点, 但各自"先清再填再用", 不会互相看见对方的值。
function sweetdream:lib/dmg_add_clear

# ②½ 共振: 穿上时每个术阵给三条技能倍率通道各 +(10%)。结算在 hook_calc 里做
#    (挂在 damage_calc 事件, 往加算池写 10n), 这里只负责把 10n 写进池子让
#    "面板现形" —— 否则玩家看不到吃到了多少, 会以为没生效(2026-10-05 用户反馈)。
#    #res_pct 默认 100(= ×1, 表示没加), 由 scan_mul 在生效时改成实际倍率 ×100,
#    stats 用它决定是否显示"共振生效"灰字。
scoreboard players set #res_pct zx.meta 100
execute if items entity @s armor.chest *[minecraft:custom_data~{zx:["resonance"]}] run function sweetdream:equipment/armor/resonance/scan_mul

# ②¾ 漫步冥河之上: 站在"暗海"内时, 以最大魔力值结算的技能伤害 +30%。
#    结算在 styx_walk/hook_calc(挂 damage_calc, 往加算池的 mm 通道写 30)。
#    这里同样只往池子写 30 让"面板现形" —— 判据(戴头盔 + 3 格内有暗海)
#    必须和 hook_calc 逐字一致, 否则面板的数字就是假的。
#    只写 mm: 文案限定"关于最大魔力值的技能"(见 styx_walk/scan_mul 头注释)。
#    (2026-10-06 用户反馈: 在暗海内看 stats 看不到这一项提升)
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["styx_walk"]}] run function sweetdream:equipment/armor/styx_walk/scan_mul

# ②¾½ 炽天使之翼(副手): 有关**基础攻击力**的技能伤害 +50%。
#    结算在 seraph_wing/hook_calc(挂 damage_calc, 往加算池的 atk 通道写 50;
#    没用 atk 通道的技能 seg_atk = 0 ⇒ 自动吃不到)。这里同样只往池子写 50。
#    判据(副手拿着)必须和 hook_calc 逐字一致, 否则面板的数字就是假的。
#    ★ 全包第一条"按通道区分"的装备加成 —— 详见 seraph_wing/hook_calc 头注释。
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["seraph_wing"]}] run function sweetdream:equipment/tool/seraph_wing/scan_mul

# ②¾¾ 愠怒(副手): 血量 < 20% 时, 有关**最大魔力值**的技能伤害 +20%**独立乘区**。
#    结算在 wrath/hook_calc —— 判"本次技能走不走 mm 通道", 走则**整体**乘最终 r.damage
#    (这才是"独立乘区": 乘在三条通道求和**之后**; 不是并进 mm 通道做加算)。
#    面板因此折的是 **pl.independent_multiplier**("独立乘区"那一行), **不是** smul_mm
#    —— 折错行会让面板把独立乘区说成"通道 +20%"(2026-10-06 用户反馈修正)。
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["wrath"]}] run function sweetdream:equipment/tool/wrath/scan_mul

# ②¾¾½ 苍蓝星(斧): 攒着「被动翻倍」时, 把 +100% 写进加算池的 mm 通道。
#   结算在 azure_star/recalc —— 那里把 manacore:in arg.max_mana_mul ×2(见 double),
#   然后**当场清掉** zx.as_x2("增加至技能倍率上, 而使用后消除", 玩家 2026-10-07 定)。
#   这里只负责让面板现形(玩家同款要求: "我希望翻倍后可以在观测镜上显示出来" ——
#   观测镜第二行是 layer 表的「翻倍」段, 这里是 stats 的"最大魔力值技能倍率"那一行)。
#   判据(手里是苍蓝星 + zx.as_x2=1)必须和 recalc 一致, 否则面板又是"说假话"。
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["azure_star"]}] run function sweetdream:equipment/axe/azure_star/scan_mul
execute unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["azure_star"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["azure_star"]}] run function sweetdream:equipment/axe/azure_star/scan_mul

# ②¾¾¾ 「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸套装 / 无效)
#    2026-10-07 用户定稿: 原来那套"攒着、只给下一次最大魔力值技能吃一次"的
#    wg_bonus 槽位整体去掉了, 加成现在直接算进这条通用乘区 ——
#    所以它和共振/漫步/炽天使一样, 只是**往加算池的 mm 通道写一份百分比**。
#    判据(玩家身上的 zx.mm_add > 0)必须和 lib/mm_add/hook_calc 一致,
#    否则面板又会"说假话"。
function sweetdream:lib/mm_add/scan_mul

# ②⅞ 把加算池统一折进三条通道倍率(加算 = 先合并再乘一次; 见 padd_apply 头注释)
#    ★ 必须排在 ②½~②¾¾¾ **全部之后**(否则后写的还没进池子)。
#    ★ 顺序上它是最后一步 —— 以前后面还有 ③(折"待生效的风声加成"), 那个整段删掉了。
function sweetdream:lib/skill_mul/pending
function sweetdream:profession/panel_add
function sweetdream:lib/skill_mul/padd_apply
function sweetdream:lib/skill_mul/independent

function sweetdream:profession/panel
