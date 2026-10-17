# ============================================================
# sweetdream:equipment/armor/beach_vein/set_cd —— 潮线: 打渊海目标给主手技能减冷却
# ------------------------------------------------------------
# 【宏参数】zx:work ob {u0..u3}(施法者 UUID 四段)
# 【执行者】被打的那一只（@s = 目标）
# 【文案(lore 逐字)】自身技能伤害命中了附有「渊海」的生物后，若当前主手装备的
#   主动技能正在冷却，则使其冷却时间 -2 秒。该效果 6 秒内最多触发一次。
# 【★ 本件是"潮线"套装的代码宿主(护腿/滩纹), 但判定要**候潮 + 滩纹两件齐** ★】
#   包内约定: 套装代码只放其中一件; 判定用两件各来一次 `items entity @s` 相乘。
#   这里用两条 if 串联(等价于相乘) —— 与 armor_mana 的二件套写法同款。
# 【★ 必须排在"候潮挂渊海"**之前** ★】(见 internal/damage/one 的排列)
#   文案说的是"命中了**附有**渊海的生物" —— 指的是**命中那一刻**它已经带着渊海。
#   若先跑候潮(把渊海挂上去)再判本条, 本次刚挂上的渊海会让套装也一起触发,
#   等于"打谁都减冷却"。所以本段的调用顺序在候潮之上。
# 【"主手主动技能"从哪读】物品自带的 custom_data.skill 字段(冷却就是按它存的)
#   —— 与 debug/cd_clear 同款: 拿着哪把就认哪把, 不用手填技能名。
# 【★ 先 remove 再 get ★】空手/非本包武器时 `data modify … set from` 会**静默失败**,
#   不先清掉会读到上一次的残留 skill(debug/cd_clear 头注释里记过这个坑)。
# ============================================================

# ① 施法者还在线吗
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run return 0

# ② 他穿齐「潮线」两件吗（● 候潮 = 胸甲 / ● 滩纹 = 护腿）
scoreboard players set #tw_on zx.meta 0
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["tide_watch"]}] if items entity @s armor.legs *[minecraft:custom_data~{zx:["beach_vein"]}] run scoreboard players set #tw_on zx.meta 1
execute unless score #tw_on zx.meta matches 1 run return 0

# ③ 6 秒节流（记在施法者身上, 所以要在他的上下文里判）
#    ★ 施法者的记分项只能 `as` 过去读写 —— 本函数执行者是目标。
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run scoreboard players set #tw_due zx.meta 0
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run execute store result score #tw_due zx.meta run scoreboard players get @s zx.tw_set_cd
execute if score #tw_due zx.meta > #now manacore.meta run return 0

# ④ 读他主手那把的 skill 字段（先在玩家上下文里取）
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/armor/beach_vein/read_skill
execute unless data storage zx:work tw.skill run return 0

# ⑤ 那个技能在冷却中吗（剩余 > 0）
data modify storage manacore:in arg set value {uuid:"",skill:""}
data modify storage manacore:in arg.uuid set from storage zx:work tw.uuid
data modify storage manacore:in arg.skill set from storage zx:work tw.skill
function manacore:api/cooldown/get
scoreboard players set #tw_rem zx.meta 0
execute store result score #tw_rem zx.meta run data get storage manacore:out r.remaining
execute if score #tw_rem zx.meta matches ..0 run return 0

# ⑥ 冷却 -2 秒
data modify storage manacore:in arg set value {uuid:"",skill:"",seconds:2.0}
data modify storage manacore:in arg.uuid set from storage zx:work tw.uuid
data modify storage manacore:in arg.skill set from storage zx:work tw.skill
function manacore:api/cooldown/reduce

# ⑦ 表现（在**施法者**身上放, 不是目标）
$execute at @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run particle minecraft:bubble ~ ~1 ~ 0.4 0.5 0.4 0.01 10 normal

# ⑧ 记下"下次可触发刻"（现在 + 120 刻 = 6 秒）, 写在**施法者**的账本上
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run scoreboard players operation @s zx.tw_set_cd = #now manacore.meta
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run scoreboard players operation @s zx.tw_set_cd += #120 zx.meta
