# ============================================================
# sweetdream:equipment/bow/rainbow/consume —— 吞噬一个效果 + 伤害 + 漫彩 -1 秒
# ------------------------------------------------------------
# 【谁调它】second ②(执行者 = 带漫彩的那只生物, #rb_k = 要吞的效果编号 1..5)
# 【做的三件事】
#   ① 消耗该效果(走统一入口 lib/mark_consume)
#   ② 使其受到 施加者最大生命值 ×0.1 的伤害
#   ③ 漫彩 -1 秒(zx.rb_end -= 20)
# 【编号 -> 效果】1=liuhuo 2=yehuo 3=yuanhai 4=dream 5=shixin
# 【伤害归属】用生物计分项 zx.rb_u0..u3 反查施加者。
# 【★ 消耗者是谁(2026-10-06)★】效果是在**被标记生物**身上被吞的, 但"消耗"这个
#   动作是**放了漫彩的玩家**做的 —— 所以先用 lib/find_by 把施加者反查出来
#   (打 zx.mc_by), 再把它当 by 传进统一入口。这样施加者穿「永恒」时,
#   会扣他的 50 魔力把效果刷回来(= 漫彩吞不掉)。反查不到人 -> by 选 0 人 ->
#   永恒跳过, 效果照常被吞。
# ============================================================

# ① 反查施加者 -> zx.mc_by
data modify storage zx:work rb set value {u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:work rb.u0 int 1 run scoreboard players get @s zx.rb_u0
execute store result storage zx:work rb.u1 int 1 run scoreboard players get @s zx.rb_u1
execute store result storage zx:work rb.u2 int 1 run scoreboard players get @s zx.rb_u2
execute store result storage zx:work rb.u3 int 1 run scoreboard players get @s zx.rb_u3
function sweetdream:lib/find_by with storage zx:work rb

# ② 消耗该效果: 按编号把 mark 名填进 a, 交给统一入口
data modify storage zx:work a set value {target:"@s",mark:"",by:"@a[tag=zx.mc_by,limit=1]"}
execute if score #rb_k zx.meta matches 1 run data modify storage zx:work a.mark set value "liuhuo"
execute if score #rb_k zx.meta matches 2 run data modify storage zx:work a.mark set value "yehuo"
execute if score #rb_k zx.meta matches 3 run data modify storage zx:work a.mark set value "yuanhai"
execute if score #rb_k zx.meta matches 4 run data modify storage zx:work a.mark set value "dream"
execute if score #rb_k zx.meta matches 5 run data modify storage zx:work a.mark set value "shixin"
function sweetdream:lib/mark_consume

# ③ 伤害 = 施加者最大生命值 ×0.1
data modify storage zx:work a set value {target:"@s",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
execute store result storage zx:work a.u0 int 1 run scoreboard players get @s zx.rb_u0
execute store result storage zx:work a.u1 int 1 run scoreboard players get @s zx.rb_u1
execute store result storage zx:work a.u2 int 1 run scoreboard players get @s zx.rb_u2
execute store result storage zx:work a.u3 int 1 run scoreboard players get @s zx.rb_u3
function sweetdream:equipment/bow/rainbow/consume_dmg with storage zx:work a

# ④ 漫彩 -1 秒
scoreboard players remove @s zx.rb_end 20

# 表现
particle minecraft:witch ~ ~1 ~ 1.0 0.6 1.0 0.5 20 normal
