#!/bin/bash

REPLY_RATE=2
REGEX_CAPTURE="^(?P<req>\?RL?R?) (?P<pre>(\S+[ ]+)*)(?P<name>(nr|nightred|tase)[^ \n]*)(?P<post>[ ]?.*)"
REGEX_REPLACE='?RR \g<pre>\g<post>'
REPLACE_NAMES_WITH="USERNAME"
MARKOV_ORDER=3
DATABASE_DIR=/tmp/jabberhive_db
DISCORD_KEY=insert_here

################################################################################

JH_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

function start_cmd
{
   if ! screen -list | grep -q "$1"; then
      screen -S $1 -d -m nice $2
   fi
}

start_cmd "jh-server" "$JH_DIR/server/markov-k-disk/run.sh /tmp/jh0 $MARKOV_ORDER $DATABASE_DIR"
start_cmd "jh-limiter" "$JH_DIR/filter/limiter/run.sh /tmp/lt0 /tmp/jh0 $REPLY_RATE"
start_cmd "jh-regex" "$JH_DIR/filter/regex/run.sh /tmp/rx0 /tmp/jh0 /tmp/lt0 '$REGEX_CAPTURE' '$REGEX_REPLACE'"
start_cmd "jh-lowercase" "$JH_DIR/filter/lowercase/run.sh /tmp/lc0 /tmp/twr0"
start_cmd "jh-two-way-replace" "$JH_DIR/filter/two-way-replace/run.sh /tmp/twr0 /tmp/rx0"
start_cmd "jh-discord" "$JH_DIR/gateway/discord/run.sh /tmp/pers0 $DISCORD_KEY"
start_cmd "jh-personalizer" "$JH_DIR/filter/personalizer/run.sh /tmp/pers0 /tmp/lc0 $REPLACE_NAMES_WITH"
