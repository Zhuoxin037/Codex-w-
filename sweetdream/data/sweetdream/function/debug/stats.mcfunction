# ============================================================
# sweetdream:debug/stats —— 打印"自己的当前数值"
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/stats   或   /trigger zx.dbg_stats
# 【打印什么】
#   魔力 / 伤害参数 / 原版属性 + **面板一致性报警** / 回魔(合成好的每秒总值) /
#   冷却缩减(直接给百分比) / 术阵 / **在身装备的加成(穿着什么报什么)** /
#   主手那把武器 + 它自己的冷却
# 【★ 穿着什么报什么(2026-10-03) ★】
#   开头先用 debug/equip_scan 扫 6 个槽位, 把在身装备 id 登记进 zx:work eq;
#   注册表(lib/reg/build)每一行都有 e 字段(属于哪件装备), 渲染时查 eq,
#   **没穿的装备不显示** —— 以前是把所有装备的账一股脑全叠上来, 装备越多越没法看。
# 【★ 这个文件不含任何宏 ★】
#   全部走前置包接口: api/player/self_uuid · api/stats/export · api/mana/get ·
#   api/mana/regen/get · api/formation/count —— 它们把 uuid 当**数据**收,
#   调用方一个 $(变量) 都不用写。
#   (2026-10-07 前唯一要按 uuid 拼路径的"风行下次加成"由小宏 debug/wg_row 处理;
#    那份槽位已去掉, 现在读玩家计分项 zx.mm_add 即可, wg_row 已删除。)
# 【★ 面板字段是"平铺"的 ★】
#   api/stats/export 导出的 manacore:out r.stats = 面板本体:
#     current_mana / max_mana / base_attack / max_health / custom_damage /
#     independent_multiplier / cooldown / cooldown_reduction /
#     mana_regen / mana_regen_multiplier / formation_limit
#   ⚠️ **没有** stats. 这一子层! 上一版写成 pl.stats.max_health, 路径永远读不到
#     -> "面板和原版对不上"的报警对谁都是亮的(静默误报), 2026-10-03 修。
# 【★ 倍率一律合成数值再显示 ★】
#   回魔给"每秒回魔"(=(基础+修正)×倍率 算好的结果) + "装备额外"(账本),
#   冷却缩减给百分比 —— 不让用户自己对算式。
# 【它是只读的】不会改任何数据(只写 zx:work / manacore:in 这些临时节点)。
# ============================================================

tellraw @s [{"text":"========== 自己的数值 ==========","color":"gold"}]
function sweetdream:profession/display_name
tellraw @s [{"text":"  职业 ","color":"gray"},{"nbt":"profession_name","storage":"zx:work","color":"white"}]

# ------------------------------------------------------------
# ① 先拿 uuid, 并且把"拿没拿到"变成一个计分项(免得后面静默失败)
# ------------------------------------------------------------
scoreboard players set #g_reg zx.meta 0
data modify storage manacore:in arg set value {uuid:""}
function manacore:api/player/self_uuid
data modify storage zx:work sd set value {uuid:""}
data modify storage zx:work sd.uuid set from storage manacore:out r.uuid
execute if data storage zx:work sd.uuid unless data storage zx:work sd{uuid:""} run scoreboard players set #g_reg zx.meta 1
execute if score #g_reg zx.meta matches 0 run tellraw @s [{"text":"还没注册完成(uuid 是空的) —— 等一秒再试","color":"red"}]
execute if score #g_reg zx.meta matches 0 run return fail

# ------------------------------------------------------------
# ② 归一化: 面板整份拷进 zx:work pl(字段名 = 面板原名, 平铺)
# ------------------------------------------------------------
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:work sd.uuid
function manacore:api/stats/export
# 【先清空再拷】接口没导出成功时这里就是空白/0, 而不是上一次的旧数值。
data remove storage zx:work pl
data modify storage zx:work pl set from storage manacore:out r.stats

# ---- 魔力(前置包接口, 带夹紧 —— 这才是"当前真值") ----
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:work sd.uuid
function manacore:api/mana/get
data modify storage zx:work pl.mana set from storage manacore:out r.value
data modify storage zx:work pl.mana_max set from storage manacore:out r.max

# ---- 回魔速率的三个原料(合成在 ③ 里做, 屏幕上只给结果) ----
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:work sd.uuid
function manacore:api/mana/regen/get
data modify storage zx:work pl.regen_base set from storage manacore:out r.value
data modify storage zx:work pl.regen_bonus set from storage manacore:out r.bonus
data modify storage zx:work pl.regen_mult set from storage manacore:out r.multiplier

# ---- 术阵数量/上限 ----
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:work sd.uuid
function manacore:api/formation/count
execute store result score #g_fcnt zx.meta run data get storage manacore:out r.count
execute store result score #g_flim zx.meta run data get storage manacore:out r.limit

# ---- 原版属性(游戏里真正生效的那一套) ----
execute store result storage zx:work pl.v_atk double 0.001 run attribute @s minecraft:attack_damage get 1000
execute store result storage zx:work pl.v_hpmax double 0.001 run attribute @s minecraft:max_health get 1000
execute store result storage zx:work pl.v_armor double 0.001 run attribute @s minecraft:armor get 1000
execute store result storage zx:work pl.v_speed double 0.001 run attribute @s minecraft:movement_speed get 1000
execute store result score #g_hp zx.meta run data get entity @s Health 1
execute store result score #g_hpmax zx.meta run attribute @s minecraft:max_health get

# ------------------------------------------------------------
# ③ 派生数值 —— 倍率类的东西在这里**算成结果**, 屏幕上只给数
# ------------------------------------------------------------
# 【每秒回魔】(基础 + 修正) × 倍率 —— 计分板只能算整数, 全程 ×1000。
#   #rp = 前置包速率(×1000); regen_last 是装备直接 add 的那部分(上一秒实收)。
execute store result score #rp zx.meta run data get storage zx:work pl.regen_base 1000
execute store result score #rt zx.meta run data get storage zx:work pl.regen_bonus 1000
scoreboard players operation #rp zx.meta += #rt zx.meta
execute store result score #rt zx.meta run data get storage zx:work pl.regen_mult 1000
# 【★ R05 整数上界保护(2026-10-10)★】#rp 此刻是**×1000 定点**, 下一步要 ×#rt。
#   计分板是 **int32**, 中间值越过 2,147,483,647 会**回绕成负数** —— 不报错,
#   得到的却是一个天文数字或负值(表现就是"伤害突然变成几百亿/负数")。
#   这里补一道动态上限 = INT32_MAX ÷ #rt; 常态数值远不到那个量级, 一行都不受影响。
#   ★ 为什么带上 `matches 1..`: 除数如果是 0, 这条 operation **静默失败**(见坑 85 的
#     除零事故), 乘数是百分比加法的结果、被减到 0 以下是有可能的。
#   ★ 为什么不改成"先 ÷100 再 ×": 那会把 45.67 砍成 45, 让常态丢掉小数精度 ——
#     为防一个极端数值牺牲常态精度不划算(vuln_tag 那条注释里有同样的取舍)。
scoreboard players set #rp_cap zx.meta 2147483647
execute if score #rt zx.meta matches 1.. run scoreboard players operation #rp_cap zx.meta /= #rt zx.meta
execute if score #rt zx.meta matches 1.. if score #rp zx.meta > #rp_cap zx.meta run scoreboard players operation #rp zx.meta = #rp_cap zx.meta
scoreboard players operation #rp zx.meta *= #rt zx.meta
#   ⚠ scoreboard operation 的除数不能写字面量(必须是"源玩家+源计分项"),
#     写 /= 1000 会导致整个函数解析失败 —— 除数放在常量假玩家 #k1000 里。
scoreboard players set #k1000 zx.meta 1000
scoreboard players operation #rp zx.meta /= #k1000 zx.meta
execute store result storage zx:work pl.regen_pack double 0.001 run scoreboard players get #rp zx.meta
scoreboard players operation #rt zx.meta = @s zx.regen_last
scoreboard players operation #rt zx.meta *= #1000 zx.meta
scoreboard players add @s zx.regen_last_m 0
scoreboard players operation #rt zx.meta += @s zx.regen_last_m
execute store result storage zx:work pl.regen_add double 0.001 run scoreboard players get #rt zx.meta
scoreboard players operation #rp zx.meta += #rt zx.meta
execute store result storage zx:work pl.regen_total double 0.001 run scoreboard players get #rp zx.meta

# 【冷却缩减百分比】0.25 -> 25.0, 屏幕上直接是"缩短百分之几"
execute store result storage zx:work pl.cd_pct double 0.1 run data get storage zx:work pl.cooldown_reduction 1000

# ------------------------------------------------------------
# ④ 装备扫描 —— 穿着什么报什么的名单(zx:work eq.<id> = 1b)
# ------------------------------------------------------------
#   6 个槽位各扫一遍; eq.all 恒为 1b, 是注册表"全局行"的通行证。
#   【槽位路径】1.21.5 穿戴的在 equipment.*, 主手是 SelectedItem(见 equip_scan)。
data remove storage zx:work eq
data modify storage zx:work eq.all set value 1b
function sweetdream:debug/equip_scan {p:"SelectedItem"}
function sweetdream:debug/equip_scan {p:"equipment.offhand"}
function sweetdream:debug/equip_scan {p:"equipment.head"}
function sweetdream:debug/equip_scan {p:"equipment.chest"}
function sweetdream:debug/equip_scan {p:"equipment.legs"}
function sweetdream:debug/equip_scan {p:"equipment.feet"}

# ============================================================
# ⑤ 魔力
# ============================================================
data modify storage zx:work np set value {k1:"mana",l1:"魔力",c1:"aqua",k2:"mana_max",l2:"魔力上限",c2:"dark_aqua"}
function sweetdream:debug/num_pair with storage zx:work np

# ============================================================
# ⑥ 伤害参数(技能往 api/damage/calc 里填的就是这几个)
# ============================================================
#   ★ 先把 lib/skill_mul/scan 跑掉 ★
#     它算出三条通道倍率(smul_*)并把「最大魔力值技能倍率」通用加成折进去,
#     **同时**让在身装备(愠怒)把"独立乘区"折进来 —— 而下面几行正要看那一行。
#     以前 scan 排在"技能倍率"节里(在独立乘区行的**后面**), 于是面板那一行
#     永远看不到愠怒的 ×1.20(2026-10-06 用户反馈: "愠怒是独立乘区")。
#     scan 只写 zx:work, 提前跑没有副作用。
function sweetdream:lib/skill_mul/scan
tellraw @s [{"text":"── 伤害参数 ──","color":"dark_gray"}]
data modify storage zx:work np set value {k1:"base_attack",l1:"基础攻击力",c1:"white",k2:"custom_damage",l2:"固定伤害",c2:"red"}
function sweetdream:debug/num_pair with storage zx:work np
data modify storage zx:work np set value {k1:"max_health",l1:"生命上限",c1:"red",k2:"independent_multiplier",l2:"独立乘区",c2:"gold"}
function sweetdream:debug/num_pair with storage zx:work np

# ---- ★ 技能倍率: 已拆成三条通道(2026-10-04) ★ ----
#   框架里技能倍率不再是一个数, 而是三条通道各自乘完基数后相加
#   (见 manacore/internal/damage/calc):
#     最大魔力值技能倍率 max_mana_mul / 基础攻击力倍率 attack_mul / 其他倍率 other_mul
#   这里显示的是"现在真的会乘上去的倍率":
#     在身装备/超限给的乘区(目前 = 主手武器的超限伤害)
#     + 最大魔力值那条**额外折进「最大魔力值技能倍率」通用加成**(风声 / 忘川彼岸 /
#       无效, 一份 20 秒的玩家 buff; 2026-10-07 前它叫"待生效的风声加成")
#   **不含技能自身的基率** —— 也就是"我这个流派现在整体被放大了多少"。
#   数值由 lib/skill_mul/scan 现算, 换主手武器 / 通用加成到期后会跟着变。
tellraw @s [{"text":"── 技能倍率(当前生效乘区) ──","color":"dark_gray"}]
#   (三条通道的值已在上面 ⑥ 的"伤害参数"之前由 lib/skill_mul/scan 算好)
data modify storage zx:work nr set value {k:"smul_mm",l:"最大魔力值技能倍率 ×",c:"aqua",s:""}
function sweetdream:debug/num_row with storage zx:work nr
data modify storage zx:work nr set value {k:"smul_atk",l:"基础攻击力倍率 ×",c:"gold",s:""}
function sweetdream:debug/num_row with storage zx:work nr
data modify storage zx:work nr set value {k:"smul_oth",l:"其他倍率 ×",c:"green",s:""}
function sweetdream:debug/num_row with storage zx:work nr

# ---- ★ 控制时长倍率(2026-10-06 加) ★ ----
#   控制时长加成(受控时间)现在也收进了"倍率"这一节: 数值由 lib/ctrl_mul/pct 现算,
#   和 lib/timestop / lib/freeze 结算时用的是**同一个文件** —— 面板显示的就是实际生效的。
#   【取谁的值】控制时长加成挂在**目标**身上(白昼梦只贴非玩家活体) —— 面板是你的数据,
#     所以取"16 格内最近一只带白昼梦的生物"来代表"你现在控制它时能多拿多少";
#     附近没有这样的目标时显示 ×1.00(表示此刻没有可控制的对象在吃这份加成)。
#   【口径说明写在 使用教程 §14.3.3】面板上不写灰字。
#   【值是字符串】lib/ctrl_mul/pct 直接拼好 "1.20" 这种两位小数(避开双精度的长尾),
#     num_row 的链路对字符串原样透传 —— 所以下面是把 cm.s 抄进 pl.ctrl_mul, 不是取数算。
data remove storage zx:work cm
data modify storage zx:work cm.target set value "@e[tag=zx.status.dream,distance=..16,sort=nearest,limit=1]"
function sweetdream:lib/ctrl_mul/pct with storage zx:work cm
data modify storage zx:work pl.ctrl_mul set from storage zx:work cm.s
data modify storage zx:work nr set value {k:"ctrl_mul",l:"控制时长 ×",c:"light_purple",s:""}
function sweetdream:debug/num_row with storage zx:work nr

# 共振: 穿上且每术阵 +10%, 已并入上面三条通道(乘最终伤害 ≡ 三条各 ×k, 数学等价)
execute unless score #res_pct zx.meta matches 100 run tellraw @s [{"text":"  共振：每术阵 +10%，已并入上面三条通道","color":"dark_gray"}]

# ============================================================
# ⑦ 原版属性 + 面板一致性检查
# ============================================================
tellraw @s [{"text":"── 原版属性 ──","color":"dark_gray"}]
data modify storage zx:work np set value {k1:"v_atk",l1:"攻击(含主手)",c1:"white",k2:"v_hpmax",l2:"生命上限",c2:"red"}
function sweetdream:debug/num_pair with storage zx:work np
data modify storage zx:work np set value {k1:"v_armor",l1:"护甲",c1:"aqua",k2:"v_speed",l2:"移速",c2:"green"}
function sweetdream:debug/num_pair with storage zx:work np
tellraw @s [{"text":"  当前生命  ","color":"gray"},{"score":{"name":"#g_hp","objective":"zx.meta"},"color":"red"},{"text":" / ","color":"gray"},{"score":{"name":"#g_hpmax","objective":"zx.meta"},"color":"dark_red"}]

# 【一致性报警】面板 max_health 和原版 max_health 应该相等(装备是双写的:
#   面板是技能公式读的账本, 原版 attribute 才是真的血条)。
#   ×100 躲开浮点比较; **两边都先归零** —— 路径读不到时 store 不执行,
#   不归零就会拿上一次的旧值比, 掩盖真正的"读不到"。
#   ⚠️ 上一版永远误报, 就是因为路径写成了 pl.stats.max_health(不存在)。
scoreboard players set #g_ph zx.meta 0
scoreboard players set #g_vh zx.meta 0
execute store result score #g_ph zx.meta run data get storage zx:work pl.max_health 100
execute store result score #g_vh zx.meta run data get storage zx:work pl.v_hpmax 100
execute unless score #g_ph zx.meta = #g_vh zx.meta run tellraw @s [{"text":"  ⚠ 面板生命上限和原版对不上! ","color":"red","bold":true},{"text":"(有装备只写了面板、没写原版 attribute, 或者反过来)","color":"red"}]

# ============================================================
# ⑧ 回魔 —— 只给合成好的数, 不摆算式
# ============================================================
tellraw @s [{"text":"── 回魔 ──","color":"dark_gray"}]
data modify storage zx:work np set value {k1:"regen_total",l1:"每秒回魔",c1:"green",k2:"regen_add",l2:"装备额外",c2:"dark_green"}
function sweetdream:debug/num_pair with storage zx:work np

# ============================================================
# ⑨ 冷却 + 术阵
# ============================================================
data modify storage zx:work nr set value {k:"cd_pct",l:"冷却缩减",c:"yellow",s:"%"}
function sweetdream:debug/num_row with storage zx:work nr
tellraw @s [{"text":"  术阵      ","color":"gray"},{"score":{"name":"#g_fcnt","objective":"zx.meta"},"color":"light_purple"},{"text":" / ","color":"dark_gray"},{"score":{"name":"#g_flim","objective":"zx.meta"},"color":"dark_purple"}]

# ============================================================
# ⑨.5 在身效果(状态计时) —— 批 14 那批"给自己上的状态"在这里看得见
# ------------------------------------------------------------
# 【为什么要单独一节】用户反馈："那些给自己的效果没给到观测镜"。
#   注册表(lib/reg/build)只能显示"某个计分项的原值", 而这几件的状态存的是
#   **到期绝对刻**(zx.bk_wd / zx.gy_wd / zx.ta_cd …), 直接显示会是一串天文数字。
#   这里统一换算成"剩余秒", 并且只对**穿着的**装备显示(和注册表一个规矩)。
# 【口径】
#   剩余秒 = max(0, 到期刻 - #now) / #20   —— 整数秒, 面板不需要 0.1 秒精度
#   ★ 先夹到 0 再除: 不夹的话过期状态会显示成负秒, 玩家会以为坏了 ★
# 【为什么不进注册表 a 表】a 表的 o 字段只能写"计分项原名", 而这里全是派生值
#   (要做减法除法), 塞不进表 —— 所以走 tellraw 直出。字段名用 #g_* 假名,
#   本函数仍然只读玩家数据(与全文件"只读"的约定一致)。
# ============================================================
tellraw @s [{"text":"── 在身效果 ──","color":"dark_gray"}]
data modify storage zx:look xline set value [{text:""}]
scoreboard players set #ly_first zx.meta 1
function sweetdream:lib/look/new_equipment
tellraw @s [{"nbt":"xline","storage":"zx:look","interpret":true}]
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["wrath"]}] run tellraw @s [{text:"  愠怒独立增伤仅适用于最大魔力值相关技能。",color:"dark_gray"}]
tellraw @s [{text:"  通道倍率包含当前待消耗增益；特定目标的易伤按目标状态结算。",color:"dark_gray"}]

# ---- 空枕「静息」：距上次造成伤害还差几秒 / 已就绪(下次攻击附「白昼梦」) ----
scoreboard players operation #g_s zx.meta = #now manacore.meta
scoreboard players operation #g_s zx.meta -= @s zx.ep_hit
scoreboard players set #g_t zx.meta 80
scoreboard players operation #g_t zx.meta -= #g_s zx.meta
execute if score #g_t zx.meta matches ..0 run scoreboard players set #g_t zx.meta 0
scoreboard players operation #g_t zx.meta /= #20 zx.meta
execute if data storage zx:work eq.empty_pillow if entity @s[tag=zx.ep_rest] run tellraw @s [{"text":"  「静息」  ","color":"gray"},{"text":"已就绪 —— 下次攻击附「白昼梦」","color":"light_purple"}]
execute if data storage zx:work eq.empty_pillow unless entity @s[tag=zx.ep_rest] run tellraw @s [{"text":"  「静息」还差  ","color":"gray"},{"score":{"name":"#g_t","objective":"zx.meta"},"color":"light_purple"},{"text":" 秒","color":"dark_gray"}]

# ---- 返照「回照」剩余 + 20 秒节流 ----
scoreboard players operation #g_a zx.meta = @s zx.bk_wd
scoreboard players operation #g_a zx.meta -= #now manacore.meta
execute if score #g_a zx.meta matches ..0 run scoreboard players set #g_a zx.meta 0
scoreboard players operation #g_a zx.meta /= #20 zx.meta
scoreboard players operation #g_b zx.meta = @s zx.bk_cd
scoreboard players operation #g_b zx.meta -= #now manacore.meta
execute if score #g_b zx.meta matches ..0 run scoreboard players set #g_b zx.meta 0
scoreboard players operation #g_b zx.meta /= #20 zx.meta
execute if data storage zx:work eq.backlight run tellraw @s [{"text":"  「回照」剩余  ","color":"gray"},{"score":{"name":"#g_a","objective":"zx.meta"},"color":"aqua"},{"text":" 秒   (下次可触发 ","color":"gray"},{"score":{"name":"#g_b","objective":"zx.meta"},"color":"dark_aqua"},{"text":" 秒)","color":"gray"}]

# ---- 回旋「旋步」剩余 + 12 秒节流 ----
scoreboard players operation #g_a zx.meta = @s zx.gy_wd
scoreboard players operation #g_a zx.meta -= #now manacore.meta
execute if score #g_a zx.meta matches ..0 run scoreboard players set #g_a zx.meta 0
scoreboard players operation #g_a zx.meta /= #20 zx.meta
scoreboard players operation #g_b zx.meta = @s zx.gy_cd
scoreboard players operation #g_b zx.meta -= #now manacore.meta
execute if score #g_b zx.meta matches ..0 run scoreboard players set #g_b zx.meta 0
scoreboard players operation #g_b zx.meta /= #20 zx.meta
execute if data storage zx:work eq.gyre run tellraw @s [{"text":"  「旋步」剩余  ","color":"gray"},{"score":{"name":"#g_a","objective":"zx.meta"},"color":"aqua"},{"text":" 秒   (下次可触发 ","color":"gray"},{"score":{"name":"#g_b","objective":"zx.meta"},"color":"dark_aqua"},{"text":" 秒)","color":"gray"}]

# ---- 踏灰 12 秒节流（回血 + 减 CD 共用这一个闸）----
scoreboard players operation #g_a zx.meta = @s zx.ta_cd
scoreboard players operation #g_a zx.meta -= #now manacore.meta
execute if score #g_a zx.meta matches ..0 run scoreboard players set #g_a zx.meta 0
scoreboard players operation #g_a zx.meta /= #20 zx.meta
execute if data storage zx:work eq.tread_ash run tellraw @s [{"text":"  踏灰下次可触发  ","color":"gray"},{"score":{"name":"#g_a","objective":"zx.meta"},"color":"aqua"},{"text":" 秒","color":"dark_gray"}]

# ---- 雨迹：场上还留着几个水迹点（30 格内）----
scoreboard players set #g_rtn zx.meta 0
execute as @e[tag=zx.rt_dot,distance=..30] run scoreboard players add #g_rtn zx.meta 1
execute if data storage zx:work eq.rain_trace run tellraw @s [{"text":"  场上水迹  ","color":"gray"},{"score":{"name":"#g_rtn","objective":"zx.meta"},"color":"aqua"},{"text":" 处（每处持续 5 秒）","color":"dark_gray"}]

# ---- 位移检测窗口（踏灰/雨迹共用）：放完技能后的 1 秒内才亮 ----
#   ★ 这是排查"为什么没触发"的关键：窗口内一直没确认位移 ⇒ 说明这次技能根本没挪窝。
execute if entity @s[tag=zx.sm_chk] run tellraw @s [{"text":"  位移检测  ","color":"gray"},{"text":"进行中，还剩 ","color":"yellow"},{"score":{"name":"@s","objective":"zx.sm_t"},"color":"yellow"},{"text":" 刻","color":"dark_gray"}]
execute if entity @s[tag=zx.sm_chk] if score @s zx.sm_done matches 1 run tellraw @s [{"text":"  位移检测  ","color":"gray"},{"text":"已确认位移","color":"green"}]

# ============================================================
# ⑩ 在身装备的加成 —— 由注册表驱动(lib/reg/build), 穿着什么报什么
# ============================================================
tellraw @s [{"text":"── 在身装备的加成 ──","color":"dark_gray"}]
function sweetdream:debug/reg_unroll

# 风行"下次技能加成"那一行(2026-10-07 改) —— 原来它是 zx:data wg_bonus 里一个按
#   uuid 存的比例值, 注册表放不进去, 所以单独拆了个小宏 debug/wg_row 来补一行。
#   现在那份槽位整体去掉: 加成变成玩家计分项 zx.mm_add(百分点), 直接读 @s 即可
#   —— 不需要宏, wg_row.mcfunction 已删除。(曾有过 zx.mm_add_t 倒计时, 2026-10-08 作废)
#   注意: 这个值**已经折进上面"最大魔力值技能倍率 ×"那一行**了, 这里单列出来只是为了
#   让你看清"具体加了多少、还剩多久"。
# 【这行读数已删】2026-10-08 用户说它"另起一行" —— 那个百分点本来就折进上面
#   "最大魔力值技能倍率 ×"那一行(lib/mm_add/scan_mul 写进 smul_mm 加算池),
#   再单独列一行带倒计时, 反而像另一套东西。要看单值走 /function sweetdream:debug/wind。

# ============================================================
# ⑪ 主手那把武器 + 它自己的冷却
# ============================================================
#   【为什么要单独一块】属性表是全账号的, 而"这把武器现在能不能放"取决于它
#     自己那条冷却。技能 id 就写在主手物品的 custom_data.skill 上, 用现成的
#     look/cooldown_get 去读(和观测镜读的是同一份逻辑, 不会两处算出不同的数)。
tellraw @s [{"text":"── 主手武器 ──","color":"dark_gray"}]
data remove storage zx:work a.skill
execute if data entity @s SelectedItem.components."minecraft:custom_data".skill run data modify storage zx:work a.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill

#   【★ 出参是 #v_cdi / #v_cdd ★】look/cooldown_get 把结果拆成"整数位 + 十分位"
#     写在 zx.meta 上(和观测镜面板同一份逻辑, 不会两处算出不同的数)。
#     2026-10-18: 原来只有整数秒, 现在统一给一位小数。
#     不需要先归零: 它内部每次都完整重算(#v_end - #now)。
scoreboard players set #g_cd zx.meta 0
scoreboard players set #g_cd_d zx.meta 0
execute if data storage zx:work a.skill run function sweetdream:equipment/tool/look/cooldown_get with storage zx:work a
scoreboard players operation #g_cd zx.meta = #v_cdi zx.meta
scoreboard players operation #g_cd_d zx.meta = #v_cdd zx.meta

# 把 "sweetdream:sickle_dreams" 砍掉命名空间, 只留 sickle_dreams 去查中文名
execute if data storage zx:work a.skill run data modify storage zx:work a.id set string storage zx:work a.skill 11
data modify storage zx:work a.l set value "  "
data modify storage zx:work a.tail set value ""
execute if data storage zx:work a.id run function sweetdream:debug/name_row with storage zx:work a
execute if data storage zx:work a.id run tellraw @s [{"text":"   剩余冷却 ","color":"gray"},{"score":{"name":"#g_cd","objective":"zx.meta"},"color":"yellow"},{"text":".","color":"yellow"},{"score":{"name":"#g_cd_d","objective":"zx.meta"},"color":"yellow"},{"text":" 秒","color":"yellow"}]
execute unless data storage zx:work a.skill run tellraw @s [{"text":"  主手不是本包武器(物品上没有 skill 字段)","color":"dark_gray"}]
