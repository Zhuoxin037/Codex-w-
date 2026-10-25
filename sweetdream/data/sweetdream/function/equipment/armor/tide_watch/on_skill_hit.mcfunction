# ============================================================
# sweetdream:equipment/armor/tide_watch/on_skill_hit —— 候潮: 技能命中给目标点「渊海」
# ------------------------------------------------------------
# 【宏参数】zx:work ob {u0..u3}(施法者 UUID 四段)
# 【执行者】被打的那一只（@s = 目标）
# 【文案(lore 逐字)】自身魔力值上限 +60。自身主动技能命中生物后，若魔力足够，则消耗
#   30 魔力并使其附加「渊海」。该效果 10 秒内最多触发一次，**同次施放最多附加一个目标**。
# 【★ "同次施放最多一个目标" 不用额外计数 ★】本效果 10 秒节流 → 同一次施放里
#   第一次命中就已经把账本推到"现在 + 200 刻"，后续每一个目标判节流都不通过 ⇒
#   天然只挂一只。所以这里**没有**"本次施放已挂过"的额外标记（少一个状态。
# 【★ 排在"潮线套装"**之后** ★】套装判的是"命中时目标**已带**渊海"，
#   见 beach_vein/set_cd 与 internal/damage/one 里的排列说明。
# 【★ 排在 deal **之后** ★】文案是"命中…后"；且附加状态不该回头影响这一击的
#   受击侧乘区(夜火/噬心那两条)。
# 【★ 附加是"附着"不是"消耗" ★】走 tag/mark —— 走 mark_consume 会白给余烬/回潮扣/
#   烛跬那一串被动(刺纹 hit 同款坑)。
# ============================================================

# ① 施法者还在线吗
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 他穿着「候潮」吗（胸甲）
scoreboard players set #tc_on zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] if items entity @s armor.chest *[minecraft:custom_data~{zx:["tide_watch"]}] run scoreboard players set #tc_on zx.meta 1
execute unless score #tc_on zx.meta matches 1 run return 0

# ③ 10 秒节流（账本记在**施法者**身上）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players set #tc_due zx.meta 0
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run execute store result score #tc_due zx.meta run scoreboard players get @s zx.tw_cd
execute if score #tc_due zx.meta > #now manacore.meta run return 0

# ④ 拿施法者的 uuid（扣魔力的公共输入口要它）
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work tc.uuid set from storage zx:data self.uuid

# ⑤ 消耗 30 魔力（够才扣；不够就什么都不做）
data modify storage manacore:in arg set value {uuid:"",value:30.0}
data modify storage manacore:in arg.uuid set from storage zx:work tc.uuid
function sweetdream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# ⑥ 给目标附加「渊海」（附着 -> tag/mark；@s 此刻就是那只目标）
data modify storage zx:work ic set value {target:"@s",mark:"yuanhai"}
function sweetdream:tag/mark with storage zx:work ic

# ⑦ 表现
execute at @s run particle minecraft:nautilus ~ ~0.8 ~ 0.4 0.5 0.4 0.01 10 normal
execute at @s run playsound minecraft:item.bucket.empty player @a ~ ~ ~ 0.5 1.4

# ⑧ 记下"下次可触发刻"（现在 + 200 刻 = 10 秒）, 写在**施法者**的账本上
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players operation @s zx.tw_cd = #now manacore.meta
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run scoreboard players operation @s zx.tw_cd += #200 zx.meta
