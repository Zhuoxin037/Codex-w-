# Serialize the actor only on an actual side change, never every tick near a wall.
data modify storage zx:work tf_pos.cur set from entity @s
$data modify storage zx:work tf_pos.prev set from entity @e[tag=zx.tf_prev,distance=0..,scores={zx.sid=$(sid)},limit=1]
execute store result score #tf_px zx.meta run data get storage zx:work tf_pos.prev.Pos[0] 64
$scoreboard players remove #tf_px zx.meta $(cx)
execute store result score #tf_py zx.meta run data get storage zx:work tf_pos.prev.Pos[1] 64
$scoreboard players remove #tf_py zx.meta $(cy)
execute store result score #tf_pz zx.meta run data get storage zx:work tf_pos.prev.Pos[2] 64
$scoreboard players remove #tf_pz zx.meta $(cz)
execute store result score #tf_cx zx.meta run data get storage zx:work tf_pos.cur.Pos[0] 64
$scoreboard players remove #tf_cx zx.meta $(cx)
execute store result score #tf_cy zx.meta run data get storage zx:work tf_pos.cur.Pos[1] 64
$scoreboard players remove #tf_cy zx.meta $(cy)
execute store result score #tf_cz zx.meta run data get storage zx:work tf_pos.cur.Pos[2] 64
$scoreboard players remove #tf_cz zx.meta $(cz)
$scoreboard players set #tf_nx zx.meta $(nx)
$scoreboard players set #tf_nz zx.meta $(nz)
scoreboard players operation #tf_d0 zx.meta = #tf_px zx.meta
scoreboard players operation #tf_d0 zx.meta *= #tf_nx zx.meta
scoreboard players operation #tf_tmp zx.meta = #tf_pz zx.meta
scoreboard players operation #tf_tmp zx.meta *= #tf_nz zx.meta
scoreboard players operation #tf_d0 zx.meta += #tf_tmp zx.meta
scoreboard players operation #tf_d1 zx.meta = #tf_cx zx.meta
scoreboard players operation #tf_d1 zx.meta *= #tf_nx zx.meta
scoreboard players operation #tf_tmp zx.meta = #tf_cz zx.meta
scoreboard players operation #tf_tmp zx.meta *= #tf_nz zx.meta
scoreboard players operation #tf_d1 zx.meta += #tf_tmp zx.meta
scoreboard players set #tf_neg zx.meta -1
execute if score #tf_d0 zx.meta matches ..-1 run scoreboard players operation #tf_d0 zx.meta *= #tf_neg zx.meta
execute if score #tf_d1 zx.meta matches ..-1 run scoreboard players operation #tf_d1 zx.meta *= #tf_neg zx.meta
scoreboard players operation #tf_den zx.meta = #tf_d0 zx.meta
scoreboard players operation #tf_den zx.meta += #tf_d1 zx.meta
execute unless score #tf_den zx.meta matches 1.. run return 0
scoreboard players operation #tf_rem zx.meta = #tf_d0 zx.meta
scoreboard players set #tf_ratio zx.meta 0
scoreboard players set #tf_digits zx.meta 4
function sweetdream:equipment/armor/tide_fold/ratio_loop
# Tangential coordinates and the interpolated intersection, in units of 1/65536.
scoreboard players operation #tf_w0 zx.meta = #tf_px zx.meta
scoreboard players operation #tf_w0 zx.meta *= #tf_nz zx.meta
scoreboard players operation #tf_tmp zx.meta = #tf_pz zx.meta
scoreboard players operation #tf_tmp zx.meta *= #tf_nx zx.meta
scoreboard players operation #tf_w0 zx.meta -= #tf_tmp zx.meta
scoreboard players operation #tf_w1 zx.meta = #tf_cx zx.meta
scoreboard players operation #tf_w1 zx.meta *= #tf_nz zx.meta
scoreboard players operation #tf_tmp zx.meta = #tf_cz zx.meta
scoreboard players operation #tf_tmp zx.meta *= #tf_nx zx.meta
scoreboard players operation #tf_w1 zx.meta -= #tf_tmp zx.meta
scoreboard players operation #m4_src zx.meta = #tf_w1 zx.meta
scoreboard players operation #m4_src zx.meta -= #tf_w0 zx.meta
scoreboard players operation #m4_mul zx.meta = #tf_ratio zx.meta
function sweetdream:lib/math/mul_10000
scoreboard players operation #tf_w0 zx.meta += #m4_out zx.meta
execute unless score #tf_w0 zx.meta matches -262144..262144 run return 0
scoreboard players operation #m4_src zx.meta = #tf_cy zx.meta
scoreboard players operation #m4_src zx.meta -= #tf_py zx.meta
function sweetdream:lib/math/mul_10000
scoreboard players operation #tf_py zx.meta += #m4_out zx.meta
execute unless score #tf_py zx.meta matches 0..154 run return 0
function sweetdream:equipment/armor/tide_fold/cross with storage zx:work tf_pair
