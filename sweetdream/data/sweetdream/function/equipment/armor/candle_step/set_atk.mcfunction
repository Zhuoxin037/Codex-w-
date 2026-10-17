# ============================================================
# sweetdream:equipment/armor/candle_step/set_atk —— 残烛: 消费夜火后的 +10% 基础攻击力
# ------------------------------------------------------------
# 【谁调用它】candle_step/consume ⑤（"技能成功消费「夜火」"那一刻）
# 【执行者】玩家（消耗者本人）
# 【文案(套装段 逐字)】自身技能成功消费夜火后，自身基础攻击力 +10%，持续 4 秒，
#   并获得 3 秒迅捷Ⅱ。该效果 8 秒内最多触发一次。
# 【★ 本件是"残烛"套装的代码宿主(靴子/烛跬) ★】判定要**焦衣 + 烛跬两件齐**。
# 【★ 口径: "自身基础攻击力"取的是**加成前**的面板值 ★】
#   若每次重算都读"含自己这 10% 的面板", 会自我引用滚雪球 ——
#   所以只在触发那一刻读一次、加一份, 到期(或拆件)再按**账本**原样减回。
#   账本 zx.cs_batk = "加了多少 base_attack × 100"(整数), 回收时 ×0.001 取负正好抵消。
#   口径与 charge/mode_on 的"攻击力翻倍"完全同款(那边系数是 1.0, 这边是 0.1)。
# 【★ 为什么不折面板 ★】它加的**就是面板** (manacore 的 base_attack 统计), 不用额外折;
#   穿上两件、触发一次后打开观测镜就能看到"基础攻击力"那一行变高 —— 这是真值, 不是折出来的。
# 【回收】由 candle_step/second 每秒判"到期 / 拆件"并减回, 见那边头注释。
# ============================================================

# ① 穿齐「残烛」两件吗（● 焦衣 = 胸甲 / ● 烛跬 = 靴子）
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["char_coat"]}] run return 0
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["candle_step"]}] run return 0

# ② 8 秒节流
scoreboard players set #csa_due zx.meta 0
execute store result score #csa_due zx.meta run scoreboard players get @s zx.cs_set_cd
execute if score #csa_due zx.meta > #now manacore.meta run return 0

# ③ 若上一轮还没回收完（4 秒内又触发了一次），先把旧的那份退掉再加新的
#    —— 否则两份叠起来会越加越多, 而账本只记得最后一份。
execute if score @s zx.cs_batk matches 1.. run function sweetdream:equipment/armor/candle_step/atk_back

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ④ 读"当前(base_attack)"并记账本(= 原值 × 100)
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
#    ★ 先归零再 store: data get 失败时 store 不执行, 会留着上一次的值。
scoreboard players set @s zx.cs_batk 0
execute store result score @s zx.cs_batk run data get storage manacore:out r.value 100

# ⑤ 真的加上去: 原值 × 0.1（账本是 ×100 的, 所以乘 0.001 正好）
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get @s zx.cs_batk
function manacore:api/stats/add

# ⑥ 到期刻 = 现在 + 80 刻（"持续 4 秒"）
scoreboard players operation @s zx.cs_end = #now manacore.meta
scoreboard players operation @s zx.cs_end += #80 zx.meta

# ⑦ 3 秒迅捷Ⅱ（amplifier 1 = Ⅱ）
effect give @s minecraft:speed 3 1 true

# ⑧ 表现 + 记账（现在 + 160 刻 = 8 秒）
execute at @s run particle minecraft:soul_fire_flame ~ ~0.2 ~ 0.35 0.1 0.35 0.01 8 normal
execute at @s run playsound minecraft:block.candle.extinguish player @a ~ ~ ~ 0.6 1.3
scoreboard players operation @s zx.cs_set_cd = #now manacore.meta
scoreboard players operation @s zx.cs_set_cd += #160 zx.meta
