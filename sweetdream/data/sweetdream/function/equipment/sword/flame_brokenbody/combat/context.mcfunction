function sweetdream:lib/uuid
data modify storage zx:fbcombat ctx set value {uuid:""}
data modify storage zx:fbcombat ctx.uuid set from storage zx:data self.uuid
