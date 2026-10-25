# ============================================================
# sweetdream:equipment/armor/tide_fold/probe —— 水墙的一个采样点（宏）
# ------------------------------------------------------------
# 【宏参数】zx:work tf {u0..u3, id}   【执行者】墙 marker  【位置】该采样点(脚底高度)
# 【口径 = 共鸣 staff/chime/pass_set ①】
#   ① 法球: 基准**抬高 1.6 格**再 `distance=..1.5`, 且必须是自己人的
#      (`nbt={data:{u0..u3}}`)、且**还没打过戳**(每颗球对这面墙只触发一次);
#   ② 生物: 以采样点本身为基准 `distance=..2`（人和怪都站地上, 不抬）;
#   ③ 玩家: 同上, 交给 cross_player 反查"是不是墙的主人"再分派。
# ============================================================

# ① 法术穿过: 给自己人的、还没穿过的法球打一次性戳 zx.tf_pass
#    ★ 口径(设计稿 §六): 只认本包法杖法球(zx.ball), 不含箭矢 / 斩击 / 光束 / 爆炸。
#    ★ "不含已经穿过一次的同一次施法" —— 法球每次施法现生成, 球上的戳天然只打一次。
$execute positioned ~ ~1.6 ~ as @e[tag=zx.ball,distance=..1.5,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}},tag=!zx.tf_pass] run tag @s add zx.tf_pass

# ② 生物穿过（★ #sweetdream:no_damage 里已含 player, 一个 type= 就够）
execute as @e[type=!#sweetdream:no_damage,distance=..2] at @s run function sweetdream:equipment/armor/tide_fold/cross_enemy with storage zx:work tf

# ③ 玩家穿过（可能是主人, 也可能是别人 ⇒ cross_player 内部反查判定）
execute as @a[distance=..2] at @s run function sweetdream:equipment/armor/tide_fold/cross_player with storage zx:work tf
