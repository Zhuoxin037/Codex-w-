# ============================================================
# sweetdream:upgrade/item/night_vision —— 给一块「夜视仪」
# ------------------------------------------------------------
# 【custom_data】标记 up_night_vision, 进度 advancement/upgrade/night_vision 认它。
# 【底板】recovery_compass + custom_model_data 编号 25。
# 【图标已画】亮黄盾形(night_vision), 编号 25 —— 盾形 = "头盔"那一类。
# 【效果已实装】apply/night_vision + def/load 已登记; 落地在 upgrade/api/nv_now
#   (由 upgrade/armor_apply 的 ⓪ 每秒调一次)。
# 【★ cat 是 "helmet" 不是 "armor" ★】所有盔甲的 zx 里都带自己的槽位词,
#   头盔类装备带 "helmet"(见 equipment/armor/*/give), 填它才能"只装头盔"。
# 【★ 常驻 = 每 12 秒续一次 ★】每秒 effect give 会让状态图标一直闪; 12 秒既不会
#   闪断, 脱下之后也只残留十几秒。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"夜视仪",bold:true,color:light_purple},custom_model_data={floats:[25.0f]},lore=[{"text":"✦ 升级石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"头盔","color":"yellow"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"无","color":"aqua"}]},{"text":" ","italic":false},{"text":"获得常驻的夜视效果。","color":"gray","italic":false}],custom_data={zx:["up_night_vision"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
