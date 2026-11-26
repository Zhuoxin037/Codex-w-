"""Rebase the standalone map on the current Fallendream and ManaCore packs."""

import json
import hashlib
import msvcrt
import os
from pathlib import Path
import re
import shutil
from zipfile import ZipFile, ZIP_DEFLATED

import dream_entry_art as art
from dream_gear import training_catalog
from dream_hub import rename_level
from dream_save_data import dat, region, renamed
from floor_upgrade import DIM, include_dimension, text, write
from forest_economy import FN, POOL, REFUNDS, WEAPONS, literal
from forest_floors import NEXT
from forest_minimum import stage as minimum_damage
from forest_new_events import stage as new_events
from forest_new_mobs import stage as new_mobs
from forest_stag import stage as forest_boss
from forest_runtime_fixes import stage as runtime_fixes
from forest_combat_clock import stage as combat_clock
from forest_playtest import stage as forest_playtest
from forest_combat import update_resin_range
from forest_god_rewards import stage as god_rewards
from forest_services import remove_echo
from forest_talents import stage as talent_stage
from forest_session_fixes import stage as session_fixes
from forest_map_icons import stage as map_icons
from training_world import TRAINING_DIM
from world import ROOT

PRIMARY="fallendream"
MANA="manacore-1.0.0"
ADDON="zz_sweetdream_floor"
RP=ROOT/"fallendream_rp_完整版"
LEGACY=ROOT/"outputs/01a1f2ce-e657-7782-ac13-28be248b8f29/坠梦_密林战斗与通路修正版.zip"
WORK=ROOT/".workbuddy/rogue_fallendream_sync_20261124"
ZIP=LEGACY.with_name("坠梦_新版数据包同步版.zip")
LIVE=Path("D:/PCL 正式版 2.10.0/.minecraft/versions/1.21.5-Fabric 0.16.10/saves/甜梦回廊·密林")


def catalog(f, source):
    entries={}
    grants={}
    for file in sorted((source/"equipment").glob("*/*/give.mcfunction")):
        category,item,_ = file.relative_to(source/"equipment").parts
        if category not in {*WEAPONS,"armor","tool","offhand"}:
            continue
        give=next((row for row in text(file).splitlines() if row.startswith("give @s ")),None)
        if not give:
            continue
        meta=re.search(r'minecraft:custom_data=(\{[^{}]*zx:\[[^][]*\][^{}]*\})|(?<!:)custom_data=(\{[^{}]*zx:\[[^][]*\][^{}]*\})',give)
        if not meta:
            continue
        meta=meta[1] or meta[2]
        name=re.search(r'item_name=(?:\{\s*"?text"?\s*:\s*)?("(?:[^"\\]|\\.)*")',give)
        if not name:
            continue
        profession=re.search(r"profession:(\d+)",meta)
        rarity=re.search(r'rarity:"t([1-5])"',meta)
        tags=re.search(r'tags:(\[[^]]*\])',meta)
        group="weapon" if category in WEAPONS else "offhand" if category in ("tool","offhand") and item!="look" else category
        rank=int(rarity[1]) if rarity else 1
        record={"id":item,"category":category,"job":int(profession[1]) if profession else 0,
                "tier":rank,"tags":json.loads(tags[1]) if tags else [],
                "fn":f"fallendream:equipment/{category}/{item}/give","name":json.loads(name[1]),"group":group,
                "raw_refund":5 if group=="offhand" else REFUNDS[rank-1],
                "signed":FN+f"market/items/{item}"}
        if item in entries:
            raise ValueError(f"Duplicate equipment id: {item}")
        entries[item]=record
        grants[item]=(give,text(file))

    def mc(path,*rows):
        write(f/f"{path}.mcfunction","\n".join(rows))

    old_pool=f/"pool/load.mcfunction"
    old_rows=[json.loads(row.split(" entries append value ",1)[1]) for row in text(old_pool).splitlines() if " entries append value " in row]
    assert len(entries) >= len(old_rows)-4, (len(entries),len(old_rows))
    mc("pool/load",f"data modify storage {POOL} entries set value []",
       *(f"data modify storage {POOL} entries append value "+literal(e) for e in entries.values()),f"function {FN}market/load")
    tags=set(re.findall(r'check_tag \{tag:"(\w+)"',text(f/"reward/open.mcfunction")))
    support=[{"job":job,"group":group,**{f"t{e['tier']}":1 for e in entries.values()
               if group==e["group"] and e["job"] in (0,job) and tags.intersection(e["tags"])}}
             for job in range(5) for group in ("weapon","armor")]
    bank=f/"market/load.mcfunction"
    rows=text(bank).splitlines()
    upgrades=json.loads(next(row for row in rows if " upgrades set value " in row).split(" set value ",1)[1])
    mc("market/load",f"data modify storage {POOL} upgrades set value "+literal(upgrades),
       f"data modify storage {POOL} support set value "+literal(support))
    for item,entry in entries.items():
        if entry["group"] not in ("weapon","armor","offhand"):
            continue
        give,body=grants[item]
        market_copy(mc,item,give,body,entry["group"]=="weapon")
    for u in upgrades:
        name=u["id"]
        file=source/f"upgrade/item/{name}.mcfunction"
        body=text(file)
        market_copy(mc,name,next(row for row in body.splitlines() if row.startswith("give @s ")),body,False)
    for file in (source/"upgrade/item").glob("*_b.mcfunction"):
        body=text(file)
        market_copy(mc,file.stem,next(row for row in body.splitlines() if row.startswith("give @s ")),body,False)

    route=f/"lobby/practice/route.mcfunction"
    old=text(route).splitlines()
    ids={m[2]:int(m[1]) for row in old
         if (m:=re.search(r'matches (\d+) run return run give @s .*?\bzx:\["([^"]+)"',row))}
    next_code=max(ids.values())+1
    rows=[row for row in old if " run return run give @s " not in row]
    for item,entry in entries.items():
        if entry["group"] not in ("weapon","armor","offhand"):
            continue
        code=ids.get(item)
        if code is None:
            code=next_code
            next_code+=1
        give=grants[item][0].replace("custom_data={","custom_data={sd_training:1b,",1)
        rows.append(f"execute if score #input sd.floor matches {code} run return run {give}")
    write(route,"\n".join(rows))
    training_catalog(mc,f)
    known=set(entries)
    outdated=sorted({e["id"] for e in old_rows}-known)
    print(f"Latest equipment catalog: {len(entries)} records. Retired entries: {outdated}",flush=True)


def market_copy(mc,item,give,body,rental):
    stock=give.replace("custom_data={","custom_data={sd_floor_refund:$(refund),",1)
    mc(f"market/items/{item}",*("$"+stock if row==give else row for row in body.splitlines() if row and not row.startswith("#")))
    payload=give.removeprefix("give @s ").removesuffix(" 1")
    mc(f"market/preview/{item}","item replace entity @s contents with "+payload)
    if rental:
        mc(f"rental/items/{item}",give.replace("custom_data={","custom_data={sd_rental:1b,",1))


def write_overrides(addon, base, old):
    src=base/"data/fallendream/function"
    dest=addon/"data/fallendream/function"
    legacy_rogue=old/"data/sweetdream/function/rogue"
    for file in legacy_rogue.rglob("*.mcfunction"):
        p=dest/"rogue"/file.relative_to(legacy_rogue)
        if not p.exists():
            write(p,renamed(text(file)))
    old_dim=old/"data/sweetdream/dimension/rogue_preview.json"
    if old_dim.exists():
        write(addon/"data/sweetdream/dimension/rogue_preview.json",renamed(text(old_dim)))
    hooks={
       "core/tick.mcfunction":'execute as @a[tag=test_look_on] run function fallendream:equipment/tool/look/render',
       "lib/second.mcfunction":'execute as @a[tag=test_look_on] run function fallendream:equipment/tool/look/cache',
       "equipment/tool/look/render_go.mcfunction":'data modify storage zx:look xline set value [{"text":""}]',
    }
    for file in src.rglob("*.mcfunction"):
        rel=file.relative_to(src)
        if rel.parts[0] in ("debug","rogue"):
            continue
        body=text(file)
        if "in minecraft:the_end " in body:
            body,number=include_dimension(body)
            if number:
                rows=[]
                for line in body.splitlines():
                    rows.append(line)
                    if line.startswith(("execute ","$execute ")) and f" in {DIM} " in line:
                        rows.extend(line.replace(f" in {DIM} ",f" in {dim} ") for dim in (NEXT,TRAINING_DIM))
                write(dest/rel,"\n".join(rows))
        if (hook:=hooks.get(rel.as_posix())):
            assert body.count(hook)==1,rel
            tweak=(hook.replace("tag=test_look_on","tag=sd.floor_hud,tag=!test_look_on")
                   if rel.as_posix()!="equipment/tool/look/render_go.mcfunction" else
                   f"execute if entity @s[tag=sd.floor_hud] run function {FN}run/mirror_text")
            existing=dest/rel
            latest=text(existing) if existing.exists() else body
            write(existing,latest.replace(hook,hook+"\n"+tweak))
    for file, swaps in {
        "bind": {"Health:800f":"Health:200f","base:800d":"base:200d"},
        "bar_create":{"max 800":"max 200"}, "init_body":{"sdk.last_hp 800000":"sdk.last_hp 200000"},
        "dispatch":{"sdk.hp matches ..400":"sdk.hp matches ..100"},
    }.items():
        p=src/f"boss/knight/{file}.mcfunction"
        body=text(p)
        for k,v in swaps.items():
            assert k in body,(p,k)
            body=body.replace(k,v,1)
        write(dest/f"boss/knight/{file}.mcfunction",body)


def resources(old,dest):
    paths={p.relative_to(RP).as_posix():p for p in RP.rglob("*")
           if p.is_file() and (p.is_relative_to(RP/"assets") or p.name in ("pack.mcmeta","pack.png"))}
    with ZipFile(old) as archive,ZipFile(dest,"w",ZIP_DEFLATED,compresslevel=3) as out:
        legacy={}
        for entry in archive.infolist():
            if entry.is_dir() or not entry.filename.startswith("assets/"):
                continue
            name=renamed(entry.filename)
            if name not in paths:
                raw=archive.read(entry)
                legacy[name]=renamed(raw.decode("utf-8")).encode() if name.endswith(".json") else raw
        for name,raw in legacy.items():
            out.writestr(name,raw)
        for name,file in paths.items():
            out.write(file,name)
    print(f"Resources: {len(paths)} current files and {len(legacy)} map resources.",flush=True)


def stage(old,dest):
    src=old/"datapacks"
    target=dest/"datapacks"
    for pack in (PRIMARY,MANA):
        shutil.copytree(ROOT/pack,target/pack,dirs_exist_ok=True)
    addon=target/ADDON
    for file in (src/ADDON).rglob("*"):
        if not file.is_file():
            continue
        rel=file.relative_to(src/ADDON)
        parts=rel.parts
        if parts[0]=="data" and parts[1] in ("sweetdream","fallendream") and parts[2]=="function":
            if parts[3]!="rogue":
                continue
            rel=Path("data","fallendream",*parts[2:])
        p=addon/rel
        write(p,renamed(text(file)))
    other=src/"家具数据包"
    if other.exists():
        shutil.copytree(other,target/other.name,dirs_exist_ok=True)
    write_overrides(addon,target/PRIMARY,src/"sweetdream")
    floor=addon/"data/sweetdream_floor/function"
    art.entry_ui(floor)
    art.shrub_functions(floor)
    catalog(floor,target/PRIMARY/"data/fallendream/function")
    new_events(dest)
    new_mobs(dest)
    minimum_damage(dest)
    forest_boss(dest, RP)
    runtime_fixes(dest)
    combat_clock(dest)
    forest_playtest(dest)
    update_resin_range(dest)
    if not (floor/"astrology/grant_30.mcfunction").exists():
        god_rewards(dest)
    remove_echo(dest)
    talent_stage(dest)
    session_fixes(dest)
    map_icons(dest)
    for name,raw in art.bake_assets().items():
        p=RP/name
        p.parent.mkdir(parents=True,exist_ok=True)
        if not p.exists() or p.read_bytes()!=raw:
            p.write_bytes(raw)
    old_rp=old/"resources.zip"
    if not old_rp.exists():
        old_rp=WORK/"legacy_resources.zip"
        if not old_rp.exists():
            with ZipFile(LEGACY) as archive:
                key=next(name for name in archive.namelist() if name.endswith("/resources.zip"))
                old_rp.write_bytes(archive.read(key))
    resources(old_rp,dest/"resources.zip")
    copy_save_state(old,dest)


def copy_save_state(old,dest):
    src=old/"datapacks"
    for file in old.rglob("*"):
        if not file.is_file() or file.is_relative_to(src):
            continue
        rel=file.relative_to(old)
        if file.name in ("resources.zip","session.lock"):
            continue
        out=dest/rel.with_name(renamed(rel.name))
        out.parent.mkdir(parents=True,exist_ok=True)
        raw=file.read_bytes()
        if file.suffix==".mca":
            raw=region(raw)
        elif raw.startswith(b"\x1f\x8b") and (file.suffix==".dat" or file.name=="level.dat_old"):
            raw=dat(raw)
            if rel==Path("level.dat"):
                raw=rename_level(raw)
        elif file.suffix==".json" and rel.parts[0] in ("stats","advancements"):
            raw=renamed(raw.decode("utf-8")).encode()
        out.write_bytes(raw)


def digest(path):
    with path.open("rb") as source:
        return hashlib.file_digest(source,"sha256").hexdigest()


def publish(candidate):
    from forest_revision_release import unpack
    seed=WORK/"clean_seed"
    starter=WORK/"clean_release"
    unpack(LEGACY,seed)
    copy_save_state(seed,starter)
    records=[]
    for path in starter.rglob("*"):
        if path.is_file():
            records.append((path,path.relative_to(starter).as_posix()))
    for pack in (PRIMARY,MANA,ADDON):
        root=candidate/"datapacks"/pack
        records.extend((path,path.relative_to(candidate).as_posix()) for path in root.rglob("*") if path.is_file())
    records.append((candidate/"resources.zip","resources.zip"))
    temp=WORK/"archive_verified.zip"
    with ZipFile(temp,"w",ZIP_DEFLATED,compresslevel=3) as out:
        for source,name in records:
            assert not name.startswith(("playerdata/","stats/","advancements/")),name
            out.write(source,"坠梦/"+name)
    with ZipFile(temp) as out:
        assert out.testzip() is None
        assert "坠梦/datapacks/fallendream/pack.mcmeta" in out.namelist()
        assert not any("/datapacks/sweetdream/" in name for name in out.namelist())
    os.replace(temp,ZIP)
    print(f"Archive verified: {ZIP.name} · {len(records)} entries · {digest(ZIP)}",flush=True)


def install():
    """Commit verified files in place; keep a full inverse for every changed path."""
    live=LIVE.resolve(strict=True)
    assert live.parent.name=="saves" and (live/"level.dat").is_file()
    work=WORK.resolve()
    assert work.is_relative_to(ROOT.resolve()) and not work.is_relative_to(live)
    candidate=work/"install_candidate"
    backup=work/"before_sync"
    if backup.exists():
        raise FileExistsError(backup)
    backup.mkdir()
    moves=[]
    wrote=[]
    with (live/"session.lock").open("r+b") as lock:
        msvcrt.locking(lock.fileno(),msvcrt.LK_NBLCK,3)
        stage(live,candidate)
        manifests={}
        for pack in (PRIMARY,MANA,ADDON):
            scope=candidate/"datapacks"/pack
            manifests[pack]={path.relative_to(scope):digest(path) for path in scope.rglob("*") if path.is_file()}
        files={}
        for path in candidate.rglob("*"):
            if not path.is_file() or path.is_relative_to(candidate/"datapacks"):
                continue
            rel=path.relative_to(candidate)
            dst=(live/rel).resolve()
            dst.relative_to(live)
            if not dst.exists() or digest(dst)!=digest(path):
                files[rel]=digest(path)
        retired=[]
        for name in ("command_storage_sweetdream.dat","command_storage_sweetdream_boss.dat"):
            rel=Path("data")/name
            if (live/rel).exists():
                retired.append(rel)

        def save_existing(relative):
            old=(live/relative).resolve()
            old.relative_to(live)
            dst=(backup/relative).resolve()
            dst.relative_to(backup)
            if old.exists():
                dst.parent.mkdir(parents=True,exist_ok=True)
                os.replace(old,dst)
                moves.append((old,dst))

        def put_candidate(relative):
            source=(candidate/relative).resolve()
            source.relative_to(candidate)
            target=(live/relative).resolve()
            target.relative_to(live)
            target.parent.mkdir(parents=True,exist_ok=True)
            os.replace(source,target)
            wrote.append((source,target))

        try:
            for pack in ("sweetdream",PRIMARY,MANA,ADDON):
                save_existing(Path("datapacks")/pack)
            for pack in (PRIMARY,MANA,ADDON):
                put_candidate(Path("datapacks")/pack)
            for rel in retired:
                save_existing(rel)
            for rel in files:
                save_existing(rel)
                put_candidate(rel)
            for pack,items in manifests.items():
                current=live/"datapacks"/pack
                assert len(list(p for p in current.rglob("*") if p.is_file()))==len(items),pack
                for rel,value in items.items():
                    assert digest(current/rel)==value,rel
            for rel,value in files.items():
                assert digest(live/rel)==value,rel
        except BaseException:
            for source,dest in reversed(wrote):
                os.replace(dest,source)
            for original,saved in reversed(moves):
                os.replace(saved,original)
            raise
    receipt={"target":str(live),"files":len(files),"packs":{k:len(v) for k,v in manifests.items()},
             "backup":str(backup)}
    (work/"installed.json").write_text(json.dumps(receipt,ensure_ascii=False,indent=2),encoding="utf8")
    print(receipt,flush=True)


if __name__=="__main__":
    import argparse
    cli=argparse.ArgumentParser()
    cli.add_argument("operation",choices=("stage","publish","install"))
    cli.add_argument("directory",type=Path,nargs="?")
    args=cli.parse_args()
    if args.operation=="stage":
        stage(LIVE,args.directory)
    elif args.operation=="publish":
        publish(args.directory)
    else:
        install()
