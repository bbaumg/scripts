#!/bin/bash
#  
#  This contains all of the funtions used by other parts of the scripting system.

logger () { 
  echo -e "\n==============================================================================\n$(date)  $1" | tee -a $v_log
}
