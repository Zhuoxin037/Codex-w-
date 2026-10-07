# 两个目标仅属于显示系统；状态本身保存在原生 Tags 中。
execute unless data storage zx:config tag_v2_initialized run scoreboard objectives add zx.icon_mask dummy
execute unless data storage zx:config tag_v2_initialized run scoreboard objectives add zx.icon_ttl dummy
data modify storage zx:config tag_v2_initialized set value 1b
scoreboard players set #tag_clock zx.meta 0
scoreboard players set #icon_t zx.meta 0

# 【★ 这里**不要**调 tag/second ★】(2026-10-06 修)
#   core/load 在 /reload 时也会跑 -> tag/load 跟着跑 -> 若再调 tag/second, 就会走到
#   tag/ttl_tick 的"每秒 -1": **每敲一次 /reload, 场上所有标签就白扣 1 秒**。
#   调试期频繁 /reload 时, 表现就是"标签莫名其妙短命, 明显不到预设的十几秒", 且不报错。
#   图标那头也不需要在这里重建: text_display 本来就随存档持久化, 下一次每秒校验
#   (core/tick -> tag/second, 最多 1 秒后)会把租约、掩码、淡出位都校好;
#   旧格式残留由 second_dimension 最后那条 kill(排除 zx.icon_fading) 持续清理。
#   本文件只负责"把两个缓存计分项建出来 + 把节拍清零"。
