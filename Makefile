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
	curl https://download.geofabrik.de/australia-oceania-latest.osm.pbf -o $(pbf)

## install osmosis binaries
osmosis:
	mkdir -p osmosis
	curl -s https://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz | tar -xv -C osmosis

$(output_dir):
	mkdir output

## extract xml from pbf
extract-xml: osmosis $(output_dir) $(pbf)
	parallel -a OSMFeaturesSet_POInty.csv --colsep ',' echo {1}.{2}
	#osmosis/bin/osmosis --read-pbf $(pbf) --node-key-value keyValueList="amenity.atm" --write-xml $(output_dir)/atm.xml

## install dependencies needed if running on Mac OS X
deps-mac:
	brew install parallel