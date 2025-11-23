SHOW max_parallel_workers_per_gather;
SHOW max_parallel_workers;
SHOW max_worker_processes;
SHOW parallel_setup_cost;
SHOW parallel_tuple_cost;

ALTER SYSTEM SET max_parallel_workers_per_gather TO '6';
ALTER SYSTEM SET max_parallel_workers TO '16';
ALTER SYSTEM SET max_worker_processes TO '20';
ALTER SYSTEM SET parallel_setup_cost TO '0';
ALTER SYSTEM SET parallel_tuple_cost TO '0';