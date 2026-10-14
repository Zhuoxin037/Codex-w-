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
# #16 专给 UUID 半字节拆解(internal/uuid/nibbles)用; #15 是死常量, 2026-10-08 删。
scoreboard players set #16 manacore.meta 16
scoreboard players set #zero manacore.meta 0
execute store result score #max_slots manacore.meta run data get storage manacore:config settings.max_slots
execute store result score #interval manacore.meta run data get storage manacore:config settings.regen_interval
# 【2026-10-08 删掉两个死常量】#max_formations / #max_mods 全包无人读 ——
#   术阵 / 修正的槽位数是**硬编码 8**(formations / regen_mods 各 8 个复合键),
#   改 settings 里的 max_formations / max_regen_mods 不会有任何效果
#   (mod_full 的旧注释曾让人以为"调大就行")。留着只会误导。

# --- 运行期容器 ---
data merge storage manacore:ctrl {arg:""}
data merge storage manacore:ctx {uuid:"",id:"",skill:"",reason:""}
data modify storage manacore:out r set value {value:0.0,damage:0.0,count:0,ready:1b,success:1b,reason:"",remaining:0,index:-1}
data merge storage manacore:players {}
# 【2026-10-10 补(修 F16)】players_all = "uuid 终身清单"(list = 裸 uuid 字符串),
#   供 debug/reset_all 清掉索引之外的**离线玩家**记录 —— 见 internal/debug/purge_registry。
#   这里只保证存储存在; 清单内容由 5 个"建记录口"各登记一行维护
#   (player/create、join/new、debug/reset_one、uuid/migrate、uuid/join)。
data merge storage manacore:players_all {}
data merge storage manacore:index {}
# 【★ 2026-10-10 修: 整包静默失效的元凶 ★】
#   原来这一行是 `data merge storage manacore:free_slots {list:[]}` —— 看着像
#   "保证回收池存在", 但 **NBT merge 对列表是整体替换**(不是保留/追加),
#   于是每 reload 一次就把池子清空一次; 而 #next_slot 只增不减 ⇒ 槽位只出不进
#   ⇒ 撑满 #max_slots 后 slot/new 永远拒分配 ⇒ 没人能注册 ⇒ index 恒空
#   ⇒ 全包静默失效(不报错、技能/观测镜/提示全死)。现场: #next_slot=64=#max_slots、
#   #slot_full=1、#slot_overflow=52。
#   现在只"保证存在", 池子内容交给下面的 internal/slot/rebuild 按 index 反推重建。
#   ★ 别改回 `{list:[]}` —— 守门: check.py 的 mergelist 规则。
data merge storage manacore:free_slots {}
execute unless data storage manacore:free_slots list run data modify storage manacore:free_slots list set value []
# 【★ 槽位回收池按 index 实际占用重建(自愈)★】不变量: 有 index 条目 = 占用, 否则空闲。
#   重建出来的集合与"正常回收"累积的完全一致 ⇒ 既能对账, 也能把历史上漏掉的槽位
#   一次性找回来(哪怕 #slot_full 已经卡在 1, reload 一次就恢复, 不用手改计分板)。
#   详见 internal/slot/rebuild 的说明。
function manacore:internal/slot/rebuild
# 【★ 2026-10-11 P1 修(N01/N02)★ 这里的"满槽归零"hack 已删除】
#   原写法: `execute if score #next_slot >= #max_slots run set #next_slot 0`。它有两个
#   致命问题 ——
#     N02: 归零后 slot/new 只是 `+1`, 而它**不判 index."<槽>" 是否已存在** ⇒ 满槽
#          reload 后第 65 人写到**已占用的 slot 1** 上, 两人索引归属冲突。
#     N01: 与之配套的"回收池只增"还会把"从未发过的高位槽"也塞进池, 而 foreach 只
#          遍历 1..#next_slot ⇒ 高位槽漏遍历。
#   正解: #next_slot 的语义改为「**当前最高已登记(占用)槽**」, 由 internal/slot/rebuild
#   在 boot 时按 index 重算(重算逻辑在那个文件的 scan_go 递归体里)。
#   ★ 不要再写回 `set #next_slot 0` —— 守门拦这一条(check.py 的 regress 槽位锁)。
#   ★ 这里**不**重算: 重算已收进上一行的 internal/slot/rebuild 内部, 顺序是"先重算上限、
#     再按 index 重建回收池"。
scoreboard players set #slot_full manacore.meta 0

# --- 让所有在线玩家在下一秒自动重新注册 ---
# 【★ F01 修(2026-10-10)】原来这里是"把秒号 #sec +1", 靠"玩家心跳 manacore.beat
#   停在旧秒号"来触发重注册。但 #sec 每秒都在涨 ⇒ 那个判据**每秒都成立** ⇒
#   每个在线玩家每秒都重走一遍完整注册(重算 UUID ~700 条命令 + 重发 player_join)。
#   现在改用"注册代" #gen: 只在 boot 里 +1, 与秒号彻底解耦;
#   玩家注册时把当前代记进 @s manacore.gen, tick_self 靠"代是否落后"判需不需要注册。
#   判据见 internal/session/tick_self。
scoreboard players add #gen manacore.meta 1

# --- 事件与完成标记 ---
function #manacore:event/load
scoreboard players add #loads manacore.meta 1

# 标记初始化已完成(tick 里的自愈逻辑据此判断是否还需要补跑)
scoreboard players set #boot_done manacore.meta 1
