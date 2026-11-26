$function sweetdream_floor:pool/filter {tag:"$(tag)"}
$execute if data storage sweetdream_floor:run pool[0] run data modify storage sweetdream_floor:run options append value {tag:"$(tag)",name:"$(name)"}
