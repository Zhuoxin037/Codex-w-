# ============================================================
# sweetdream:equipment/sword/liaoyuan/second_one —— 光环每秒的心跳(以玩家身份)
# ------------------------------------------------------------
# 【做什么】① 自己的 2 秒小计时器走一格, 到点灼烧一次 ② 光环倒计时, 到点收工
# 【节奏】施法那一刻 ly_timer = 2 -> 之后每 2 秒灼烧一次, 也就是
#   施法后第 2 / 4 / 6 / 8 … 秒各一次, 18 秒一共 9 次;
#   其中第 3、6、9 次(施法后第 6 / 12 / 18 秒)额外附加「流火」。
#   为什么不用"全局秒号 #sec 取余 2": 那样第一次灼烧可能在施法后 1 秒就到(取决于
#   施法落在哪一秒), 节奏不规整、很难数清"第几次"。
# ============================================================

scoreboard players remove @s zx.ly_timer 1
execute if score @s zx.ly_timer matches ..0 run function sweetdream:equipment/sword/liaoyuan/pulse
# 灼烧过就把小计时器装回 2 —— 放在这里而不是 pulse 里面:
# pulse 万一中途 return(比如玩家刚进服还没注册), 节奏也不会被打乱。
execute if score @s zx.ly_timer matches ..0 run scoreboard players set @s zx.ly_timer 2

scoreboard players remove @s zx.ly_aura 1
execute if score @s zx.ly_aura matches ..0 run function sweetdream:equipment/sword/liaoyuan/end
