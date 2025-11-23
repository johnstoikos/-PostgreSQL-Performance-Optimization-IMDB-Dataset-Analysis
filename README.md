# PostgreSQL Performance Optimization – IMDB Dataset Analysis

## Overview
This project was developed as part of the **Database Management Systems** course and focuses on **performance optimization techniques in PostgreSQL** using the **IMDB dataset**.  
Through a sequence of experiments, we examined how query performance changes after applying:
1. **Memory tuning (shared buffers)**  
2. **Parallel query execution (parallel workers)**  
3. **Table partitioning (range partitioning on startyear)**  

Each optimization step was tested using five SQL queries (Q1–Q5) on IMDB-style tables.

---

## Authors
- **Anargyrou Lamprou Aikaterini**
- **Stoikos Ioannis Panagiotis**  

*Course:* Database Management Systems  
*Assignment 2*  

---

## Database Schema
The project uses the same IMDB-based schema as Assignment 1:

| Table | Description |
|--------|-------------|
| `name_basics` | Information about people (`nconst`, `primaryname`, `birthyear`, `primaryprofession`, `knownfortitles`) |
| `title_basics` | Titles and metadata (`tconst`, `primarytitle`, `titletype`, `startyear`, `genres`) |
| `title_ratings` | Ratings and votes (`tconst`, `averagerating`, `numvotes`) |

Indexes from Assignment 1 were maintained to ensure fair performance comparison across optimization experiments.

---

## Experiment 1 – Base Queries (No Optimization)
Five SQL queries (Q1–Q5) were designed to test different workloads:

| Query | Description |
|--------|--------------|
| **Q1** | Find contributors related to a production by its code (`knownfortitles`). |
| **Q2** | Retrieve title category and genre for a given title ID. |
| **Q3** | Calculate average ratings for all titles associated with a given actor (e.g., *Brad Pitt*). |
| **Q4** | Find cases where an actor also appears as director, producer, or writer. |
| **Q5** | Return the most popular title per decade based on vote count. |

Performance analysis using **EXPLAIN ANALYZE** showed:
- Q1 and Q5 were the most resource-intensive (several seconds).  
- Q2–Q4 were fast (<1 ms), benefiting from index scans.

---

## Experiment 2 – Increasing Memory Buffers
### Configuration
PostgreSQL parameter `shared_buffers` was increased from the default to **4GB**:

```sql
ALTER SYSTEM SET shared_buffers TO '4GB';
