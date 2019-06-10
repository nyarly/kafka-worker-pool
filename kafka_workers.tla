--------------------------- MODULE kafka_workers ---------------------------

\* We need a Kafka with two topics: work_orders, and work_claims
\* Represent a topic as a sequence and an index. (or: regular and committed?)

\* A pool of workers that
\* Can get its commited index from the queue,
\* And does exactly-once work based on work_orders

\* Customers who issue work_orders onto the work_orders queue.
\* Some number of customers, some number of orders each.

(*--algorithm kafka_workers

variables
  work_orders = [ index |-> 0, committed |-> 0, queue |-> <<>>];
  work_claims = [ index |-> 0, committed |-> 0, queue |-> <<>>];

begin
end algorithm;*)


=============================================================================
\* Modification History
\* Last modified Fri Jun 07 17:23:36 PDT 2019 by judson
\* Created Thu Jun 06 17:46:57 PDT 2019 by judson
