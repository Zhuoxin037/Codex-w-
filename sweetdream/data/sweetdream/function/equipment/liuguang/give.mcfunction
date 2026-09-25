# custom_data 里的 skill:"sweetdream:liuguang" 是给观测镜面板认的:
#   面板会读主手物品的 custom_data.skill, 再显示那个技能的剩余冷却。
#   以后每把武器都带上这个字段, 面板就通用, 不用改任何代码。
give @s iron_sword[item_name={text:"流光",bold:true,color:blue},lore=[{"text":"消耗魔力：20 冷却时间：20秒","color":"gold","italic":false,"bold":true},{"text":"测试用武器","italic":false,"color":"white"}],unbreakable={},custom_data={zx:["liuguang","sword","itemreplace"],skill:"sweetdream:liuguang"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["attribute_modifiers","unbreakable"]}]
