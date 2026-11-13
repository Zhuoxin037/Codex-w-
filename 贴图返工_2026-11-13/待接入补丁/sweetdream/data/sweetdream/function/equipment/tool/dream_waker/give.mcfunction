# 醒梦仪 — 职业强化道具
# 用户确认：沿用追溯指针原版外观，未制作独立模型前不覆盖 item_model。
give @s recovery_compass[item_name={text:"醒梦仪",bold:true,color:"gold"},lore=[{"text":"当前职业：“我”","color":"aqua","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"强化当前职业的被动，每个职业只能强化","color":"gray","italic":false},{"text":"一次。当前职业为“我”，没有可强化的","color":"gray","italic":false},{"text":"职业被动。","color":"gray","italic":false}],custom_data={zx:["dream_waker","tool","itemreplace"],tags:["buff","max_mana","max_hp","heal","summon","formation","slow"]},max_stack_size=1,consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"minecraft:block.bamboo_wood_button.click_off"},minecraft:item_model="sweetdream:tool_dream_waker"]

function sweetdream:equipment/tool/dream_waker/sync
