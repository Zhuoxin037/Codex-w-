# UUID查询包含仍加载的尸体；distance将查询限制在攻击者当前维度与16格内。
$execute unless data storage zx:combat ranged_search as $(uuid) at @s if entity @a[tag=zx.vx_owner,distance=..16] if data entity @s {Health:0.0f,HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]} run function fallendream:lib/victim/candidate
# UUID查询包含仍加载的尸体；distance将查询限制在攻击者当前维度与16格内。
$execute if data storage zx:combat ranged_search as $(uuid) at @s if entity @a[tag=zx.vx_owner,distance=0..] if data entity @s {Health:0.0f,HurtTime:10s,last_hurt_by_player:[I;$(u0),$(u1),$(u2),$(u3)]} run function fallendream:lib/victim/candidate
