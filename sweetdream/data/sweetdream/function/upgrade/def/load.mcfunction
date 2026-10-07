# ============================================================
# sweetdream:upgrade/def/load —— 升级定义表(由 core/load 调用)
# ------------------------------------------------------------
# 【存在哪】zx:config updef."<升级id>" = {
#     cat:"<类别词>", cat2:"<第二类别词或空>",       —— 能装到哪些类别上
#     dmg/mana/cd,                                  —— 老三样(乘区, 一律累加)
#     mm:"魔力上限", mr:"每秒回魔",                   —— 盔甲向
#     mh:"每次攻击回魔", mhp:"每次攻击回魔(百分比)",  —— 武器向
#     tier:1~3, series:"<同系名字>", req:"<前置升级id>"
#     note:".." }
#
# 【类别词】就用 custom_data.zx 里那个词:
#   sword / axe / bow / staff / helmet / chestplate / leggings / boots
#   外加 "armor" = 任意盔甲(所有盔甲的 zx 里都带这个词, 见 equipment/armor/*/give)
#   想让一条升级同时吃两类就填 cat + cat2(比如"剑、斧"= cat:"sword", cat2:"axe")
#
# 【★ series / tier / req 三件套 = 分级链条 ★】
#   同一 series 里只认**最高 tier 那条**的数值(高阶覆盖低阶, 不是叠加)。
#   例: 盔甲同时有 魔力提升·α(20) 和 β(30) -> 按 β 算: 上限 +30 且每秒 +2。
#   这样每条定义的数值就能"照抄文案", 不用拆成增量。
#   req 是**安装前提**: 敲 β 之前那件装备上必须已经有 α(见 upgrade/api/fit)。
#
# 【数值口径】
#   dmg/mana/cd = 乘区加算(0.1 = +10%, 负数 = 省蓝/减冷却), 全部**累加**
#   mm/mr/mh = 整数(mr 是每秒几点) / mhp = 百分数(1.5 = 最大魔力的 1.5%)
#
# 【怎么加新升级】照抄一行改 id 和数字; 还要配三件套(物品/进度/敲入函数), 见
#   upgrade/item/<id>.mcfunction 与 advancement/upgrade/<id>.json。
# ============================================================

# ---- 老三条(补齐新字段保持结构一致; series 各自独立, 所以互不覆盖) ----
data modify storage zx:config updef."sharp" set value {label:"锐利",cat:"sword",cat2:"",dmg:0.10,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,tier:1,series:"sharp",req:"",note:"伤害 +10%"}
data modify storage zx:config updef."efficiency" set value {label:"高效",cat:"sword",cat2:"",dmg:0.0,mana:-0.10,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,tier:1,series:"efficiency",req:"",note:"魔力消耗 -10%"}
data modify storage zx:config updef."swift" set value {label:"迅捷",cat:"sword",cat2:"",dmg:0.0,mana:0.0,cd:-0.10,mm:0,mr:0,mh:0,mhp:0.0,tier:1,series:"swift",req:"",note:"冷却 -10%"}

# ---- 魔力提升(盔甲) α -> β -> Ω: 上限递增, 高阶额外带每秒回魔 ----
data modify storage zx:config updef."mana_up_a" set value {label:"魔力提升·α",cat:"armor",cat2:"",dmg:0.0,mana:0.0,cd:0.0,mm:20,mr:0,mh:0,mhp:0.0,tier:1,series:"mana_up",req:"",note:"魔力上限 +20"}
data modify storage zx:config updef."mana_up_b" set value {label:"魔力提升·β",cat:"armor",cat2:"",dmg:0.0,mana:0.0,cd:0.0,mm:30,mr:2,mh:0,mhp:0.0,tier:2,series:"mana_up",req:"mana_up_a",note:"魔力上限 +30, 每秒 +2"}
data modify storage zx:config updef."mana_up_o" set value {label:"魔力提升·Ω",cat:"armor",cat2:"",dmg:0.0,mana:0.0,cd:0.0,mm:40,mr:5,mh:0,mhp:0.0,tier:3,series:"mana_up",req:"mana_up_b",note:"魔力上限 +40, 每秒 +5"}

# ---- 魔力增殖(剑 / 斧) α -> β -> Ω: 攻击回魔, 最高级改成百分比 ----
data modify storage zx:config updef."mana_gain_a" set value {label:"魔力增殖·α",cat:"sword",cat2:"axe",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:5,mhp:0.0,tier:1,series:"mana_gain",req:"",note:"每次攻击回 5 魔力"}
data modify storage zx:config updef."mana_gain_b" set value {label:"魔力增殖·β",cat:"sword",cat2:"axe",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:9,mhp:0.0,tier:2,series:"mana_gain",req:"mana_gain_a",note:"每次攻击回 9 魔力"}
data modify storage zx:config updef."mana_gain_o" set value {label:"魔力增殖·Ω",cat:"sword",cat2:"axe",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:1.5,tier:3,series:"mana_gain",req:"mana_gain_b",note:"每次攻击回 1.5% 最大魔力"}

# ============================================================
# ---- 四系新升级石(2026-10-07 实装: 物品/进度/敲入三件套此前已发, 只缺定义+效果) ----
# ------------------------------------------------------------
# 【新增字段(之前只有老三样 + mm/mr/mh/mhp)】
#   ar / at / hp : 护甲值 / 护甲韧性 / 最大生命值(整数) —— 盔甲向, 由 upgrade/armor_apply
#                  账本式落到面板与原版属性上(和已有的 mm/mr 同一条流水线)
#   cdex         : 0/1, 1 = "冷却超过 30 秒的技能每秒额外 -1 秒"(冷却剂·Ω 独有)
#   ms           : {pct, every} 魔力沸涌: 魔力低于 pct% 时, 每 every 秒把技能冷却 -1 秒
#                  (整条按"同系取最高 tier"生效, 不叠乘)
# 【★ 三/四类别 ★】冷却剂吃 剑/斧/法杖、愿景吃 剑/斧/弓/法杖 —— cat~cat4 是一条 OR,
#   见 upgrade/api/fit 与 station/api/apply(cat3/cat4 缺失时自动补空串)。
# 【★ dmg 口径 ★】dmg 是**技能伤害**加算(由 lib/skill_mul 那条 damage_calc 链路上的
#   upgrade/api/dmg_held 折进加算池)。愿景就是靠它。
#   副作用(有意为之): 老石头"锐利 +10%"的 dmg 也从此真正生效了 —— 它的文案本来就是
#   "伤害 +10%", 之前一直没接线(设计文档 §7 记的欠账)。
# ============================================================

# ---- 冷却剂(剑 / 斧 / 法杖) α -> β -> Ω: 主动技能冷却 -5/10/20% ----
data modify storage zx:config updef."coolant_a" set value {label:"冷却剂·α",cat:"sword",cat2:"axe",cat3:"staff",cat4:"",dmg:0.0,mana:0.0,cd:-0.05,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,tier:1,series:"coolant",req:"",note:"冷却 -5%"}
data modify storage zx:config updef."coolant_b" set value {label:"冷却剂·β",cat:"sword",cat2:"axe",cat3:"staff",cat4:"",dmg:0.0,mana:0.0,cd:-0.10,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,tier:2,series:"coolant",req:"coolant_a",note:"冷却 -10%"}
data modify storage zx:config updef."coolant_o" set value {label:"冷却剂·Ω",cat:"sword",cat2:"axe",cat3:"staff",cat4:"",dmg:0.0,mana:0.0,cd:-0.20,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:1,tier:3,series:"coolant",req:"coolant_b",note:"冷却 -20%, 冷却总时长高于 30 秒的技能每秒额外 -1 秒"}

# ---- 硬化(盔甲) α -> β -> Ω: 护甲 +2 / +4&韧性+1 / +6&韧性+3&生命+3 ----
data modify storage zx:config updef."harden_a" set value {label:"硬化·α",cat:"armor",cat2:"",cat3:"",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:2,at:0,hp:0,cdex:0,tier:1,series:"harden",req:"",note:"护甲 +2"}
data modify storage zx:config updef."harden_b" set value {label:"硬化·β",cat:"armor",cat2:"",cat3:"",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:4,at:1,hp:0,cdex:0,tier:2,series:"harden",req:"harden_a",note:"护甲 +4, 韧性 +1"}
data modify storage zx:config updef."harden_o" set value {label:"硬化·Ω",cat:"armor",cat2:"",cat3:"",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:6,at:3,hp:3,cdex:0,tier:3,series:"harden",req:"harden_b",note:"护甲 +6, 韧性 +3, 生命 +3"}

# ---- 魔力沸涌(剑 / 斧 / 法杖) α -> β -> Ω: 低魔力时技能冷却加速 ----
data modify storage zx:config updef."mana_surge_a" set value {label:"魔力沸涌·α",cat:"sword",cat2:"axe",cat3:"staff",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,ms:{pct:20,every:3},tier:1,series:"mana_surge",req:"",note:"魔力<20% 时每 3 秒 -1 秒冷却"}
data modify storage zx:config updef."mana_surge_b" set value {label:"魔力沸涌·β",cat:"sword",cat2:"axe",cat3:"staff",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,ms:{pct:30,every:2},tier:2,series:"mana_surge",req:"mana_surge_a",note:"魔力<30% 时每 2 秒 -1 秒冷却"}
data modify storage zx:config updef."mana_surge_o" set value {label:"魔力沸涌·Ω",cat:"sword",cat2:"axe",cat3:"staff",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,ms:{pct:50,every:2},tier:3,series:"mana_surge",req:"mana_surge_b",note:"魔力<50% 时每 2 秒 -1 秒冷却"}

# ---- 愿景(剑 / 斧 / 弓 / 法杖) α -> β -> Ω: 技能伤害 +10/20/30% ----
data modify storage zx:config updef."vision_a" set value {label:"愿景·α",cat:"sword",cat2:"axe",cat3:"bow",cat4:"staff",dmg:0.10,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,tier:1,series:"vision",req:"",note:"技能伤害 +10%"}
data modify storage zx:config updef."vision_b" set value {label:"愿景·β",cat:"sword",cat2:"axe",cat3:"bow",cat4:"staff",dmg:0.20,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,tier:2,series:"vision",req:"vision_a",note:"技能伤害 +20%"}
data modify storage zx:config updef."vision_o" set value {label:"愿景·Ω",cat:"sword",cat2:"axe",cat3:"bow",cat4:"staff",dmg:0.30,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,tier:3,series:"vision",req:"vision_b",note:"技能伤害 +30%"}

# ============================================================
# ---- 最后一批升级石(2026-10-08 实装): 火炬 / 沸腾 / 夜视仪 / 生命提升 ----
# ------------------------------------------------------------
# 【新增字段】这四个是"效果开关", 不是数值 —— 填 1 就是"装了这条就开这个效果"。
#   tc  : 火炬   —— 攻击到带「流火」的目标时, 10% 把它转成「夜火」
#   boil: 沸腾   —— 攻击到"同时在冻结 + 燃烧"的目标时, 追加 最大魔力 ×0.05 真实伤害
#   nv  : 夜视仪 —— 头盔上装了就常驻夜视(每 12 秒续一次, 每秒续会刷屏)
#   rg  : 再生   —— 生命提升·Ω 附带: 常态再生Ⅰ(同样是每 12 秒续)
# 【★ 开关也要走 bonus_take 的分桶 ★】虽然同系只有一条(tier 1), 但桶里"减旧加新"
#   之后就只剩当前生效那条 —— 逻辑和数值字段一模一样, 不加进去就读不到(r.tc 恒 0)。
# 【★ 夜视仪的 cat 是 "helmet" 不是 "armor" ★】所有盔甲的 zx 里都带自己的槽位词
#   (head 类装备带 "helmet", 见 equipment/armor/*/give), 填 helmet 才能"只装头盔"。
# 【★ 生命提升的 hp 字段已有落地 ★】ar/at/hp 那条账本(硬化石用的)直接就能用,
#   所以 α/β/Ω = hp:2/6/10 写完就生效, 不用另写一份落地。
# ============================================================

# ---- 火炬(剑 / 斧): 流火 -> 夜火, 10% ----
data modify storage zx:config updef."torch" set value {label:"火炬",cat:"sword",cat2:"axe",cat3:"",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,tc:1,boil:0,nv:0,rg:0,ms:{pct:0,every:0},tier:1,series:"torch",req:"",note:"攻击带「流火」的目标时, 10% 转为「夜火」"}

# ---- 沸腾(剑 / 斧): 冻结 + 燃烧 同时成立 -> 最大魔力 ×0.05 真实伤害 ----
data modify storage zx:config updef."boil" set value {label:"沸腾",cat:"sword",cat2:"axe",cat3:"",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,tc:0,boil:1,nv:0,rg:0,ms:{pct:0,every:0},tier:1,series:"boil",req:"",note:"攻击同时冻结+燃烧的目标时追加真实伤害"}

# ---- 夜视仪(头盔): 常驻夜视 ----
data modify storage zx:config updef."night_vision" set value {label:"夜视仪",cat:"helmet",cat2:"",cat3:"",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:0,cdex:0,tc:0,boil:0,nv:1,rg:0,ms:{pct:0,every:0},tier:1,series:"night_vision",req:"",note:"常驻夜视"}

# ---- 生命提升(盔甲) α -> β -> Ω: 最大生命 +2 / +6 / +10(Ω 附带常态再生Ⅰ) ----
data modify storage zx:config updef."life_up_a" set value {label:"生命提升·α",cat:"armor",cat2:"",cat3:"",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:2,cdex:0,tc:0,boil:0,nv:0,rg:0,ms:{pct:0,every:0},tier:1,series:"life_up",req:"",note:"最大生命值 +2"}
data modify storage zx:config updef."life_up_b" set value {label:"生命提升·β",cat:"armor",cat2:"",cat3:"",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:6,cdex:0,tc:0,boil:0,nv:0,rg:0,ms:{pct:0,every:0},tier:2,series:"life_up",req:"life_up_a",note:"最大生命值 +6"}
data modify storage zx:config updef."life_up_o" set value {label:"生命提升·Ω",cat:"armor",cat2:"",cat3:"",cat4:"",dmg:0.0,mana:0.0,cd:0.0,mm:0,mr:0,mh:0,mhp:0.0,ar:0,at:0,hp:10,cdex:0,tc:0,boil:0,nv:0,rg:1,ms:{pct:0,every:0},tier:3,series:"life_up",req:"life_up_b",note:"最大生命值 +10, 常态再生Ⅰ"}
