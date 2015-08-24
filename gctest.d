import std.stdio,core.memory,core.time,std.datetime,std.random,core.thread;
// inspired by http://mattwarren.org/2014/06/18/measuring-the-impact-of-the-net-garbage-collector/
double[][int] save;

void testFn(){
    auto i=uniform(2003,30003);
    auto j=uniform(50001,100010);
    double[] x=new double[i];
    double[] y=new double[j];
    if(i<5000){
	save[i]=x;
	//save[j]=y;
    }
    x[1]=1.0f;
    y[1]=4.0f;
}

void thrFunc(){
    while(1==1){
	auto t0=Clock.currTime();
	Thread.sleep(5.msecs);
	auto t1=Clock.currTime();
        auto elps=t1-t0;
	if(elps>8.msecs){
	    writeln("pause:",elps);
	}
    }
}


void main(){
    auto thread=new Thread(&thrFunc);
    thread.start();
    writeln("started");
    //GC.disable();
    auto t0=Clock.currTime();
    for(int i=0;i<100000;i++){
        testFn();
    }
    auto t1=Clock.currTime();
    auto ela1=t1-t0;
    writeln("finished ",ela1);
    stdin.readln();
    auto t2=Clock.currTime();
    GC.collect();
    auto t3=Clock.currTime();
    writeln("GC time:",(t3-t2));
    writeln("saved ",save.length);
}
