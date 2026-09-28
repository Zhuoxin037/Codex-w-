# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/hurt —— 受伤触发(桂冠的狂醉)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/dionysus_helmet
#   触发器 minecraft:entity_hurt_player —— 玩家受到任何伤害都会触发。
#   用它而不是"每刻查血量": 只在真受伤时才跑, 平时零开销。
# 【文案】自身受到伤害后有 20% 的概率获得反胃 III 和力量 III,
#         并且自身每秒恢复 80 魔力值, 持续 3 秒。
# 【20% 怎么判】用谓词 sweetdream:chance_20(minecraft:random_chance, chance:0.2)
#   这是数据包里做概率最干净的办法: 一行, 不占计分板, 也不往聊天栏刷东西。
# ============================================================

# ⓪ 先撤销自己的进度
#   进度一旦授予就不会再"授予一次", 不撤销的话只有第一次受伤会触发。
advancement revoke @s only sweetdream:equipment/armor/dionysus_helmet

# ① 戴着才生效(~ 部分匹配 + 只认桂冠独有的那一段标记, 以后改 give 也不用跟着改)
execute unless items entity @s armor.head netherite_helmet[custom_data~{zx:["dionysus_helmet"]}] run return fail

# ② 掷一次 20%(没中就直接结束, 什么都不做)
execute unless predicate sweetdream:chance_20 run return fail

# ③ 中了: 反胃 III + 力量 III, 各 3 秒
#    amplifier 从 0 开始算, 所以"III 级"是 2。hideParticles 填 true 免得烟雾糊脸。
effect give @s minecraft:nausea 3 2 true
effect give @s minecraft:strength 3 2 true

# ④ 每秒回 80 魔力, 持续 3 秒
#    不用 schedule(它没有 @s, 还得靠标签找回来), 而是把一个"剩余秒数"写在自己身上,
#    由每秒的 second 那份去扣 —— 简单、也不用管清理。
scoreboard players set @s zx.dio_regen 3

# ⑤ 给自己一点反馈(不然"中了但屏幕没变化"会让人以为是 bug)
tellraw @s [{"text":"醉意涌上来了……","color":"light_purple","italic":false}]
