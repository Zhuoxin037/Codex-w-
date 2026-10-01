# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill —— 击杀后的临时魔力上限(基础 +200)
# ------------------------------------------------------------
# 【文案】自身杀死一个生物后自身临时获得 200 魔力值上限, 持续 8 秒;
#         若杀死的生物有任意一个通用标签, 则额外获得 100 魔力值上限。
# 【两条进度分开记账】这条只管"基础 200"(记在 zx.dd_t1), 带标签的 +100 在
#   kill_mark 里(记在 zx.dd_t2) —— 这样两条进度谁先跑都不会互相覆盖。
#   kill_init 负责"同一次击杀只清一次账", 详见那个文件。
# 【为什么"临时"要记账】加的是面板里的上限, 到点必须减回去:
#   zx.dd_app 记"现在一共加了多少", 到点按差值抵掉(见 temp_off)。
# ============================================================

advancement revoke @s only sweetdream:equipment/armor/dusk_dawn_kill
execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"]}] run return fail

function sweetdream:equipment/armor/dusk_dawn/kill_init
scoreboard players set @s zx.dd_t1 200
scoreboard players set @s zx.dd_temp 8
function sweetdream:equipment/armor/dusk_dawn/temp_apply

# 表现: 一圈暖金色的光(黄昏/黎明)
execute at @s run particle minecraft:dust{color:[1.0,0.78,0.45],scale:1.2} ~ ~1 ~ 1.6 0.8 1.6 0 25 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.6 1.3
