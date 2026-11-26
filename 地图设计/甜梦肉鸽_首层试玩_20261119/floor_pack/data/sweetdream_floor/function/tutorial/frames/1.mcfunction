execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/pose {right:0,left:0,turn:0}
execute if score #edu_frame sd.floor matches 1 run function sweetdream_floor:tutorial/stage/cue {line:"潮痕就绪",color:"aqua"}
execute if score #edu_frame sd.floor matches 17 run function sweetdream_floor:tutorial/stage/pose {right:-112,left:0,turn:-12}
execute if score #edu_frame sd.floor matches 17 run function sweetdream_floor:tutorial/stage/cue {line:"右键施法",color:"aqua"}
execute if score #edu_frame sd.floor matches 24 run function sweetdream_floor:tutorial/stage/pose {right:-53,left:0,turn:14}
execute if score #edu_frame sd.floor matches 24 run function sweetdream_floor:tutorial/stage/bolt
execute if score #edu_frame sd.floor matches 24 run function sweetdream_floor:tutorial/stage/impact
execute if score #edu_frame sd.floor matches 24 run function sweetdream_floor:tutorial/stage/cue {line:"技能进入冷却",color:"gold"}
execute if score #edu_frame sd.floor matches 50 run function sweetdream_floor:tutorial/stage/pose {right:0,left:0,turn:0}
