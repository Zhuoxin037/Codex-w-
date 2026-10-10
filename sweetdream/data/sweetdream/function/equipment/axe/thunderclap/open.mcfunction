# ============================================================
# sweetdream:equipment/axe/thunderclap/open —— 威霆: 开一个术阵
# ------------------------------------------------------------
# 【谁调用它】thunderclap/hit(②), 执行者 = 施法者, 位置 = 施法者
# 【做什么】
#   ① 消耗 = min(当前魔力, 天煌点数); X = **实际消耗** ×0.005(×5 ÷100 ÷10), 下限 1
#      ★ 口径(2026-10-08 用户定稿 a): 文案"若魔力值不足则本次攻击视消耗的魔力总数为
#        「天煌」点数" —— 即魔力不足时把"消耗的魔力"当作天煌点数, X 按**实际消耗**算。
#        魔力充足 ⇒ 消耗 = 天煌(X 与旧版一致); 魔力不足 ⇒ 消耗 = 当前魔力(X 随之变小)。
#   ② 扣除这 min(魔力, 天煌) 点魔力
#   ③ 清空「天煌」
#   ④ 在被击者(当前 zx.victim)所在处生成半径 6 的术阵 marker, 持续 X×2 秒
#   ⑤ 置 zx.tc_on = 1("术阵结束前不能再开")
# 【数值改哪】持续 = 这里的 X×2; 半径 6 = field_tick/bolt 里的 ..6。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 读当前魔力 -> #tc_m; 本次实际消耗 #tc_use = min(魔力, 天煌点数); X = #tc_use ×0.005, 下限 1
data modify storage manacore:in arg set value {uuid:"",key:"current_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #tc_m zx.meta 0
execute store result score #tc_m zx.meta run data get storage manacore:out r.value
scoreboard players operation #tc_use zx.meta = @s zx.tc_n
scoreboard players operation #tc_use zx.meta < #tc_m zx.meta
scoreboard players operation #tc_x zx.meta = #tc_use zx.meta
scoreboard players operation #tc_x zx.meta *= #5 zx.meta
scoreboard players operation #tc_x zx.meta /= #100 zx.meta
scoreboard players operation #tc_x zx.meta /= #10 zx.meta
execute unless score #tc_x zx.meta matches 1.. run scoreboard players set #tc_x zx.meta 1

# ② 扣除这 min(魔力, 天煌) 点魔力
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #tc_use zx.meta
function manacore:api/mana/consume

# ③ 清空「天煌」
scoreboard players set @s zx.tc_n 0

# ④ 组装术阵 marker 的宏参数(X / 持续秒数 / 施法者 uuid 文本 + 四整数)
scoreboard players operation #tc_dur zx.meta = #tc_x zx.meta
scoreboard players operation #tc_dur zx.meta *= #2 zx.meta
# ④-b 【R03】绝对到期 tick = 当前 gametime + 持续秒数×20, 一并写进 marker。
#   marker 上的 zx.tc_ft 只在它**被加载**时才每秒 -1; 区块卸载期间全局时钟照走,
#   框架术阵(duration_seconds)按绝对时间到期 ⇒ 重进后 marker 会比框架多活一段。
#   marker 额外存一个"几点几分该收摊", field_tick 重加载时立刻核对过期(见那里)。
#   ★ gametime 存计分项(整型)在约 1242 天后会触 int32 上界 —— 与包内 #now 去重戳同款口径。
execute store result score #tc_et zx.meta run time query gametime
scoreboard players operation #tc_tmp zx.meta = #tc_dur zx.meta
scoreboard players operation #tc_tmp zx.meta *= #20 zx.meta
scoreboard players operation #tc_et zx.meta += #tc_tmp zx.meta
data modify storage zx:work tcf.x set value 0
execute store result storage zx:work tcf.x int 1 run scoreboard players get #tc_x zx.meta
data modify storage zx:work tcf.dur set value 0
execute store result storage zx:work tcf.dur int 1 run scoreboard players get #tc_dur zx.meta
data modify storage zx:work tcf.et set value 0
execute store result storage zx:work tcf.et int 1 run scoreboard players get #tc_et zx.meta
data modify storage zx:work tcf.uu set from storage zx:data self.uuid
data modify storage zx:work tcf.u0 set from entity @s UUID[0]
data modify storage zx:work tcf.u1 set from entity @s UUID[1]
data modify storage zx:work tcf.u2 set from entity @s UUID[2]
data modify storage zx:work tcf.u3 set from entity @s UUID[3]

# 在被击者所在处生成(位置在被击者)
execute at @e[tag=zx.victim,distance=0..,limit=1] run function sweetdream:equipment/axe/thunderclap/field with storage zx:work tcf

# ⑤ 同时在**框架里**登记一个真术阵(和 charge 同款: id/type 固定, 重开只刷新不越堆)
#   【为什么要这一步】文案明写"术阵", 而框架的术阵系统才是"术阵"的真相所在 ——
#     登记之后: 观测镜的"术阵 n/上限"、术阵上限、以及「无效」/「共振」这类
#     "看术阵行事"的装备都能认出它(共振: 每有一个术阵 技能伤害 +10%)。
#   【为什么 marker 还要留】框架里的术阵只存数据、**不存位置**; 而"半径 6 格"的判定
#     必须有个圆心 -> 位置真相仍然是上面那个 marker(和神裁领域/崩裂裂缝同一套做法)。
#   【失败怎么办】术阵上限满了 create 会失败(reason=formation_limit) —— 不影响技能:
#     落雷判定只看 marker 与 zx.tc_on。所以这里**不看返回值**。
data modify storage manacore:in arg set value {uuid:"",id:"sweetdream:thunderclap",type:"thunderclap",duration_seconds:0.0,data:{radius:6.0}}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.duration_seconds double 1 run scoreboard players get #tc_dur zx.meta
function manacore:api/formation/create

# ⑥ 标记"已有术阵"
scoreboard players set @s zx.tc_on 1

# ⑥ 表现
execute at @e[tag=zx.victim,distance=0..,limit=1] run particle minecraft:electric_spark ~ ~1 ~ 2.5 1.0 2.5 0.15 60 normal
execute at @e[tag=zx.victim,distance=0..,limit=1] run playsound minecraft:entity.lightning_bolt.thunder player @a ~ ~ ~ 1.0 1.2
tellraw @s [{"text":"威霆: 天煌 ","color":"aqua"},{"score":{"name":"#tc_x","objective":"zx.meta"},"color":"white"},{"text":" → 术阵持续 ","color":"aqua"},{"score":{"name":"#tc_dur","objective":"zx.meta"},"color":"white"},{"text":" 秒","color":"aqua"}]
