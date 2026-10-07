# ============================================================
# sweetdream:equipment/staff/final_revelation/give —— 给一把「终末天启」（法杖）
# ------------------------------------------------------------
# 【custom_data】"final_revelation" -> 装备 id
#   ★ 判定一律写成 custom_data~{zx:["final_revelation"]}(部分匹配 + 独有标记)
# 【数值要和实现对上】普攻 魔力 60 / 伤害 20; 主动 魔力 500 / 冷却 30 秒;
#   「圣光」10 层触发; 光柱 持续 6 秒 / 范围 4×16 / 每秒 最大魔力 ×0.1 / 缓慢Ⅲ 3 秒;
#   主动释放(非圣光触发)结束时额外 最大魔力 ×0.2。
#   ★ 范围 2026-10-07 由 7×20 改成 4×16(用户口径), 见 scan(9 个半径 2 的采样球)。
# 【★ 效果已实装(2026-10-06 晚)】
#   进度 advancement/equipment/staff/final_revelation.json (consume_item -> cast, 分派)
#   + cast / attack / skill / auto_light / second / scan / tick / end / end_blast。
#   custom_data 已补 skill:"sweetdream:final_revelation"。
#   ★ 用户定稿的三条(2026-10-06 晚):
#     ① 光柱**跟随玩家**(按当前位置/朝向每秒重扫), 不是固定在世界里;
#     ② 「圣光」满 10 层自动释放 = **免魔力、不进冷却**(普攻玩家控制不了);
#     ③ 只有**主动释放**才有结束时的 ×0.2 收尾伤害(自动释放没有)。
#   ★ 范围 4×16 用"沿朝向 9 个半径 2 的采样球"拼成(截面是圆的, 近似), 见 scan。
# 【"圣光"是层数资源】10 层满了自动放一次主动技能 —— 所以主动技能有"圣光触发"
#   和"玩家主动释放"两个入口, 只有后者有结束时的 ×0.2 额外伤害。
# 【模型】**故意不写 item_model** —— 包里只有 naturewind:staff 一个法杖模型,
#   写了就会变成「风行于大地之上」。用户 2026-10-05 定: 法杖先用原版外观。
# 【手写文件】不是 _gen_batch5.py 的产物(那批是第五批 15 件), 别被生成器覆盖。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"终末天启",bold:true,color:gold},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"20","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 圣光","color":"gold","bold":true,"italic":false},{"text":"每次普攻后都会积攒一层「圣光」。当","color":"gray","italic":false},{"text":"「圣光」层数到达 10 层后则立即释放一","color":"gray","italic":false},{"text":"次主动技能，之后清除「圣光」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"500","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"仅能在没有释放该技能的时候使用。使用","color":"gray","italic":false},{"text":"后朝自身前方射出一道持续 6 秒、范围为","color":"gray","italic":false},{"text":"4×16 的光柱。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 光柱","color":"gold","bold":true,"italic":false},{"text":"范围内的生物每秒受到一次相当于自身最","color":"gray","italic":false},{"text":"大魔力值 ×0.1 的伤害，且获得 3 秒缓慢","color":"gray","italic":false},{"text":"Ⅲ。若为主动释放，则在结束后再对范围","color":"gray","italic":false},{"text":"内的生物造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.2 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["final_revelation","staff","itemreplace"],skill:"sweetdream:final_revelation"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
