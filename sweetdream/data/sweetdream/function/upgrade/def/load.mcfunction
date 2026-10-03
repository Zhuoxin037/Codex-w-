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
