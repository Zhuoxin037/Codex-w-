scoreboard players set #phase sd.floor 3
data modify storage sweetdream_floor:run options set value []
data modify storage sweetdream_floor:run offers set value []
function sweetdream_floor:reward/check_tag {tag:"yuanhai",name:"渊海"}
function sweetdream_floor:reward/check_tag {tag:"liuhuo",name:"流火"}
function sweetdream_floor:reward/check_tag {tag:"yehuo",name:"夜火"}
function sweetdream_floor:reward/check_tag {tag:"shixin",name:"噬心"}
function sweetdream_floor:reward/check_tag {tag:"dream",name:"白昼梦"}
function sweetdream_floor:reward/check_tag {tag:"cur_mana",name:"当前魔力"}
function sweetdream_floor:reward/check_tag {tag:"max_mana",name:"最大魔力"}
function sweetdream_floor:reward/check_tag {tag:"base_atk",name:"基础攻击"}
function sweetdream_floor:reward/check_tag {tag:"max_hp",name:"生命上限"}
function sweetdream_floor:reward/check_tag {tag:"flat",name:"固定伤害"}
function sweetdream_floor:reward/check_tag {tag:"true_dmg",name:"真实伤害"}
function sweetdream_floor:reward/check_tag {tag:"heal",name:"治疗"}
function sweetdream_floor:reward/check_tag {tag:"apply",name:"状态施加"}
function sweetdream_floor:reward/check_tag {tag:"consume",name:"状态消耗"}
function sweetdream_floor:reward/check_tag {tag:"debuff",name:"减益"}
function sweetdream_floor:reward/check_tag {tag:"buff",name:"增益"}
function sweetdream_floor:reward/check_tag {tag:"cd_down",name:"缩减冷却"}
function sweetdream_floor:reward/check_tag {tag:"indep_mul",name:"独立增伤"}
function sweetdream_floor:reward/check_tag {tag:"summon",name:"召唤"}
function sweetdream_floor:reward/check_tag {tag:"dash",name:"位移"}
function sweetdream_floor:reward/check_tag {tag:"attract",name:"聚怪"}
function sweetdream_floor:reward/check_tag {tag:"field",name:"领域"}
function sweetdream_floor:reward/check_tag {tag:"formation",name:"术阵"}
function sweetdream_floor:reward/check_tag {tag:"timestop",name:"时停"}
function sweetdream_floor:reward/check_tag {tag:"freeze",name:"冰冻"}
function sweetdream_floor:reward/check_tag {tag:"slow",name:"缓速"}
function sweetdream_floor:reward/check_tag {tag:"lightning",name:"闪电"}
execute unless data storage sweetdream_floor:run options[0] if data storage sweetdream_floor:run {battle_draw:1b} run return run function sweetdream_floor:reward/empty_battle_pool
execute unless data storage sweetdream_floor:run options[0] if data storage sweetdream_floor:run exact_tier run return run function sweetdream_floor:reward/offer
function sweetdream_floor:reward/sample
# dup-ok: choose three distinct elements by removing each sampled option.
function sweetdream_floor:reward/sample
function sweetdream_floor:reward/sample
function sweetdream_floor:reward/show
