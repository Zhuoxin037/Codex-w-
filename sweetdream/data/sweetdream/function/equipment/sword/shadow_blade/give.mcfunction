# ============================================================
# sweetdream:equipment/sword/shadow_blade/give —— 给一把「影刃」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】
#   "itemreplace"   -> 通用回手线认它(右键才触发、用完还手)
#   "shadow_blade"  -> 武器 id, 进度 equipment/sword/shadow_blade 靠它认人
#   "sword"         -> 分类标记(剑/斧/弓/法杖/盔甲/道具)
#   skill           -> 观测镜靠它显示冷却, 必须和 cast 里传的 skill 一致
# 【lore 版式】统一走 .workbuddy/lore_fmt.py(数字两侧留白 / × 乘号 / 罗马数字 / 37 宽折行)。
# ============================================================

give @s diamond_sword[item_model="sweetdream:shadow_blade",item_name={text:"影刃",bold:true,color:blue},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"120","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"40 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后立即瞬移至自身 10 格内离自身最","color":"gray","italic":false},{"text":"近的一个生物并对其造成相当于自身基础","color":"gray","italic":false},{"text":"伤害 ×2 的伤害。若使用此武器在 5 秒内","color":"gray","italic":false},{"text":"击杀敌人则刷新冷却时间并返还 60 魔力。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["shadow_blade","sword","itemreplace"],skill:"sweetdream:shadow_blade",tags:["base_atk","dash","cd_down"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
