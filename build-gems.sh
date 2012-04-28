#!/bin/bash

FPM=/usr/bin/fpm

if [ ! -d BUILD ]
then
  mkdir -p BUILD
fi

for gem in `cat gem-list | grep -v "#" `
do
  version=`echo $gem | awk -F':' '{print $2}'`
  basename=`echo $gem | awk -F':' '{print $1}'`
  cd BUILD
  if [ x$version == 'x' ]; then
    version=`gem list -r $basename | grep "^$basename " | sed "s/.*(\([0-9.]*\).*/\1/"`
  fi

  gembuilddir="gembuild/${basename}/${version}"
  donefile="${gembuilddir}/done"

  if [ -e $donefile ]; then
    echo "Already exists, skipping: $basename-$version"
    RETVAL=0
  else
    if [ ! -d $gembuilddir ]; then
      mkdir -p $gembuilddir
    fi

    echo "Finding dependencies for $basename-$version"
    echo 

    gem install --no-ri --no-rdoc --install-dir $gembuilddir -v $version $basename

    GEMRETVAL=$?
    echo "Gem install returned with $GEMRETVAL"
    [ $GEMRETVAL -ne 0 ] && exit 1

    for g in `ls -1 ${gembuilddir}/cache`
    do
      echo "Building ${g}"
      echo 
      ${FPM} -s gem -t rpm ${gembuilddir}/cache/${g}
      RETVAL=$?
    done
  
    echo "Build of $basename returned with $RETVAL"
    echo 
    [ $RETVAL -ne 0 ] && exit 1
  fi
  
  touch $donefile  
  cd ../

done
