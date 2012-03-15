#!/usr/sbin/dtrace -s pragma D option quiet
dtrace:::BEGIN {
        printf("Tracing... Hit Ctrl-C to end.\n");
}
io:::start {
        start_time[arg0] = timestamp;
}
io:::done /(args[0]->b_flags & B_READ) && (this->start = start_time[arg0])/ {
        this->delta = (timestamp - this->start) / 1000;
        @plots["Read I/O, us",
        execname,
        args[1]->dev_statname,
        args[1]->dev_pathname,
        args[1]->dev_major,
        args[1]->dev_minor] = quantize(this->delta);
        @avgs["Avg read I/O, us"] = avg(this->delta);
        start_time[arg0] = 0;
}

io:::done /!(args[0]->b_flags & B_READ) && (this->start = start_time[arg0])/ {
        this->delta = (timestamp - this->start) / 1000;
        @plots["Write I/O, us",
        execname,
        args[1]->dev_statname,
        args[1]->dev_pathname,
        args[1]->dev_major,
        args[1]->dev_minor] = quantize(this->delta);
        @avgs["Avg write I/O, us"] = avg(this->delta);

        start_time[arg0] = 0;
}

profile:::tick-10sec {
        printa("%s %s %s :: %s\n (%d,%d), us:\n%@d\n ", @plots);
        printa(@avgs);
        printf("%Y\n", walltimestamp);
}
