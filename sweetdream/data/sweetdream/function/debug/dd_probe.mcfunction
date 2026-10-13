# ============================================================
# sweetdream:debug/dd_probe —— 黄昏黎明「带标签击杀 100×X」断点自检
# ------------------------------------------------------------
# 【什么时候跑】打死了带通用标签的怪、但魔力上限看起来没多给的时候。
# 【机制(2026-10-12 坑 138 起)】"X = 死者身上有几个通用效果"由 **5 条标签进度**
#   各自独立触发实现(advancement/equipment/armor/dusk_dawn_kill_mark_<tag>) ——
#   同刻触发几条, kill_mark 就进来几次, `@s zx.dd_n` 就是那个 X。
#   ★ 从这一版起**不再有任何附魔回调**: 原版 post_attack 只读攻击者的主手物品,
#     附魔挂在靴子上永远不触发(旧方案静默失效, 用户实测"流火+夜火只加 300")。
# 【读法(逐行对)】
#   ① 脚上是这件 / 是不是超限版   -> 装对没有(只有超限版才走 100×X; 基础版固定 100)
#   ② 本刻进来了几次(dd_n)        -> 应等于死者身上的通用标签数(= X)
#   ③ 账本 t1(基础 200) / t2(100×X) / app(已加) / temp(剩余秒)
#   ④ 完成判定时刻(dd_know) vs 当前刻: 相等 = 本刻刚结算过这一次击杀
#   ★ 典型判读:
#     held=0  -> 脚上不是黄昏黎明之交界, kill_mark 第二行就退了(什么都没加)
#     ol=0    -> 被当成**基础版**(只 +100); 想走 100×X 得穿超限版
#     n=1 但死者明明有 2 个标签 -> 有一条标签进度没触发, 查死者 Tags 与进度文件对不对得上
# ============================================================

tellraw @s [{"text":"════ 黄昏黎明 100×X 断点 ════","color":"gold","bold":true}]

scoreboard players set #dd_held zx.meta 0
execute if items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"]}] run scoreboard players set #dd_held zx.meta 1
function sweetdream:equipment/armor/dusk_dawn/is_ol
tellraw @s [{"text":"① 脚上是这件=","color":"gray"},{"score":{"name":"#dd_held","objective":"zx.meta"},"color":"yellow"},{"text":"   是超限版=","color":"gray"},{"score":{"name":"#dd_ol","objective":"zx.meta"},"color":"yellow"}]

tellraw @s [{"text":"② 本刻进来几次(#dd_n→X)=","color":"gray"},{"score":{"name":"@s","objective":"zx.dd_n"},"color":"yellow"},{"text":"   当前刻(#now)=","color":"gray"},{"score":{"name":"#now","objective":"manacore.meta"},"color":"yellow"}]

tellraw @s [{"text":"③ 账本: 基础=","color":"dark_gray"},{"score":{"name":"@s","objective":"zx.dd_t1"},"color":"gray"},{"text":" 带标签=","color":"dark_gray"},{"score":{"name":"@s","objective":"zx.dd_t2"},"color":"gray"},{"text":" 已加=","color":"dark_gray"},{"score":{"name":"@s","objective":"zx.dd_app"},"color":"gray"},{"text":" 剩余秒=","color":"dark_gray"},{"score":{"name":"@s","objective":"zx.dd_temp"},"color":"gray"}]

tellraw @s [{"text":"④ 完成判定时刻(dd_know)=","color":"gray"},{"score":{"name":"@s","objective":"zx.dd_know"},"color":"yellow"},{"text":"   (#now 相等 = 本刻刚结算过)","color":"dark_gray"}]
