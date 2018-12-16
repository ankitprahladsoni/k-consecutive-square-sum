# Find sum of k consecutive squares and check if the result is a perfect square for the range 1..N 
**COP5615 - Distributed Operating Systems Principles Project 1**


The project uses actor model facility in Elixir to produce an immaculate solution to the problem statement mentioned above.The main idea is to utilize as many cores for as much time to get an efficient concurrent system.

---
## Group Info

* [Ankit Soni- 8761-9158](http://github.com/ankitprahladsoni)
* [Kumar Kunal- 5100-5964](http://github.com/kunal4892)

---

## Size of workunit:  

>The program was tested for a lot of combinations and 1/64th chunk of work  
to each process seemed to give us the most optimized output.  
In a given range of numbers the input was divided into 64 parts and thrown open
for consumption. For 2-4 systems this division seems appropriate as each system has definitely some chunk of work to compute upon. Chunks bigger than this would cause some processors to just wait. While smaller chunks that are more in number will cause a lot of network overhang/calls reducing the efficiency. 
---

## Instructions:

Since the application is a distributed one, the implementation takes care of the modularity and isolation for the server and the worker systems. Hence the server starts a worker implicitly and also there is a provision to start as many workers from the same machine or another.


* For starting workers other than the one that server starts implicitly make sure epmd is running on all machines. The command is given below:
>$ epmd -daemon

* Run the application as server

Running the app as the server makes it ready to distribute number ranges to workers.
The server also participate in calculations along with supervising the workers. The workers communicate finished job to the server. The server closes when all the workers are done performing their tasks along with itself

>$ *mix run proj1.exs N k*  
eg. *mix run  proj1.exs 1000000 4*  
output:   
Completed work  
Completed everything  

* Running the application explicitly on worker/s on the same system or different systems

The worker logic is invoked when the argument passed to proj1.exs is of the pattern server@Server_ip_address. This program then becomes a “worker” and contacts the server to get work. Multiple workers can participate in the computation along with the server itself.The workers don't output the result, and instead only notify the server of their findings.


>$ *mix run proj1.exs server@server-ip-address*  
eg. *mix run proj1.exs server@192.168.0.13*  


For the bonus 15% of the project following command needs to be run with the IP address of the server started above.

* Running a process on a separate machine  
>$ *mix run proj1.exs server@server-ip-address*  
eg. *mix run proj1.exs server@192.168.0.13*   


Three systems were connected together. One server and two workers

---

## Result of running:
The application runs separately for 1 server and worker/s.
Server:
>$ *mix run proj1.exs 1000000 4*  
Completed everything

Worker:
>$ *mix run proj1.exs server@192.168.0.13*  
Completed work

No number was outputted for the mentioned input.

---

## CPU time to Real time for mix run proj1.exs 1000000 4:

> *Real Time: 0m0.695s*  
 *User Time:  0m1.357s*  
 *Sys Time:   0m0.058*  
----

## The largest problem that was solved:
 
 
 *N = 500000000,  k = 4*  
 > *Real Time: 3m3.769s*  
 *User Time:  11m54.709s*  
 *Sys Time:   0m11.105*  
 ---
 

