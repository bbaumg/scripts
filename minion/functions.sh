#!/bin/bash
#  
#  This contains all of the funtions used by other parts of the scripting system.

logger () { 
  echo -e "$(date)  $1" | tee -a $2
}
