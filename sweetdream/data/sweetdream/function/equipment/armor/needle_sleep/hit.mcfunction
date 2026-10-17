# ============================================================
# sweetdream:equipment/armor/needle_sleep/hit —— 针眠: 命中给目标点「噬心」
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/needle_sleep_hit（player_hurt_entity）
# 【执行者】玩家（动手的那个人）
# 【文案(lore 逐字)】自身魔力值上限 +100。自身法杖普攻或攻击命中了未附有「噬心」的
#   生物后，若魔力足够，则消耗 60 魔力并使其附加「噬心」。该效果 10 秒内最多触发一次。
# 【★ "法杖普攻或攻击" 就是同一条进度 ★】本包的法杖普攻也走原版攻击判定
#   (player_hurt_entity + is_player_attack 的伤害类型) —— 和剑/斧的近战命中同一个触发源,
#   不需要另开一条"法杖专用"进度(全包先例: 刺纹 / 燧帽 / 烟履 都只用这一条)。
# 【★ 附加是"附着"不是"消耗" ★】走 tag/mark（不走 mark_consume）。
# 【★ "若魔力足够" 交给 api/mana/consume 判 ★】见燧帽 hit 的同款注释。
# 【★ 本件同时是"缝心"套装「绯结」的积攒来源 ★】附加成功后如果穿齐缝心两件,
#   就顺手积攒 1 层「绯结」—— 积攒逻辑写在 crimson_seam/knit_add, 由这里调用。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/needle_sleep_hit

# ---- 满蓄力闸（全包统一口径：平A 没蓄满力这一发不触发；见 lib/atk_charge 头部） ----
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# ① 没穿针眠就没这事（头盔）
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["needle_sleep"]}] run return 0

# ② 10 秒节流（账本存"下次可触发刻"）
scoreboard players set #ns_due zx.meta 0
execute store result score #ns_due zx.meta run scoreboard players get @s zx.ns_cd
execute if score #ns_due zx.meta > #now manacore.meta run return 0

# ③ 定位命中的那一只
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,distance=0..,limit=1] run return 0

# ④ 它必须**未**带「噬心」
execute as @e[tag=zx.victim,distance=0..,limit=1] if entity @s[tag=zx.status.shixin] run return 0

# ⑤ 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ⑥ 消耗 60 魔力（够才扣）
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute unless data storage manacore:out r{success:1b} run return 0

# ⑦ 给它附加「噬心」（附着 -> tag/mark）
data modify storage zx:work ic set value {target:"@e[tag=zx.victim,limit=1]",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

# ⑧ ★ 缝心套装: 为"原本未带噬心"的生物成功附加后, 积攒 1 层「绯结」 ★
#   文案(套装段): "自身为原本未附有「噬心」的生物成功附加噬心后，积攒 1 层「绯结」
#   （最多 3 层，6 秒内最多积攒一次）。"
#   ★ 上一句 ④ 已经保证"原本未带" ⇒ 这里就是套装要的那个时机。
#   ★ 积攒与"是否消耗魔力成功"无关吗? 不是 —— 文案要求的是"成功附加噬心",
#     而附加发生在扣蓝成功之后, 所以排在 ⑥⑦ 之后正是"成功附加"成立的那一刻。
function sweetdream:equipment/armor/crimson_seam/knit_add

# ⑨ 表现
execute at @e[tag=zx.victim,limit=1] run particle minecraft:item{item:{id:"minecraft:amethyst_shard",count:1}} ~ ~0.8 ~ 0.3 0.4 0.3 0.02 6 normal
execute at @s run playsound minecraft:block.trial_spawner.place player @a ~ ~ ~ 0.5 1.5

# ⑩ 记下"下次可触发刻"（现在 + 200 刻 = 10 秒）
scoreboard players operation @s zx.ns_cd = #now manacore.meta
scoreboard players operation @s zx.ns_cd += #200 zx.meta

# ⑪ 收尾
tag @e[tag=zx.victim] remove zx.victim
