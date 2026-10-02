# ============================================================
# sweetdream:equipment/armor/mirage/expire —— 每秒收掉"到寿"的那一格
# ------------------------------------------------------------
# 【执行者】玩家(由 passive 在算加成**之前**调进来)
# 【为什么要有"格子"】套装的两条加成都是"每次触发 +1 层, 每层各活 5 / 8 秒",
#   而且**先加的先掉**—— 不能像以前那样只写一个"剩余秒数": 那样第二次
#   触发只是把时间刷回去, 层数永远只有 1 层(就是用户说的"重置时间")。
#   所以做成**环形记账**: 每一格记"那一秒内加了几层", 每秒把"该到寿的那
#   一格"清掉, 并从总层数里扣回去。总层数 = 所有格子之和。
# 【格数 = 时长 + 1】到第 T 秒清的是"第 T-格数 秒"那一格, 它的年龄是
#   (格数-1) ~ 格数 秒。取"时长+1"才能保证每层**至少**活满 5 / 8 秒。
# 【下标谁推进】mirage/second 每秒把 #mr_ra / #mr_rb 各 +1 取模; 这里只读
#   它: 清"当前这一格", 而这一秒里新加的层也写进"当前这一格" —— 两者
#   必须同格, 否则新层会被下一轮提前清掉。
# ============================================================

# ① +1 环: 6 格, 每层至少活 5 秒(受伤一次 +1 层)
execute if score #mr_ra zx.meta matches 0 run scoreboard players operation @s zx.mr_atk1 -= @s zx.mr_a0
execute if score #mr_ra zx.meta matches 0 run scoreboard players set @s zx.mr_a0 0
execute if score #mr_ra zx.meta matches 1 run scoreboard players operation @s zx.mr_atk1 -= @s zx.mr_a1
execute if score #mr_ra zx.meta matches 1 run scoreboard players set @s zx.mr_a1 0
execute if score #mr_ra zx.meta matches 2 run scoreboard players operation @s zx.mr_atk1 -= @s zx.mr_a2
execute if score #mr_ra zx.meta matches 2 run scoreboard players set @s zx.mr_a2 0
execute if score #mr_ra zx.meta matches 3 run scoreboard players operation @s zx.mr_atk1 -= @s zx.mr_a3
execute if score #mr_ra zx.meta matches 3 run scoreboard players set @s zx.mr_a3 0
execute if score #mr_ra zx.meta matches 4 run scoreboard players operation @s zx.mr_atk1 -= @s zx.mr_a4
execute if score #mr_ra zx.meta matches 4 run scoreboard players set @s zx.mr_a4 0
execute if score #mr_ra zx.meta matches 5 run scoreboard players operation @s zx.mr_atk1 -= @s zx.mr_a5
execute if score #mr_ra zx.meta matches 5 run scoreboard players set @s zx.mr_a5 0

# ② +2 环: 9 格, 每层至少活 8 秒(打到带白昼梦的生物 +1 层, 最多 10 层)
execute if score #mr_rb zx.meta matches 0 run scoreboard players operation @s zx.mr_atk2 -= @s zx.mr_b0
execute if score #mr_rb zx.meta matches 0 run scoreboard players set @s zx.mr_b0 0
execute if score #mr_rb zx.meta matches 1 run scoreboard players operation @s zx.mr_atk2 -= @s zx.mr_b1
execute if score #mr_rb zx.meta matches 1 run scoreboard players set @s zx.mr_b1 0
execute if score #mr_rb zx.meta matches 2 run scoreboard players operation @s zx.mr_atk2 -= @s zx.mr_b2
execute if score #mr_rb zx.meta matches 2 run scoreboard players set @s zx.mr_b2 0
execute if score #mr_rb zx.meta matches 3 run scoreboard players operation @s zx.mr_atk2 -= @s zx.mr_b3
execute if score #mr_rb zx.meta matches 3 run scoreboard players set @s zx.mr_b3 0
execute if score #mr_rb zx.meta matches 4 run scoreboard players operation @s zx.mr_atk2 -= @s zx.mr_b4
execute if score #mr_rb zx.meta matches 4 run scoreboard players set @s zx.mr_b4 0
execute if score #mr_rb zx.meta matches 5 run scoreboard players operation @s zx.mr_atk2 -= @s zx.mr_b5
execute if score #mr_rb zx.meta matches 5 run scoreboard players set @s zx.mr_b5 0
execute if score #mr_rb zx.meta matches 6 run scoreboard players operation @s zx.mr_atk2 -= @s zx.mr_b6
execute if score #mr_rb zx.meta matches 6 run scoreboard players set @s zx.mr_b6 0
execute if score #mr_rb zx.meta matches 7 run scoreboard players operation @s zx.mr_atk2 -= @s zx.mr_b7
execute if score #mr_rb zx.meta matches 7 run scoreboard players set @s zx.mr_b7 0
execute if score #mr_rb zx.meta matches 8 run scoreboard players operation @s zx.mr_atk2 -= @s zx.mr_b8
execute if score #mr_rb zx.meta matches 8 run scoreboard players set @s zx.mr_b8 0

# ③ 保险: 总层数不该为负(理论上不会, 出现就归零, 免得加成算出负数)
execute if score @s zx.mr_atk1 matches ..-1 run scoreboard players set @s zx.mr_atk1 0
execute if score @s zx.mr_atk2 matches ..-1 run scoreboard players set @s zx.mr_atk2 0
