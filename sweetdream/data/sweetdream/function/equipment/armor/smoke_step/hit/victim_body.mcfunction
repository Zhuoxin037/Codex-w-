$execute unless entity $(vx_uuid) run return 0

# ④ 它必须**原本**就带「流火」（没烧着的砍了没有收益）
$execute unless data entity $(vx_uuid) {Tags:["zx.status.liuhuo"]} run return 0

# ⑤ 拿 uuid（回复魔力的公共输入口要它）
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ⑥ 回复 10 点魔力值
data modify storage manacore:in arg set value {uuid:"",value:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# ⑦ 获得 2 秒迅捷Ⅰ（amplifier 0 = Ⅰ；每秒不续 —— 文案就是"获得 2 秒"）
effect give @s minecraft:speed 2 0 true

# ⑧ 表现
$execute at $(vx_uuid) run particle minecraft:smoke ~ ~0.6 ~ 0.3 0.4 0.3 0.01 8 normal
execute at @s run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.5 1.6

# ⑨ 记下"下次可触发刻"（现在 + 60 刻 = 3 秒）
scoreboard players operation @s zx.ss_cd = #now manacore.meta
scoreboard players operation @s zx.ss_cd += #60 zx.meta

# ⑩ 收尾
$tag $(vx_uuid) remove zx.victim
