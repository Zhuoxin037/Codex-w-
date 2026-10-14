# 烈火残躯：动画帧及本人施法快照；伤害由动画命中帧驱动。
execute unless data storage zx:config obj_zx_fb_frame run scoreboard objectives add zx.fb_frame dummy
execute unless data storage zx:config obj_zx_fb_frame run data modify storage zx:config obj_zx_fb_frame set value 1b
execute unless data storage zx:config obj_zx_fb_mode run scoreboard objectives add zx.fb_mode dummy
execute unless data storage zx:config obj_zx_fb_mode run data modify storage zx:config obj_zx_fb_mode set value 1b
execute unless data storage zx:config obj_zx_fb_hand run scoreboard objectives add zx.fb_hand dummy
execute unless data storage zx:config obj_zx_fb_hand run data modify storage zx:config obj_zx_fb_hand set value 1b
execute unless data storage zx:config obj_zx_fb_slot run scoreboard objectives add zx.fb_slot dummy
execute unless data storage zx:config obj_zx_fb_slot run data modify storage zx:config obj_zx_fb_slot set value 1b
execute unless data storage zx:config obj_zx_fb_until run scoreboard objectives add zx.fb_until dummy
execute unless data storage zx:config obj_zx_fb_until run data modify storage zx:config obj_zx_fb_until set value 1b
execute unless data storage zx:config obj_zx_fb_dim run scoreboard objectives add zx.fb_dim dummy
execute unless data storage zx:config obj_zx_fb_dim run data modify storage zx:config obj_zx_fb_dim set value 1b
execute unless data storage zx:config obj_zx_fb_fx_t run scoreboard objectives add zx.fb_fx_t dummy
execute unless data storage zx:config obj_zx_fb_fx_t run data modify storage zx:config obj_zx_fb_fx_t set value 1b
data modify storage zx:fbvis frames set value [{"translation":[0.0f,0.435f,0.0f],"scale":[3.74f,6.8f,3.74f],"left_rotation":[0,0.0f,0,1.0f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[-0.0f,0.4934375f,-0.0f],"scale":[4.505f,6.8f,4.505f],"left_rotation":[0,-0.19509032f,0,0.98078528f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[0.0f,0.5625f,0.0f],"scale":[5.44f,6.8f,5.44f],"left_rotation":[0,-0.38268343f,0,0.92387953f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[0.0f,0.605f,-0.0f],"scale":[6.20075f,6.8f,6.20075f],"left_rotation":[0,-0.65275975f,0,0.75756498f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[-0.0f,0.6475f,-0.0f],"scale":[6.8f,6.8f,6.8f],"left_rotation":[0,-0.8571673f,0,0.51503807f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[0.0f,0.71125f,0.0f],"scale":[7.072f,6.8f,7.072f],"left_rotation":[0,-0.98699637f,0,0.16074257f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[-0.0f,0.775f,0.0f],"scale":[7.208f,6.8f,7.208f],"left_rotation":[0,0.97629601f,0,0.21643961f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[-0.0f,0.82015625f,0.0f],"scale":[7.3695f,6.8f,7.3695f],"left_rotation":[0,0.83146961f,0,0.55557023f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[0.0f,0.86f,0.0f],"scale":[7.48f,6.8f,7.48f],"left_rotation":[0,0.57357644f,0,0.81915204f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[0.0f,0.9025f,0.0f],"scale":[7.497f,6.8f,7.497f],"left_rotation":[0,0.3007058f,0,0.95371695f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[0.0f,0.945f,0.0f],"scale":[7.48f,6.8f,7.48f],"left_rotation":[0,0.0f,0,1.0f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[0.0f,0.9928125f,0.0f],"scale":[7.48f,6.8f,7.48f],"left_rotation":[0,0.0f,0,1.0f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]},{"translation":[0.0f,1.03f,0.0f],"scale":[7.48f,6.8f,7.48f],"left_rotation":[0,0.0f,0,1.0f],"right_rotation":[0.0f,0.0f,0.0f,1.0f]}]
execute as @a[tag=zx.fb_cast] at @s run function sweetdream:equipment/sword/flame_brokenbody/visual/end
execute in minecraft:overworld run kill @e[type=minecraft:item_display,tag=zx.fb_fx,distance=0..]
execute in minecraft:the_nether run kill @e[type=minecraft:item_display,tag=zx.fb_fx,distance=0..]
execute in minecraft:the_end run kill @e[type=minecraft:item_display,tag=zx.fb_fx,distance=0..]
execute unless data storage zx:config obj_zx_fb_ol run scoreboard objectives add zx.fb_ol dummy
execute unless data storage zx:config obj_zx_fb_ol run data modify storage zx:config obj_zx_fb_ol set value 1b
execute unless data storage zx:config obj_zx_fb_refresh run scoreboard objectives add zx.fb_refresh dummy
execute unless data storage zx:config obj_zx_fb_refresh run data modify storage zx:config obj_zx_fb_refresh set value 1b
# reload 后不保留离线会话的施法快照。
data remove storage zx:fbcombat p
