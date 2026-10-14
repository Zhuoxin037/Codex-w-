# 帧13 / 0.65秒：强化反向横扫；同一份目标再受一次0.1伤害。
function sweetdream:equipment/sword/flame_brokenbody/combat/restore
function sweetdream:equipment/sword/flame_brokenbody/dmg
# 夜火吸收与流火转化只在前方攻击完成后处理一次，不能把新转的夜火再次吸走。
function sweetdream:equipment/sword/flame_brokenbody/combat/status
tag @e[tag=zx.fb_hit,distance=0..] remove zx.fb_hit
