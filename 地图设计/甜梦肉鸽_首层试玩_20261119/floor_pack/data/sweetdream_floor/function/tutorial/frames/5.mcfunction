execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/pose {right:0,left:0,turn:0}
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/cue {line:"最大魔力值变动 100 → 200",color:"aqua"}
execute if score #edu_frame sd.floor matches 26 run function sweetdream_floor:tutorial/stage/pose {right:-101,left:0,turn:-15}
execute if score #edu_frame sd.floor matches 26 run function sweetdream_floor:tutorial/stage/cue {line:"潮痕使用技能",color:"aqua"}
execute if score #edu_frame sd.floor matches 40 run function sweetdream_floor:tutorial/stage/pose {right:-45,left:0,turn:12}
execute if score #edu_frame sd.floor matches 40 run function sweetdream_floor:tutorial/stage/bolt
execute if score #edu_frame sd.floor matches 40 run function sweetdream_floor:tutorial/stage/impact
execute if score #edu_frame sd.floor matches 40 run function sweetdream_floor:tutorial/stage/cue {line:"计算值从 8 到 16",color:"gold"}
execute if score #edu_frame sd.floor matches 71 run function sweetdream_floor:tutorial/stage/pose {right:0,left:0,turn:0}
