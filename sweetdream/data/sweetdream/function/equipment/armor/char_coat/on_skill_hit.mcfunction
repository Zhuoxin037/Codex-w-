# ============================================================
# sweetdream:equipment/armor/char_coat/on_skill_hit —— 焦衣: 把目标的「流火」升级成「夜火」
# ------------------------------------------------------------
# 【宏参数】zx:work ob {u0..u3}(施法者 UUID 四段)
# 【执行者】被打的那一只（@s = 目标）
# 【文案(lore 逐字)】自身魔力值上限 +130。自身主动技能的**普通伤害**命中了附有
#   「流火」而未附有「夜火」的生物后，若魔力足够，则消耗 80 魔力，将其「流火」
#   转化为「夜火」。该效果 10 秒内最多触发一次。
# 【★ 排在 deal **之后** ★】两个理由:
#   ① 文案是"命中了…后";
#   ② 更要紧 —— 「夜火」的受击侧效果是"受到**技能伤害** +15%"(见 internal/damage/
#      vuln_tag)。若在 deal 之前就把流火升级成夜火, 这一击会**当场**多吃那 15%,
#      而文案明确是"**之后**转化"。所以必须等这一击结算完再转。
# 【★ "转化" ≠ "消耗" ★】流火不是被"消费掉"的, 而是**变**成了夜火 ⇒
#   摘模板走 tag/unmark(**不是** lib/mark_consume)。走消耗入口会白给
#   余烬/回潮扣/烛跬那一串"消耗触发"的被动(等于凭空多一份收益)。
#   代价: 本转化**不会**触发自家烛跬的"消费流火回 8 魔力"(它是转化, 不是消费) ——
#   与文案口径一致。
# 【★ 顺序: 先摘流火、再挂夜火 ★】反过来的话, 目标会短暂同时带两个,
#   ttl 与图标也会多刷一次。
# ============================================================

# ① 施法者还在线吗
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run return 0

# ② 他穿着「焦衣」吗（胸甲）
scoreboard players set #cc_on zx.meta 0
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["char_coat"]}] run scoreboard players set #cc_on zx.meta 1
execute unless score #cc_on zx.meta matches 1 run return 0

# ③ 目标仍要满足"带流火 + 未带夜火"（one 里已判过一次，这里复判 —— 本件要能独立测，
#    也不能被别处误调）
execute unless entity @s[tag=zx.status.liuhuo,tag=!zx.status.yehuo] run return 0

# ④ 10 秒节流（账本记在**施法者**身上）
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run scoreboard players set #cc_due zx.meta 0
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run execute store result score #cc_due zx.meta run scoreboard players get @s zx.cc_cd
execute if score #cc_due zx.meta > #now manacore.meta run return 0

# ⑤ 拿施法者的 uuid（扣魔力的公共输入口要它）
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work cc.uuid set from storage zx:data self.uuid

# ⑥ 消耗 80 魔力（够才扣）
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:work cc.uuid
function manacore:api/mana/consume
execute unless data storage manacore:out r{success:1b} run return 0

# ⑦ 转化：先摘「流火」，再挂「夜火」
#    摘模板会顺手撤掉流火那条"护甲 -20%"的修饰符与它的剩余秒数(见 tag/unmark_one)。
data modify storage zx:work cc set value {target:"@s",mark:"liuhuo"}
function sweetdream:tag/unmark with storage zx:work cc
data modify storage zx:work ic set value {target:"@s",mark:"yehuo"}
function sweetdream:tag/mark with storage zx:work ic

# ⑧ 表现
execute at @s run particle minecraft:soul_fire_flame ~ ~0.8 ~ 0.4 0.5 0.4 0.01 12 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.6 1.1

# ⑨ 记下"下次可触发刻"（现在 + 200 刻 = 10 秒）
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run scoreboard players operation @s zx.cc_cd = #now manacore.meta
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run scoreboard players operation @s zx.cc_cd += #200 zx.meta
