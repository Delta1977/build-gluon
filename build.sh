#!/bin/bash

# Populate variables with default values

BROKEN=0 # -b
DIRCLEAN=0 # -d
GLUON_BRANCH=v2017.1.x # -g
GLUON_GIT=https://github.com/freifunk-gluon/gluon.git
GLUON_RELEASE=v2017.1.5 # -r
GLUON_TARGET=ar71xx-tiny # -t
GLUON_VERSION= # -v
LEDE_DIR=$(pwd)/lede # -l
OUTPUT_DIR=$(pwd)/output # -o
SITE_BRANCH=v2017.1-tdf # -z
SITE_GIT=https://github.com/Freifunk-Troisdorf/site.git # -s
JOBS=$(grep -c processor /proc/cpuinfo) # -j


# Process flags

while getopts ":bdg:j:l:o:r:s:t:v:z:" opt; do
  case $opt in
    b)
      BROKEN=1
      ;;
    d)
      DIRCLEAN=1
      ;;
    g)
      GLUON_BRANCH="$OPTARG"
      ;;
    j)
      JOBS="$OPTARG"
      ;;
    l)
      LEDE_DIR="$OPTARG"
      ;;
    o)
      OUTPUT_DIR="$OPTARG"
      ;;
    r)
      GLUON_RELEASE="$OPTARG"
      ;;
    s)
      SITE_GIT="$OPTARG"
      ;;
    t)
      GLUON_TARGET="$OPTARG"
      ;;
    v)
      GLUON_VERSION="$OPTARG"
      ;;
    z)
      SITE_BRANCH="$OPTARG"
      ;;
   \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Build Gluon, if build fails try again with -j 1 and V=s for debugging purposes
docker run --rm -a STDOUT -a STDERR -v $LEDE_DIR:/gluon/lede -v $OUTPUT_DIR:/gluon/output -w /gluon handle/build-gluon /bin/bash -c "git checkout $GLUON_BRANCH; git pull; git clone $SITE_GIT -b $SITE_BRANCH /gluon/site; $([[ $DIRCLEAN = 1 ]] && echo "make -C lede dirclean;") make update GLUON_RELEASE=$GLUON_RELEASE; make -j $JOBS GLUON_TARGET=$GLUON_TARGET GLUON_RELEASE=$GLUON_RELEASE $([[ $GLUON_VERSION ]] && echo "GLUON_VERSION=$GLUON_VERSION") $([[ $BROKEN = 1 ]] && echo "BROKEN=1") 2>&1 || make -j 1 GLUON_TARGET=\"$GLUON_TARGET\" GLUON_RELEASE=$GLUON_RELEASE $([[ $GLUON_VERSION ]] && echo "GLUON_VERSION=$GLUON_VERSION") $([[ $BROKEN = 1 ]] && echo "BROKEN=1") V=s 2>&1"
