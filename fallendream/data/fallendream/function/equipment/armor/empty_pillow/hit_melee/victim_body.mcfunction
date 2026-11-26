$execute unless entity $(vx_uuid) run return 0

# ④ 交给 on_deal（它认 zx.ep_vic：记"造成伤害时刻" + 兑现静息）
$scoreboard players set $(vx_uuid) zx.ep_vic 1
function fallendream:equipment/armor/empty_pillow/on_deal
scoreboard players reset @e[scores={zx.ep_vic=1}] zx.ep_vic

# ⑤ 清掉受害者的临时标签（lib/victim 自己会清，这里只是兜底）
$tag $(vx_uuid) remove zx.victim
