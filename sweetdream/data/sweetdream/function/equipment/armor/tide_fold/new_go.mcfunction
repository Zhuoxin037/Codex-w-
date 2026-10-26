# ============================================================
# sweetdream:equipment/armor/tide_fold/new_go —— 立墙的宏叶子
# ------------------------------------------------------------
# 【宏参数】zx:work tf {u0..u3, id, yaw}   【执行者】玩家  【位置】自身位置
# 【为什么单独一层】`summon` 的 `Rotation:[<yaw>f,0f]` 只接受**命令行字面量**,
#   yaw 是运行时算出来的 ⇒ 必须走宏（与"attribute 数值只能字面量"同一类禁区）。
# 【墙为什么不跟随玩家】"在自身位置生成"指生成那一刻（设计稿 §六 边界）。
# ============================================================

# ① 墙体 marker: 记下朝向(yaw)与归属(UUID 四个 int)
$summon minecraft:marker ~ ~ ~ {Tags:["zx.tf_wall","zx.tf_new"],data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)],id:$(id)}},Rotation:[$(yaw)f,0f]}

# ② 寿命 200 刻(10 秒) / 粒子间隔 / 编号 / 归属
scoreboard players set @e[tag=zx.tf_new,limit=1] zx.tf_life 200
scoreboard players set @e[tag=zx.tf_new,limit=1] zx.tf_fx 5
scoreboard players operation @e[tag=zx.tf_new,limit=1] zx.tf_id = #tf_seq zx.meta
scoreboard players operation @e[tag=zx.tf_new,limit=1] zx.tf_u0 = #tf_u0 zx.meta
scoreboard players operation @e[tag=zx.tf_new,limit=1] zx.tf_u1 = #tf_u1 zx.meta
scoreboard players operation @e[tag=zx.tf_new,limit=1] zx.tf_u2 = #tf_u2 zx.meta
scoreboard players operation @e[tag=zx.tf_new,limit=1] zx.tf_u3 = #tf_u3 zx.meta

# ③ 表现（以墙为执行者: 沿本地 X 轴铺开, 见 fx_wall）
execute as @e[tag=zx.tf_new,limit=1] at @s run function sweetdream:equipment/armor/tide_fold/init
execute as @e[tag=zx.tf_new,limit=1] at @s run function sweetdream:equipment/armor/tide_fold/fx_wall
tag @e[tag=zx.tf_new,limit=1] remove zx.tf_new

# ④ 出参
scoreboard players set #tf_ok zx.meta 1
