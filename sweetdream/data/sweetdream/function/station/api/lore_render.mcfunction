# ============================================================
# sweetdream:station/api/lore_render —— 往正在重建的 lore 里追加一行(宏 {lab,note})
# ------------------------------------------------------------
# 【样式】"  · " + 全名 + 备注 —— 升级和超限共用这一个。
# 【为什么不用 tellraw】这里是在**造物品**不是打印, 目标列表是
#   zx:work lore(最后会被整段写回物品的 lore 组件)。
# 【注意】宏是按**原样**把字符串塞进这段 JSON 的(不带引号),
#   所以外面的英文引号要自己写全 —— debug/stat_row 那类渲染也是这个写法。
#   反过来: label / note 里不能出现英文双引号和反斜杠。
# ============================================================

$data modify storage zx:work lore append value {"text":"","italic":false,"extra":[{"text":"  · ","color":"dark_gray"},{"text":"$(lab)","color":"yellow"},{"text":"   ","color":"dark_gray"},{"text":"$(note)","color":"gray"}]}
