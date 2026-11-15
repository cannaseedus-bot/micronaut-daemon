#!/usr/bin/env python3
"""Lower the compiled BSON bank into the native daemon's line-oriented runtime index."""
from __future__ import annotations
import argparse, json, re, sys
import xml.etree.ElementTree as ET
from pathlib import Path
from bson import BSON

MANIFEST = "micronaut.aiml.manifest.v1"
SOURCE = "micronaut.aiml.source.v1"
CATEGORY = "micronaut.aiml.category.v1"
SCHEMA = "micronaut.aiml.corpus.v2"


def node(el):
    content = [el.text] if el.text else []
    for child in list(el):
        content.append(node(child))
        if child.tail: content.append(child.tail)
    return {"tag": el.tag.rsplit("}",1)[-1].lower(),
            "attrs": {k.rsplit("}",1)[-1].lower():v for k,v in el.attrib.items()},
            "content": content}


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--bank",type=Path,required=True)
    ap.add_argument("--output",type=Path,required=True)
    a=ap.parse_args()
    bank=BSON(a.bank.read_bytes()).decode()
    categories=[]
    def append(pattern, response, that="", topic=""):
        try: template=ET.fromstring(f"<template>{response}</template>")
        except ET.ParseError: template=ET.Element("template");template.text=response
        p=ET.Element("pattern");p.text=pattern
        nodes=[node(p),node(template)]
        if that:
            t=ET.Element("that");t.text=that;nodes.insert(1,node(t))
        categories.append({"source":0,"source_path":a.bank.name,"source_category":len(categories),
                           "pattern":pattern,"that":that,"topic":topic,"nodes":nodes})
    for pattern,response in sorted(bank.get("exact",{}).items()): append(pattern,response)
    for item in bank.get("wild",[]): append(item.get("pattern",""),item.get("template",""),item.get("that") or "",item.get("topic") or "")
    for key,response in sorted(bank.get("topic",{}).items()):
        parts=key.split("|",1);append(parts[0],response,topic=parts[1] if len(parts)>1 else "")
    for key,response in sorted(bank.get("that",{}).items()):
        parts=key.split("|",1);append(parts[0],response,that=parts[1] if len(parts)>1 else "")
    a.output.parent.mkdir(parents=True,exist_ok=True)
    with a.output.open("w",encoding="utf-8",newline="\n") as out:
        out.write(json.dumps({"@kind":MANIFEST,"schema":SCHEMA,"source_count":1,"category_count":len(categories)},ensure_ascii=False,separators=(",",":"))+"\n")
        out.write(json.dumps({"@kind":SOURCE,"index":0,"path":a.bank.name,"text":""},ensure_ascii=False,separators=(",",":"))+"\n")
        for i,record in enumerate(categories):
            record["index"]=i
            out.write(json.dumps({"@kind":CATEGORY,"index":i,"record":record},ensure_ascii=False,separators=(",",":"))+"\n")
    print(f"runtime index: {a.output} ({len(categories)} categories)")


if __name__=="__main__": raise SystemExit(main())
