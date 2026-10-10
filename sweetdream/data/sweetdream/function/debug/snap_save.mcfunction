# ============================================================
# sweetdream:debug/snap_save —— 把当前所有要盯的值存成快照(宏参数 {uuid})
# ------------------------------------------------------------
# 【这个文件是生成的】改动看 .workbuddy/gen_diff.py, 然后跑
#   python .workbuddy/gen_diff.py
# 【它只写 zx:data snap."<uuid>", 不碰面板】随便按。
# 【为什么先 scoreboard players add ... 0】计分板里"没这个玩家的分"和
#   "分是 0"是两种状态, 直接 store 会失败并往日志里刷错。先 add 0 把它建出来。
# ============================================================

$data modify storage zx:data snap."$(uuid)" set value {}
scoreboard players add @s zx.pump_mana 0
$execute store result storage zx:data snap."$(uuid)".o0 int 1 run scoreboard players get @s zx.pump_mana
scoreboard players add @s zx.set_mana 0
$execute store result storage zx:data snap."$(uuid)".o1 int 1 run scoreboard players get @s zx.set_mana
scoreboard players add @s zx.set_hp 0
$execute store result storage zx:data snap."$(uuid)".o2 int 1 run scoreboard players get @s zx.set_hp
scoreboard players add @s zx.regen_last 0
$execute store result storage zx:data snap."$(uuid)".o3 int 1 run scoreboard players get @s zx.regen_last
scoreboard players add @s zx.power_hp 0
$execute store result storage zx:data snap."$(uuid)".o4 int 1 run scoreboard players get @s zx.power_hp
scoreboard players add @s zx.dio_mana 0
$execute store result storage zx:data snap."$(uuid)".o5 int 1 run scoreboard players get @s zx.dio_mana
scoreboard players add @s zx.dio_regen 0
$execute store result storage zx:data snap."$(uuid)".o6 int 1 run scoreboard players get @s zx.dio_regen
scoreboard players add @s zx.bl_mana 0
$execute store result storage zx:data snap."$(uuid)".o7 int 1 run scoreboard players get @s zx.bl_mana
scoreboard players add @s zx.bl_atk 0
$execute store result storage zx:data snap."$(uuid)".o8 int 1 run scoreboard players get @s zx.bl_atk
scoreboard players add @s zx.bl_regen 0
$execute store result storage zx:data snap."$(uuid)".o9 int 1 run scoreboard players get @s zx.bl_regen
scoreboard players add @s zx.ss_mana 0
$execute store result storage zx:data snap."$(uuid)".o10 int 1 run scoreboard players get @s zx.ss_mana
scoreboard players add @s zx.ss_hp 0
$execute store result storage zx:data snap."$(uuid)".o11 int 1 run scoreboard players get @s zx.ss_hp
scoreboard players add @s zx.ss_armor 0
$execute store result storage zx:data snap."$(uuid)".o12 int 1 run scoreboard players get @s zx.ss_armor
scoreboard players add @s zx.se_mana 0
$execute store result storage zx:data snap."$(uuid)".o13 int 1 run scoreboard players get @s zx.se_mana
scoreboard players add @s zx.se_regen 0
$execute store result storage zx:data snap."$(uuid)".o14 int 1 run scoreboard players get @s zx.se_regen
scoreboard players add @s zx.dd_mana 0
$execute store result storage zx:data snap."$(uuid)".o15 int 1 run scoreboard players get @s zx.dd_mana
scoreboard players add @s zx.dd_set 0
$execute store result storage zx:data snap."$(uuid)".o16 int 1 run scoreboard players get @s zx.dd_set
scoreboard players add @s zx.dd_temp 0
$execute store result storage zx:data snap."$(uuid)".o17 int 1 run scoreboard players get @s zx.dd_temp
scoreboard players add @s zx.em_mana 0
$execute store result storage zx:data snap."$(uuid)".o18 int 1 run scoreboard players get @s zx.em_mana
scoreboard players add @s zx.im_mk 0
$execute store result storage zx:data snap."$(uuid)".o19 int 1 run scoreboard players get @s zx.im_mk
scoreboard players add @s zx.im_buff 0
$execute store result storage zx:data snap."$(uuid)".o20 int 1 run scoreboard players get @s zx.im_buff
scoreboard players add @s zx.ir_mana 0
$execute store result storage zx:data snap."$(uuid)".o21 int 1 run scoreboard players get @s zx.ir_mana
scoreboard players add @s zx.mr_mana 0
$execute store result storage zx:data snap."$(uuid)".o22 int 1 run scoreboard players get @s zx.mr_mana
scoreboard players add @s zx.mr_atk 0
$execute store result storage zx:data snap."$(uuid)".o23 int 1 run scoreboard players get @s zx.mr_atk
scoreboard players add @s zx.mr_atk1 0
$execute store result storage zx:data snap."$(uuid)".o24 int 1 run scoreboard players get @s zx.mr_atk1
scoreboard players add @s zx.mr_atk2 0
$execute store result storage zx:data snap."$(uuid)".o25 int 1 run scoreboard players get @s zx.mr_atk2
scoreboard players add @s zx.wg_mana 0
$execute store result storage zx:data snap."$(uuid)".o26 int 1 run scoreboard players get @s zx.wg_mana
scoreboard players add @s zx.wg_aura 0
$execute store result storage zx:data snap."$(uuid)".o27 int 1 run scoreboard players get @s zx.wg_aura
scoreboard players add @s zx.wg_burst 0
$execute store result storage zx:data snap."$(uuid)".o28 int 1 run scoreboard players get @s zx.wg_burst
scoreboard players add @s zx.cc_ice 0
$execute store result storage zx:data snap."$(uuid)".o29 int 1 run scoreboard players get @s zx.cc_ice
scoreboard players add @s zx.ly_aura 0
$execute store result storage zx:data snap."$(uuid)".o30 int 1 run scoreboard players get @s zx.ly_aura
scoreboard players add @s zx.ly_timer 0
$execute store result storage zx:data snap."$(uuid)".o31 int 1 run scoreboard players get @s zx.ly_timer
scoreboard players add @s zx.sd_lock 0
$execute store result storage zx:data snap."$(uuid)".o32 int 1 run scoreboard players get @s zx.sd_lock
scoreboard players add @s zx.fb_lava 0
$execute store result storage zx:data snap."$(uuid)".o33 int 1 run scoreboard players get @s zx.fb_lava
scoreboard players add @s zx.chg_on 0
$execute store result storage zx:data snap."$(uuid)".o34 int 1 run scoreboard players get @s zx.chg_on
scoreboard players add @s zx.de_t 0
$execute store result storage zx:data snap."$(uuid)".o35 int 1 run scoreboard players get @s zx.de_t
scoreboard players add @s zx.floor_mana 0
$execute store result storage zx:data snap."$(uuid)".o36 int 1 run scoreboard players get @s zx.floor_mana
scoreboard players add @s zx.wg_sound 0
$execute store result storage zx:data snap."$(uuid)".o37 int 1 run scoreboard players get @s zx.wg_sound
$execute store result storage zx:data snap."$(uuid)".o38 int 1 run data get storage manacore:players "$(uuid)".stats.max_mana
$execute store result storage zx:data snap."$(uuid)".o39 int 1 run data get storage manacore:players "$(uuid)".stats.base_attack
$execute store result storage zx:data snap."$(uuid)".o40 int 1 run data get storage manacore:players "$(uuid)".stats.skill_multiplier
$execute store result storage zx:data snap."$(uuid)".o41 int 1 run data get storage manacore:players "$(uuid)".stats.independent_multiplier
$execute store result storage zx:data snap."$(uuid)".o42 int 1 run data get storage manacore:players "$(uuid)".stats.custom_damage
$execute store result storage zx:data snap."$(uuid)".o43 int 1 run data get storage manacore:players "$(uuid)".stats.max_health
$execute store result storage zx:data snap."$(uuid)".o44 int 1 run data get storage manacore:players "$(uuid)".stats.cooldown_reduction
$execute store result storage zx:data snap."$(uuid)".o45 int 1 run attribute @s minecraft:attack_damage get
$execute store result storage zx:data snap."$(uuid)".o46 int 1 run attribute @s minecraft:max_health get
$execute store result storage zx:data snap."$(uuid)".o47 int 1 run attribute @s minecraft:armor get
$execute store result storage zx:data snap."$(uuid)".o48 int 1 run attribute @s minecraft:movement_speed get
