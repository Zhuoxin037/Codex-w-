# ============================================================
# sweetdream:equipment/staff/attack —— 法杖类的"普攻形态"
# ------------------------------------------------------------
# 【这一层是干嘛的】武器的普攻形态**按类别统一**:
#   法杖 = 向前射出一颗法球(就是这一份);
#   以后剑 / 斧 / 弓 各自也会有自己的一份(挥砍 / 劈砍 / 射箭)。
#   同一类里每把武器的数值不同, 但"怎么打出去"是同一套, 所以只写一次。
#
# 【谁调用它】法杖的普攻(例如 wind_ontheground/attack)。
#   调用之前先把数值放好:
#     data modify storage zx:work ball set value {dmg:0.0,style:"<本武器的 zx[0]>"}
#     data modify storage zx:work ball.dmg set from storage manacore:out r.damage
#     function sweetdream:equipment/staff/attack
#   —— 形状 / 射程 / 碰撞 / 归属 / 命中表现全都不用管。
#
# 【想做一把新法杖】照上面的模板写自己的 attack 就行, 别的什么都不用碰。
# 【想加新外观】加两份
#     sweetdream:projectile/ball/fx_<style>.mcfunction        (飞的拖尾)
#     sweetdream:projectile/ball/fx_<style>_hit.mcfunction    (命中的表现)
#   再在 ball/tick 与 ball/hit 里各加一行 `if data {style:"<style>"}` 分支。
# ============================================================

# ① 补默认值(调用者只写了 dmg 也没关系)
execute unless data storage zx:work ball.dmg run data modify storage zx:work ball.dmg set value 0.0
execute unless data storage zx:work ball.style run data modify storage zx:work ball.style set value "plain"

# ② 出膛的"咻"(类别默认音效; 想换就在这一行换)
playsound minecraft:item.trident.throw player @a ~ ~ ~ 0.45 1.5

# ③ 交给法球发射器
function sweetdream:projectile/ball/fire

execute if score @s zx.job matches 1 run function sweetdream:profession/mage/add_orb
execute if score @s zx.job matches 2 run function sweetdream:profession/berserker/attack
