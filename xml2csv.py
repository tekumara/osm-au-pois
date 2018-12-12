#!/usr/bin/env python

import argparse
import json
import sys

import xmltodict


def convert(filepath):
    print(filepath, file=sys.stderr)
    with open(filepath, 'rb') as xmlfile:
        osm = xmltodict.parse(xmlfile)
        print(json.dumps(osm, indent=4))
        nodes = osm["osm"].get("node", None)
        if nodes:
            nodes_list = nodes if isinstance(nodes, list) else [nodes]
            for node in nodes_list:
                print("""{},{},"{}",{},{}""".format(category(filepath), node["@id"], name(node["tag"]), node["@lat"],
                                                    node["@lon"]))


def category(filepath):
    return filepath[filepath.rfind("/") + 1:].replace(".xml", "")


def name(tags):
    if isinstance(tags, list):
        for tag in tags:
            if tag["@k"] == "name":
                return tag["@v"]
    elif isinstance(tags, dict):
        if tags["@k"] == "name":
            return tags["@v"]
    return ""


def main():
    parser = argparse.ArgumentParser(description="Print OpenStreetMap XML as CSV",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("xml_file", help="Input OSM XML file")
    args = parser.parse_args()

    convert(args.xml_file)


if __name__ == "__main__":
    main()
