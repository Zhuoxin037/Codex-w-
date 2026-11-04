execute if entity @s[tag=zx.j_new_record] run return 0
function sweetdream:lib/uuid
data modify storage zx:work jt.uuid set from storage zx:data self.uuid
function sweetdream:profession/join_go with storage zx:work jt

# Reconnection uses the absolute world clock for active temporary states.
execute if score @s zx.j_cr_t matches 1.. run function sweetdream:profession/rejoin_timer/j_cr_end
execute if score @s zx.j_il_t matches 1.. run function sweetdream:profession/rejoin_timer/j_il_end
execute if score @s zx.j_empath matches 1.. run function sweetdream:profession/rejoin_timer/j_em_end
execute if score @s zx.j_bloom matches 1.. run function sweetdream:profession/rejoin_timer/j_bloom_end
execute if score @s zx.j_pick_t matches 1.. run function sweetdream:profession/rejoin_timer/j_pick_end
execute if score @s zx.j_pain matches 1.. run function sweetdream:profession/rejoin_timer/j_pain_end
execute if score @s zx.job matches 1 if score @s zx.j_reborn matches 1.. run function sweetdream:profession/rejoin_timer/j_abs_end
execute if score @s zx.job matches 4 if score @s zx.j_reborn matches 1.. run function sweetdream:profession/rejoin_timer/j_rb_end
execute if score @s zx.j_host_t matches 1.. run function sweetdream:profession/twin/host_end
# 潮涌，潮枯：离线跨过 12 秒时，别人身上那份"攻/蓝上限"加成得在回来那一刻撤掉。
#   buff_end 自己会判"还没到点就返回"，所以这里只在真过期时动手。
execute if score @s zx.se_b_until matches 1.. run function sweetdream:equipment/staff/surge_ebb/buff_end
