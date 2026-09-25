advancement revoke @s only test:itemreplace_mainhand
function test:uuid
execute unless data storage test:data self{ok:1b} run return fail

data modify storage test:work a.uuid set from storage test:data self.uuid
function test:itemreplace_mainhand_2 with storage test:work a