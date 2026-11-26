# 只消耗进攻前已有的借火；命中后的充能仍由 on_hit 处理。
$execute as $(vx_uuid) at @s run function fallendream:internal/native/melee {melee:1,charged:1,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
