# ------------------------------------------------------------
# 把"这次击杀该加多少"补上去
#   want = t1(基础 200) + t2(带标签额外 100), diff = want - 已经加过的
#   为什么要用差值: 一连杀好几只时, 8 秒的倒计时会刷新, 上限不能重复加。
# ------------------------------------------------------------
scoreboard players operation #want zx.meta = @s zx.dd_t1
scoreboard players operation #want zx.meta += @s zx.dd_t2
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.dd_app
scoreboard players set #src zx.meta 3
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/dusk_dawn/apply_mana
