import std.stdio,core.memory,core.time,std.datetime,std.random,core.thread;
// inspired by http://mattwarren.org/2014/06/18/measuring-the-impact-of-the-net-garbage-collector/
/* with GC disabled:
fill node#9000000
finished 1 sec, 152 ms, 620 μs, and 7 hnsecs
pause:404 ms, 150 μs, and 2 hnsecs
GC time:475 ms, 335 μs, and 3 hnsecs

with GC enabled:

fill node#9000000
pause:375 ms, 548 μs, and 1 hnsec
pause:389 ms, 894 μs, and 3 hnsecs
finished 8 secs, 222 ms, and 363 μs

The longest time in GC is taken by stacks scan:
10.740965:     scan stacks.
11.127984:     scan roots[]

*/
Node[] save;
int nodes=1000;

class Node{
    int n;
    Node[] child;
    this(int n,Node[] child){
		this.n=n;
		this.child=child;
    }
    this(int n){
		this.n=n;
    }
    this(){}
}

void testFn(int idx){
    save[idx]=new Node(idx);
    fillNode(save[idx],7);
}

void fillNode(ref Node n,int depth){
	if(depth<=0){
		return;
	}

	//writeln(nodes," ",depth);
	int i=5;
	//uniform(1,5)
    n.child=new Node[i];
    foreach(ref e; n.child){
		e=new Node(nodes++);
		if(nodes%1000000==0){
			writeln("fill node#",nodes);
		}
		fillNode(e,depth-1);
		//writeln(e.child.length);
    }    
}

void thrFunc(){
    while(1==1){
	auto t0=Clock.currTime();
	Thread.sleep(5.msecs);
	auto t1=Clock.currTime();
        auto elps=t1-t0;
	if(elps>10.msecs){
	    writeln("pause:",elps);
	}
    }
}


void main(){
    save=new Node[100];
    auto thread=new Thread(&thrFunc);
    thread.start();
    writeln("started");
    GC.disable();
    auto t0=Clock.currTime();
    for(int i=0;i<100;i++){
        testFn(i);
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
    writeln(save[0].child.length);
}
