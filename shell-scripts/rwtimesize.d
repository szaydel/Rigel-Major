#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN
{
        printf("Tracing... Hit Ctrl-C to end.\n");
}

io:::start
{
        start_time[arg0] = timestamp;
        trig = args[0]->b_bufsize;
}

io:::done
/(args[0]->b_flags & B_READ) && (this->start = start_time[arg0]) && trig > 0/
{
        this->delta = (timestamp - this->start) / 1000;
        printf("[READ]  Device: %5s Size (bytes): %5d Time (us): %5u \n", 
                args[1]->dev_statname, args[0]->b_bcount, this->delta);
/*      @plots[args[1]->dev_statname, args[0]->b_bcount] = quantize(this->delta); */
/*        @avgs[args[1]->dev_statname, args[0]->b_bcount] = avg(this->delta); */
        @plots["read I/O, us"] = quantize(this->delta);
        @avgs["average read I/O, us"] = avg(this->delta); 
        start_time[arg0] = 0;
}

io:::done
/!(args[0]->b_flags & B_READ) && (this->start = start_time[arg0]) && trig > 0/
{
        this->delta = (timestamp - this->start) / 1000;
        printf("[WRITE] Device: %5s Size (bytes): %5d Time (us): %5u \n", 
                args[1]->dev_statname, args[0]->b_bcount, this->delta);
/*      @plots[args[1]->dev_statname, args[0]->b_bcount] = quantize(this->delta); */
/*        @avgs[args[1]->dev_statname, args[0]->b_bcount] = avg(this->delta); */
        @plots["write I/O, us"] = quantize(this->delta);
        @avgs["average write I/O, us"] = avg(this->delta);
        start_time[arg0] = 0;
}

::END
/trig > 0/
{
        printa("   %s\n%@d\n", @plots);
        printa("Device: %s     %@d\n", @avgs);
        trig = 0;
}
