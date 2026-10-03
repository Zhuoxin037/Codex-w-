# ============================================================
# sweetdream:debug/menu_draw —— 画一个菜单按钮(宏参数 {name,obj,hint})
# ------------------------------------------------------------
# 【宏参数】zx:work mi {name,obj,hint}   【执行者】玩家本人
#   name = 显示名  obj = trigger 计分项  hint = 悬停说明
# 【点击执行什么】run_command + /trigger <obj>
#   · 1.21.5 起字段叫 click_event, command 里 **不用带 /** 也行, 带上也行;
#   · 点击是"以点击者本人的身份"跑 —— /trigger 正好就是给这种场景用的
#     (不需要 OP), 所以这里绝不能换成 /function, 那样玩家会没权限。
# 【悬停】hover_event 的 show_text 用 value 字段(老版本叫 contents)。
# ============================================================
$tellraw @s [{"text":"  "},{"text":"▸ ","color":"dark_gray"},{"text":"$(name)","color":"aqua","underlined":true,"click_event":{"action":"run_command","command":"/trigger $(obj)"},"hover_event":{"action":"show_text","value":"$(hint)"}},{"text":"   $(hint)","color":"dark_gray"}]
