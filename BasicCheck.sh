#! /bin/bash
path=$1
file=$2
cd $path
# Run compilation of makefile
make
comp=$?
if (($comp > 0))
then 
  echo "COMPILIATION    MEMORY LEAKS    THREAD RACE"
  echo "   FAIL           FAIL             FAIL"
  # echo "7"
  exit 7
fi
# Run valgrind for memory leaks 
valgrind --leak-check=full --error-exitcode=1 ./$file
valg=$?
echo "valgrind exitcode is $valg"
if (($valg > 0))
then 
  valg=2
fi

# Run helgrind to check for thread races
valgrind --tool=helgrind --error-exitcode=1 ./$file
helg=$?
# echo "helgrind exitcode is $helg"
if (($helg > 0))
then 
  if(($valg==2))
  then
    helg=3
  else
  helg=1
  fi
else 
  if(($valg>0))
  then 
  helg=2
  else
  helg=0
  fi
fi

# echo $helg
# Print out what passed and failed
if (($helg==0))
then
  echo "COMPILIATION    MEMORY LEAKS    THREAD RACE"
  echo "   PASS           PASS             PASS"
  exit 0
fi
if (($helg==1))
then
  echo "COMPILIATION    MEMORY LEAKS    THREAD RACE"
  echo "   PASS           PASS             FAIL"
  exit 1
fi
if (($helg==2))
then
  echo "COMPILIATION    MEMORY LEAKS    THREAD RACE"
  echo "   PASS           FAIL             PASS"
  exit 2
fi
if (($helg==3))
then
  echo "COMPILIATION    MEMORY LEAKS    THREAD RACE"
  echo "   PASS           FAIL             FAIL"
  exit 3
fi
