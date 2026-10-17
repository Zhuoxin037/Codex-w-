# ============================================================
# sweetdream:equipment/armor/backlight/on_cast —— 返照 ·「回照」兑现
# ------------------------------------------------------------
# 【谁调用它】#manacore:event/cooldown_start
#   ★ 时机正好：前置包 internal/cooldown/start_go 在**写完冷却之后**才抛这个事件，
#     所以这里对同一个 skill 再 reduce 160 刻是有效的（end 已存在，往前推）。
#   ★ 而 mana 在更早的 stage_mana 就扣过了，且 internal/skill/go 是用
#     `with storage manacore:work a` 调的 —— 事件链上 macore:work a 仍是
#     **本次技能参数**，所以 `a.mana` 就是"该次实际消耗的魔力"。
# 【技能原文】"自身下一次主动技能成功施放后，返还该次实际消耗魔力的 25%，
#   并使该技能冷却时间 -8 秒，之后清除「回照」。"
# 【★ 顺序铁律 ★】
#   ① `a.mana` 必须在**任何会写 manacore:work a 的调用之前**读出来
#      （lib/uuid → api/player/self_uuid 就会写 a.i / a.uuid）；
#   ② lib/in_bak 备份的是 `manacore:in arg`，而 api/mana/add 与
#      api/cooldown/reduce **都读 in arg** ⇒ in_restore 必须放在两者之后。
# 【★ 只对"下一次主动技能"生效 ★】兑现即清 zx.bk_wd，所以不会连着吃两个技能。
# ============================================================

# ⓪ 不是玩家（理论到不了这）→ 收工
execute unless entity @s[type=minecraft:player] run return 0

# ① 穿着门控（头盔）
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["backlight"]}] run return 0

# ② 没有「回照」（含已过期）→ 收工
execute if score @s zx.bk_wd < #now manacore.meta run return 0

# ③ 读本次实际消耗魔力（×1000）—— 必须排在 lib/uuid 前面
#    ★ 先复位：#bk_mana 是全局假玩家，`data get` 取不到字段时 store result **不写入**，
#      留着上一次的值就会被当成"本次消耗"返还好几倍（静默、且只会多给）。
scoreboard players set #bk_mana zx.meta 0
execute store result score #bk_mana zx.meta run data get storage manacore:work a.mana 1000

# ④ 兑现即清除「回照」
scoreboard players set @s zx.bk_wd 0

# ⑤ ★★ 整份备份技能参数 ★★
#   api/mana/add 与 api/cooldown/reduce 都会 `data modify storage manacore:work a set value {...}`
#   **整份重置**它；而 internal/skill/go 在本事件之后还有一步 `damage/calc with storage manacore:work a`
#   —— 不还原的话，穿返照且有回照时那一次技能会**算不出伤害**（只扣蓝、不打人），
#   而且不报错。这是"事件钩子插在技能链中段"最容易踩的坑。
#   ★ 用 zx:work 的独立键（别用 zx:work a：那是全包共用临时节点）。
data modify storage zx:work bkarg set from storage manacore:work a

# ⑥ 备份公共输入口 + 取自己的 uuid
function sweetdream:lib/in_bak
function sweetdream:lib/uuid

# ⑥ 返还 25%（#bk_mana 是 ×1000；÷4 即 25%，转 double 时再 ÷1000）
scoreboard players set #bk_n4 zx.meta 4
scoreboard players operation #bk_ret zx.meta = #bk_mana zx.meta
scoreboard players operation #bk_ret zx.meta /= #bk_n4 zx.meta
data modify storage manacore:in arg set value {uuid:"",value:0.0}
execute if data storage zx:data self.uuid run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #bk_ret zx.meta
execute if score #bk_ret zx.meta matches 1.. run function manacore:api/mana/add

# ⑦ 本次技能冷却 -8 秒（160 刻）
data modify storage zx:work bk set value {uuid:"",skill:"",ticks:160}
execute if data storage zx:data self.uuid run data modify storage zx:work bk.uuid set from storage zx:data self.uuid
execute if data storage manacore:ctx skill run data modify storage zx:work bk.skill set from storage manacore:ctx skill
execute if data storage zx:work bk.skill unless data storage zx:work bk{skill:""} run function sweetdream:equipment/armor/backlight/cd_go with storage zx:work bk

# ⑧ 还原公共输入口（放在两个 api 调用之后 —— 它们都读 in arg）
function sweetdream:lib/in_restore

# ⑧-b 还原技能参数（见 ⑤ 的说明）
data modify storage manacore:work a set from storage zx:work bkarg
data remove storage zx:work bkarg

# ⑨ 表现：身上泛起一层暖白的光
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.4 0.5 0.4 0.03 16 normal
execute at @s run particle minecraft:dust{color:[1.0,0.9,0.6],scale:1.6} ~ ~1 ~ 0.35 0.4 0.35 0.02 10 normal
execute at @s run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.9 1.2
