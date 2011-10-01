#!/usr/bin/bash
#
# Copyright 2011 Nexenta Systems, Inc. All rights reserved.
PATH=/usr/sbin:/usr/bin

FUNCTION=$1

if [ -z "$FUNCTION" ]; then
        echo "error: no kernel function specified"
        exit 1
fi

THRESHOLD=$2
if [ -z "$THRESHOLD" ]; then
        THRESHOLD=1000000
fi

dtrace -Cn '
#pragma D option quiet
#pragma D option dynvarsize=4m

dtrace:::BEGIN { trace("Tracing... Interval 10 seconds, or Ctrl-C.\n"); }

'$FUNCTION':entry
{
        self->ts = timestamp;
}

'$FUNCTION':return
/self->ts && ((this->t = (timestamp - self->ts)) > '$THRESHOLD')/
{
        @s[stack()] = count();
}

'$FUNCTION':return
/self->ts/
{
        t = timestamp - self->ts;
        @l = quantize(t);
        /* @s[stack()] = count(); */
        self->ts = 0;
}

profile:::tick-10s,
dtrace:::END
{
        printf("%Y\t'$FUNCTION'\tnanoseconds", walltimestamp);
        printa(@l);
        trunc(@l);
        printa(@s);
        trunc(@s);
}
'
