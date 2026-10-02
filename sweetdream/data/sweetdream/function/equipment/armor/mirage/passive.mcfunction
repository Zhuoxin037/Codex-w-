# ============================================================
# sweetdream:equipment/armor/mirage/passive —— 幻昼的被动 + 套装
# ------------------------------------------------------------
# 【执行者】玩家(由 second 逐个 as @a 调进来)
# 【文案上写的】
#   ① 自身魔力值上限 +240
#   ② 自身攻击生物后有 20% 的概率对其附加「白昼梦」(事件驱动, 见 attack)
#   ③ 附带「白昼梦」的生物受到伤害后, 有 20% 的概率时停 1 秒(同上, 见 attack)
#   ④ 自身 8 格内的生物时停结束后, 对其造成基础攻击力 ×2 的真实伤害(见 ts_end)
#   ⑤ 套装(异彩 + 幻昼): 受伤后基础攻击力 +1, 持续 5 秒 —— **可叠加, 每次受伤
#      各加一层, 不是把时间刷回去**; 攻击带「白昼梦」的生物时基础攻击力 +2,
#      持续 8 秒, **最多叠加 10 次**
# 【本件只管 ① 和 ⑤ 的结算】②③④ 是事件驱动的, 各有自己的入口。
# 【套装为什么写在这一份里】套装要同时看两件, 放哪边都得知道另一件; 按
#   体外供能装置 / 脊骨共生的先例, 统一放"后做的一件", 异彩那份只管自己。
# 【认装备统一用 ~ 部分匹配 + 独有标记】custom_data~{zx:["mirage"]}
# ============================================================

# ① 拿 UUID
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 自己穿了吗 / 异彩戴了吗(套装要两件都在)
scoreboard players set #mr_on zx.meta 0
execute if items entity @s armor.legs netherite_leggings[custom_data~{zx:["mirage"]}] run scoreboard players set #mr_on zx.meta 1
scoreboard players set #ir_on zx.meta 0
execute if items entity @s armor.head netherite_helmet[custom_data~{zx:["iridescent"]}] run scoreboard players set #ir_on zx.meta 1
scoreboard players operation #set_on zx.meta = #mr_on zx.meta
scoreboard players operation #set_on zx.meta *= #ir_on zx.meta

# ③ 魔力上限 +240(账本 zx.mr_mana, 只加差值)
scoreboard players set #want zx.meta 0
execute if score #mr_on zx.meta matches 1 run scoreboard players set #want zx.meta 240
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.mr_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/mirage/apply_mana

# ④ 先把"到寿"的层收掉 —— 必须在算加成之前, 否则会多算一层(见 expire 顶部注释)
function sweetdream:equipment/armor/mirage/expire

# ⑤ 总加成 = (+1 层数) ×1 + (+2 层数) ×2; 套装不在就归零
#    【为什么是"层数"不是"剩余秒数"】旧写法两条各写一个剩余秒数, 第二次触发
#      只是把秒数刷回 5 / 8 —— 加成永远只有 1 层。现在每次触发真加一层,
#      每层各自到期(环形记账, 见 expire), 才是文案说的"叠加"。
#    【+1 不设上限 / +2 封顶 10 层】上限写死在 add_b 里, 这里只管乘 2。
scoreboard players set #want zx.meta 0
execute if score #set_on zx.meta matches 1 run scoreboard players operation #want zx.meta += @s zx.mr_atk2
execute if score #set_on zx.meta matches 1 run scoreboard players operation #want zx.meta *= #2 zx.meta
execute if score #set_on zx.meta matches 1 run scoreboard players operation #want zx.meta += @s zx.mr_atk1

scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.mr_atk
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/mirage/apply_set_atk
