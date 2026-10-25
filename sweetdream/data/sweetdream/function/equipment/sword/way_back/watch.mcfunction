# owner key may be absent on an old lamp: delete it rather than orphaning it.
execute unless data entity @s data.wb.uuid run return run kill @s
function sweetdream:equipment/sword/way_back/watch_go with entity @s data.wb
