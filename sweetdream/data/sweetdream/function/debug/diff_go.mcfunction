# ============================================================
# sweetdream:debug/diff_go —— 快照对比的正文(宏参数 {uuid})
# ------------------------------------------------------------
# 【这个文件是生成的】改动看 .workbuddy/gen_diff.py, 然后跑
#   python .workbuddy/gen_diff.py
# 【★ 为什么"第一次按"的判断在这一层 ★】
#   快照是按 uuid 存的(zx:data snap."<uuid>")。上一层的 diff 是普通函数,
#   手上没有展开好的 uuid, 只能判断"snap 这个节点在不在"(任何人存过都算在),
#   判断不出"**你**存过没有"。所以这句必须放在宏层。
# 【它干什么】逐项比 "现在 @s 身上的值" 和 "上次存下的值":
#     一样 -> 什么都不打(静默)
#     不同 -> 打一行 "旧 -> 新", 并**顺手把新值写进快照**
#   于是连按两次就能看到"这一段期间变了什么"。典型用法:
#     换装备前按一次 -> 换完再按一次 -> 所有跟着变的账本一行行自己冒出来。
# 【为什么每项 6 行】没有循环, 只能一行为一项:
#     ① (计分项先补 0, 免得读不出来)  ② 读新值到 #d_new
#     ③ 读旧值到 #d_old(快照里没有就当 0)  ④ 把新值写回快照
#     ⑤ 不一样才打印  ⑥ 记一下有几项变了
# 【数值精度】全部按整数比(小数被截断)。对"换装有没有生效"这个用途足够了;
#   要看精确小数用 /trigger zx.dbg_stats。
# 【快照存哪】zx:data snap."<uuid>".o0 / o1 / ..., 见 gen_diff.py 的 EXTRA 与
#   lib/reg/build 的表(两边顺序加起来就是键的序号)。
# 【★ 宏参数从哪来 ★】上一层(debug/diff)会先把 uuid 抄进 zx:work df,
#   再用 `with storage zx:work df` 调这个函数。
#   ⚠️ 绝不能写成 `with storage zx:data self` —— 实测那个写法会让整个宏函数
#      **一条命令都不跑**(静默, 连日志都不报), 2026-10-03 栽过。
#      全项目能正常工作的宏调用清一色是 `with storage zx:work <临时节点>`
#      或 `with storage zx:reg <表项>`; 照这个来。
# ============================================================

# ---- 第一次按: 只存快照, 不比较(没有"上一次"可比) ----
$execute unless data storage zx:data snap."$(uuid)" run tellraw @s [{"text":"[调试] 第一次按: 已存下当前快照。","color":"aqua"}]
$execute unless data storage zx:data snap."$(uuid)" run tellraw @s [{"text":"换一件装备, 再按一次 /trigger zx.dbg_diff 就能看到变了什么。","color":"gray"}]
$execute unless data storage zx:data snap."$(uuid)" run function sweetdream:debug/snap_save with storage zx:work df
$execute unless data storage zx:data snap."$(uuid)" run return 0

# ---- 之后每次: 比较 + 更新快照 ----
tellraw @s [{"text":"========== 和上次快照比 ==========","color":"gold"}]
scoreboard players set #d_n zx.meta 0

# --- 魔力上限 ---
scoreboard players add @s zx.pump_mana 0
scoreboard players operation #d_new zx.meta = @s zx.pump_mana
$execute if data storage zx:data snap."$(uuid)".o0 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o0
$execute unless data storage zx:data snap."$(uuid)".o0 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o0 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 套装魔力上限 ---
scoreboard players add @s zx.set_mana 0
scoreboard players operation #d_new zx.meta = @s zx.set_mana
$execute if data storage zx:data snap."$(uuid)".o1 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o1
$execute unless data storage zx:data snap."$(uuid)".o1 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o1 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  套装魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 套装生命上限 ---
scoreboard players add @s zx.set_hp 0
scoreboard players operation #d_new zx.meta = @s zx.set_hp
$execute if data storage zx:data snap."$(uuid)".o2 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o2
$execute unless data storage zx:data snap."$(uuid)".o2 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o2 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  套装生命上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 回魔 · 装备额外 ---
scoreboard players add @s zx.regen_last 0
scoreboard players operation #d_new zx.meta = @s zx.regen_last
$execute if data storage zx:data snap."$(uuid)".o3 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o3
$execute unless data storage zx:data snap."$(uuid)".o3 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o3 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  回魔 · 装备额外  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 生命上限 ---
scoreboard players add @s zx.power_hp 0
scoreboard players operation #d_new zx.meta = @s zx.power_hp
$execute if data storage zx:data snap."$(uuid)".o4 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o4
$execute unless data storage zx:data snap."$(uuid)".o4 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o4 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  生命上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
scoreboard players add @s zx.dio_mana 0
scoreboard players operation #d_new zx.meta = @s zx.dio_mana
$execute if data storage zx:data snap."$(uuid)".o5 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o5
$execute unless data storage zx:data snap."$(uuid)".o5 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o5 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 回魔 · 剩余 ---
scoreboard players add @s zx.dio_regen 0
scoreboard players operation #d_new zx.meta = @s zx.dio_regen
$execute if data storage zx:data snap."$(uuid)".o6 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o6
$execute unless data storage zx:data snap."$(uuid)".o6 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o6 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  回魔 · 剩余  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
scoreboard players add @s zx.bl_mana 0
scoreboard players operation #d_new zx.meta = @s zx.bl_mana
$execute if data storage zx:data snap."$(uuid)".o7 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o7
$execute unless data storage zx:data snap."$(uuid)".o7 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o7 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 基础攻击力 ---
scoreboard players add @s zx.bl_atk 0
scoreboard players operation #d_new zx.meta = @s zx.bl_atk
$execute if data storage zx:data snap."$(uuid)".o8 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o8
$execute unless data storage zx:data snap."$(uuid)".o8 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o8 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  基础攻击力  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 回魔修正 ---
scoreboard players add @s zx.bl_regen 0
scoreboard players operation #d_new zx.meta = @s zx.bl_regen
$execute if data storage zx:data snap."$(uuid)".o9 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o9
$execute unless data storage zx:data snap."$(uuid)".o9 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o9 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  回魔修正  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
scoreboard players add @s zx.ss_mana 0
scoreboard players operation #d_new zx.meta = @s zx.ss_mana
$execute if data storage zx:data snap."$(uuid)".o10 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o10
$execute unless data storage zx:data snap."$(uuid)".o10 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o10 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 生命上限 ---
scoreboard players add @s zx.ss_hp 0
scoreboard players operation #d_new zx.meta = @s zx.ss_hp
$execute if data storage zx:data snap."$(uuid)".o11 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o11
$execute unless data storage zx:data snap."$(uuid)".o11 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o11 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  生命上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 护甲 ---
scoreboard players add @s zx.ss_armor 0
scoreboard players operation #d_new zx.meta = @s zx.ss_armor
$execute if data storage zx:data snap."$(uuid)".o12 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o12
$execute unless data storage zx:data snap."$(uuid)".o12 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o12 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  护甲  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
scoreboard players add @s zx.se_mana 0
scoreboard players operation #d_new zx.meta = @s zx.se_mana
$execute if data storage zx:data snap."$(uuid)".o13 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o13
$execute unless data storage zx:data snap."$(uuid)".o13 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o13 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 回魔 · 剩余 ---
scoreboard players add @s zx.se_regen 0
scoreboard players operation #d_new zx.meta = @s zx.se_regen
$execute if data storage zx:data snap."$(uuid)".o14 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o14
$execute unless data storage zx:data snap."$(uuid)".o14 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o14 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  回魔 · 剩余  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
scoreboard players add @s zx.dd_mana 0
scoreboard players operation #d_new zx.meta = @s zx.dd_mana
$execute if data storage zx:data snap."$(uuid)".o15 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o15
$execute unless data storage zx:data snap."$(uuid)".o15 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o15 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 套装魔力上限 ---
scoreboard players add @s zx.dd_set 0
scoreboard players operation #d_new zx.meta = @s zx.dd_set
$execute if data storage zx:data snap."$(uuid)".o16 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o16
$execute unless data storage zx:data snap."$(uuid)".o16 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o16 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  套装魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 击杀后临时魔力上限 ---
scoreboard players add @s zx.dd_temp 0
scoreboard players operation #d_new zx.meta = @s zx.dd_temp
$execute if data storage zx:data snap."$(uuid)".o17 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o17
$execute unless data storage zx:data snap."$(uuid)".o17 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o17 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  击杀后临时魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
scoreboard players add @s zx.em_mana 0
scoreboard players operation #d_new zx.meta = @s zx.em_mana
$execute if data storage zx:data snap."$(uuid)".o18 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o18
$execute unless data storage zx:data snap."$(uuid)".o18 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o18 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
scoreboard players add @s zx.im_mk 0
scoreboard players operation #d_new zx.meta = @s zx.im_mk
$execute if data storage zx:data snap."$(uuid)".o19 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o19
$execute unless data storage zx:data snap."$(uuid)".o19 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o19 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 套装 buff 剩余 ---
scoreboard players add @s zx.im_buff 0
scoreboard players operation #d_new zx.meta = @s zx.im_buff
$execute if data storage zx:data snap."$(uuid)".o20 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o20
$execute unless data storage zx:data snap."$(uuid)".o20 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o20 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  套装 buff 剩余  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
scoreboard players add @s zx.ir_mana 0
scoreboard players operation #d_new zx.meta = @s zx.ir_mana
$execute if data storage zx:data snap."$(uuid)".o21 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o21
$execute unless data storage zx:data snap."$(uuid)".o21 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o21 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
scoreboard players add @s zx.mr_mana 0
scoreboard players operation #d_new zx.meta = @s zx.mr_mana
$execute if data storage zx:data snap."$(uuid)".o22 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o22
$execute unless data storage zx:data snap."$(uuid)".o22 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o22 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 基础攻击力 ---
scoreboard players add @s zx.mr_atk 0
scoreboard players operation #d_new zx.meta = @s zx.mr_atk
$execute if data storage zx:data snap."$(uuid)".o23 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o23
$execute unless data storage zx:data snap."$(uuid)".o23 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o23 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  基础攻击力  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 基础攻击力 · A层 ---
scoreboard players add @s zx.mr_atk1 0
scoreboard players operation #d_new zx.meta = @s zx.mr_atk1
$execute if data storage zx:data snap."$(uuid)".o24 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o24
$execute unless data storage zx:data snap."$(uuid)".o24 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o24 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  基础攻击力 · A层  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 基础攻击力 · B层 ---
scoreboard players add @s zx.mr_atk2 0
scoreboard players operation #d_new zx.meta = @s zx.mr_atk2
$execute if data storage zx:data snap."$(uuid)".o25 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o25
$execute unless data storage zx:data snap."$(uuid)".o25 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o25 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  基础攻击力 · B层  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 回响期间魔力上限 ---
scoreboard players add @s zx.wg_mana 0
scoreboard players operation #d_new zx.meta = @s zx.wg_mana
$execute if data storage zx:data snap."$(uuid)".o26 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o26
$execute unless data storage zx:data snap."$(uuid)".o26 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o26 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  回响期间魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 回响剩余 ---
scoreboard players add @s zx.wg_aura 0
scoreboard players operation #d_new zx.meta = @s zx.wg_aura
$execute if data storage zx:data snap."$(uuid)".o27 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o27
$execute unless data storage zx:data snap."$(uuid)".o27 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o27 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  回响剩余  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 爆发剩余 ---
scoreboard players add @s zx.wg_burst 0
scoreboard players operation #d_new zx.meta = @s zx.wg_burst
$execute if data storage zx:data snap."$(uuid)".o28 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o28
$execute unless data storage zx:data snap."$(uuid)".o28 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o28 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  爆发剩余  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 冰凌层数 ---
scoreboard players add @s zx.cc_ice 0
scoreboard players operation #d_new zx.meta = @s zx.cc_ice
$execute if data storage zx:data snap."$(uuid)".o29 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o29
$execute unless data storage zx:data snap."$(uuid)".o29 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o29 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  冰凌层数  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 光环剩余 ---
scoreboard players add @s zx.ly_aura 0
scoreboard players operation #d_new zx.meta = @s zx.ly_aura
$execute if data storage zx:data snap."$(uuid)".o30 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o30
$execute unless data storage zx:data snap."$(uuid)".o30 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o30 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  光环剩余  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 离下次灼烧 ---
scoreboard players add @s zx.ly_timer 0
scoreboard players operation #d_new zx.meta = @s zx.ly_timer
$execute if data storage zx:data snap."$(uuid)".o31 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o31
$execute unless data storage zx:data snap."$(uuid)".o31 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o31 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  离下次灼烧  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 强化锁定 ---
scoreboard players add @s zx.sd_lock 0
scoreboard players operation #d_new zx.meta = @s zx.sd_lock
$execute if data storage zx:data snap."$(uuid)".o32 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o32
$execute unless data storage zx:data snap."$(uuid)".o32 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o32 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  强化锁定  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 熔浆 ---
scoreboard players add @s zx.fb_lava 0
scoreboard players operation #d_new zx.meta = @s zx.fb_lava
$execute if data storage zx:data snap."$(uuid)".o33 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o33
$execute unless data storage zx:data snap."$(uuid)".o33 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o33 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  熔浆  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 超载剩余 ---
scoreboard players add @s zx.chg_on 0
scoreboard players operation #d_new zx.meta = @s zx.chg_on
$execute if data storage zx:data snap."$(uuid)".o34 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o34
$execute unless data storage zx:data snap."$(uuid)".o34 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o34 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  超载剩余  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 下一波倒计时 ---
scoreboard players add @s zx.de_t 0
scoreboard players operation #d_new zx.meta = @s zx.de_t
$execute if data storage zx:data snap."$(uuid)".o35 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o35
$execute unless data storage zx:data snap."$(uuid)".o35 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o35 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  下一波倒计时  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力下限保护垫付 ---
scoreboard players add @s zx.floor_mana 0
scoreboard players operation #d_new zx.meta = @s zx.floor_mana
$execute if data storage zx:data snap."$(uuid)".o36 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o36
$execute unless data storage zx:data snap."$(uuid)".o36 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o36 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力下限保护垫付  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 风声 ---
scoreboard players add @s zx.wg_sound 0
scoreboard players operation #d_new zx.meta = @s zx.wg_sound
$execute if data storage zx:data snap."$(uuid)".o37 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o37
$execute unless data storage zx:data snap."$(uuid)".o37 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o37 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  风声  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 魔力上限 ---
$execute store result score #d_new zx.meta run data get storage manacore:players."$(uuid)".stats.max_mana
$execute if data storage zx:data snap."$(uuid)".o38 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o38
$execute unless data storage zx:data snap."$(uuid)".o38 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o38 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  魔力上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 基础攻击力 ---
$execute store result score #d_new zx.meta run data get storage manacore:players."$(uuid)".stats.base_attack
$execute if data storage zx:data snap."$(uuid)".o39 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o39
$execute unless data storage zx:data snap."$(uuid)".o39 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o39 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  基础攻击力  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 技能倍率 ---
$execute store result score #d_new zx.meta run data get storage manacore:players."$(uuid)".stats.skill_multiplier
$execute if data storage zx:data snap."$(uuid)".o40 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o40
$execute unless data storage zx:data snap."$(uuid)".o40 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o40 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  技能倍率  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 独立乘区 ---
$execute store result score #d_new zx.meta run data get storage manacore:players."$(uuid)".stats.independent_multiplier
$execute if data storage zx:data snap."$(uuid)".o41 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o41
$execute unless data storage zx:data snap."$(uuid)".o41 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o41 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  独立乘区  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 固定伤害 ---
$execute store result score #d_new zx.meta run data get storage manacore:players."$(uuid)".stats.custom_damage
$execute if data storage zx:data snap."$(uuid)".o42 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o42
$execute unless data storage zx:data snap."$(uuid)".o42 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o42 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  固定伤害  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 面板生命上限 ---
$execute store result score #d_new zx.meta run data get storage manacore:players."$(uuid)".stats.max_health
$execute if data storage zx:data snap."$(uuid)".o43 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o43
$execute unless data storage zx:data snap."$(uuid)".o43 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o43 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  面板生命上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 冷却缩减 ---
$execute store result score #d_new zx.meta run data get storage manacore:players."$(uuid)".stats.cooldown_reduction
$execute if data storage zx:data snap."$(uuid)".o44 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o44
$execute unless data storage zx:data snap."$(uuid)".o44 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o44 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  冷却缩减  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 原版攻击力 ---
execute store result score #d_new zx.meta run attribute @s minecraft:attack_damage get
$execute if data storage zx:data snap."$(uuid)".o45 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o45
$execute unless data storage zx:data snap."$(uuid)".o45 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o45 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  原版攻击力  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 原版生命上限 ---
execute store result score #d_new zx.meta run attribute @s minecraft:max_health get
$execute if data storage zx:data snap."$(uuid)".o46 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o46
$execute unless data storage zx:data snap."$(uuid)".o46 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o46 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  原版生命上限  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 原版护甲 ---
execute store result score #d_new zx.meta run attribute @s minecraft:armor get
$execute if data storage zx:data snap."$(uuid)".o47 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o47
$execute unless data storage zx:data snap."$(uuid)".o47 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o47 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  原版护甲  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

# --- 原版移速 ---
execute store result score #d_new zx.meta run attribute @s minecraft:movement_speed get
$execute if data storage zx:data snap."$(uuid)".o48 store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".o48
$execute unless data storage zx:data snap."$(uuid)".o48 run scoreboard players set #d_old zx.meta 0
$execute store result storage zx:data snap."$(uuid)".o48 int 1 run scoreboard players get #d_new zx.meta
execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  原版移速  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]
execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1

execute if score #d_n zx.meta matches 0 run tellraw @s [{"text":"  没有任何变化。","color":"dark_gray"}]
tellraw @s [{"text":"(本次共 ","color":"dark_gray","italic":true},{"score":{"name":"#d_n","objective":"zx.meta"},"color":"yellow","italic":true},{"text":" 项有变化)","color":"dark_gray","italic":true}]
