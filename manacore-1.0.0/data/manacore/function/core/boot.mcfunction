# ============================================================
# core/boot —— 真正的初始化逻辑(由 core/load 调用)
# ------------------------------------------------------------
# 【为什么单独拆一个文件】函数一旦引用到"加载失败的函数", 自己也会连带
#   加载失败。把初始化放在这里, core/load 就能保持极简、始终可用,
#   排错时可以一眼看出问题出在"入口"还是"初始化内容"。
# 【执行内容】
#   ① 默认配置(仅当不存在时写入, 可直接在游戏里改)
#   ② 常量(#scale / #100 / #15 / #zero / #interval / #max_slots ...)
#   ③ 运行期容器(data merge 保证存在, 且不清空已有内容)
#   ④ 会话重置遍历(#mode = 2, 见 index/visit 的模式表)
#   ⑤ 抛 load 事件 + 计数标记
# 【术阵与恢复修正的结构】固定 8 个槽位, 但用的是"复合体 + 数字字符串键"
#   ("0".."7")而不是数组。原因: 宏占位符可以安全地出现在引号键里
#   (formations."$(i)"), 却不能让数组下标参与宏替换(formations[$(i)]
#   会让整个函数在加载期解析失败)。
# ============================================================

# --- 默认配置 (已存在则不覆盖, 可直接在游戏内修改) ---
execute unless data storage manacore:config defaults run data modify storage manacore:config defaults set value {stats:{current_mana:100.0,max_mana:100.0,base_attack:5.0,max_health:20.0,custom_damage:0.0,skill_multiplier:1.0,independent_multiplier:1.0,cooldown:0.0,mana_regen:1.0,mana_regen_multiplier:1.0,cooldown_reduction:0.0,formation_limit:3},flags:{no_regen:0b,regen_ban_end:0},session:0b,debug:0b,cooldowns:{},regen_mods:{"0":{},"1":{},"2":{},"3":{},"4":{},"5":{},"6":{},"7":{}},formations:{"0":{},"1":{},"2":{},"3":{},"4":{},"5":{},"6":{},"7":{}},slot:0,u0:0,u1:0,u2:0,u3:0,uuid:""}
execute unless data storage manacore:config settings run data modify storage manacore:config settings set value {regen_interval:20,max_slots:64,max_regen_mods:8,max_formations:8,debug_default:0b}

# --- 常量 ---
scoreboard players set #scale manacore.meta 1000
# #10 / #100 —— 专给"乘法类"运算用的低精度缩放。
# 背景: 计分板是 32 位有符号整数(上限 21.4 亿)。若两个操作数都按 x1000 取值,
# 相乘会到 x1000000, 于是"裸数值"超过约 2147 就会溢出成负数(表现为结果变成 0)。
# 所以乘法一律把倍率类操作数改成 x100, 再把除回来的除数换成 #100, 这样
# 中间量只有 x100000, 能承受的裸数值提升到约 21474。
# 详见 internal/damage/calc 与 internal/stats/mul_calc 的注释。
scoreboard players set #10 manacore.meta 10
scoreboard players set #100 manacore.meta 100
scoreboard players set #15 manacore.meta 15
scoreboard players set #16 manacore.meta 16
scoreboard players set #zero manacore.meta 0
execute store result score #max_slots manacore.meta run data get storage manacore:config settings.max_slots
execute store result score #interval manacore.meta run data get storage manacore:config settings.regen_interval
execute store result score #max_formations manacore.meta run data get storage manacore:config settings.max_formations
execute store result score #max_mods manacore.meta run data get storage manacore:config settings.max_regen_mods

# --- 运行期容器 ---
data merge storage manacore:ctrl {arg:""}
data merge storage manacore:ctx {uuid:"",id:"",skill:"",reason:""}
data modify storage manacore:out r set value {value:0.0,damage:0.0,count:0,ready:1b,success:1b,reason:"",remaining:0,index:-1}
data merge storage manacore:players {}
data merge storage manacore:index {}
data merge storage manacore:free_slots {list:[]}

# --- 让所有在线玩家在下一秒自动重新注册 ---
# 这里的做法是"把秒号 +1"而不是"遍历所有人把 session 清零":
#   玩家的心跳标记 manacore.beat 停在旧秒号, 于是下一秒 tick_self 就会
#   发现 beat < #sec 并重新走一遍注册(重新计算 UUID、补字段、重新占槽)。
# 好处: boot 不再依赖 index/foreach, 整条加载链变得极短 ——
#   只要 core/load 与 core/boot 本身合法, 入口就一定可用。
scoreboard players add #sec manacore.meta 1

# --- 事件与完成标记 ---
function #manacore:event/load
scoreboard players add #loads manacore.meta 1

# 标记初始化已完成(tick 里的自愈逻辑据此判断是否还需要补跑)
scoreboard players set #boot_done manacore.meta 1
