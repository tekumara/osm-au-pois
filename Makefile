MAKEFLAGS += --warn-undefined-variables
.DEFAULT_GOAL := help

## display this help message
help:
	@awk '/^##.*$$/,/^[~\/\.a-zA-Z_-]+:/' $(MAKEFILE_LIST) | awk '!(NR%2){print $$0p}{p=$$0}' | awk 'BEGIN {FS = ":.*?##"}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' | sort

pbf := pbf/australia-oceania-latest.osm.pbf
output_dir := output

## download pbf (~600Mb)
download-pbf: $(pbf)

$(pbf):
	mkdir -p pbf
	curl https://download.geofabrik.de/australia-oceania-latest.osm.pbf -o $(pbf)

## install osmosis binaries
osmosis:
	mkdir -p osmosis
	curl -s https://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz | tar -xvz -C osmosis

$(output_dir):
	mkdir output

## extract xml from pbf
extract-xml: osmosis $(output_dir) $(pbf)
	parallel -a OSMFeaturesSet_POInty.csv --colsep ',' osmosis/bin/osmosis --read-pbf $(pbf) --node-key-value keyValueList="{1}.{2}" --write-xml $(output_dir)/{1}.{2}.xml

## install dependencies needed if running on Mac OS X
deps-mac:
	brew install parallel
