
Hi Users,

We would like to clarify the nature of the following error messages observed during CML / PySpark usage:

```text
Container exited with a non-zero exit code 1
Job 0 cancelled because SparkContext was shut down
Connection refused
```

These messages are commonly shown at the end of a failed execution, but they are usually **not the actual root cause** of the failure. They are surface-level symptoms reported by CML, YARN, Spark, or the underlying runtime after something has already failed earlier in the execution flow.

In most cases, these errors indicate that the Spark session, Spark driver, JVM, Python process, or container has become unhealthy due to an earlier issue. Therefore, it is important to review the complete logs and identify the **first actual error or traceback**, rather than concluding that the final CML/YARN message is the root cause.

## 1. Container exited with a non-zero exit code 1

This is a generic container-level failure message. It means the container hosting the driver or executor ended with an error.

Typical causes include:

1. Memory exhaustion, especially during large data processing.
2. Code-level errors in the notebook or driver script.
3. Spark driver crash due to heavy operations such as `collect()`, `toPandas()`, or large pandas dataframe processing.
4. Reuse of an unhealthy or stale SparkContext from a previous run.
5. Package, dependency, or environment-related issues.

This message alone does not confirm a CML platform issue. The actual reason is normally available earlier in the logs.

## 2. Job 0 cancelled because SparkContext was shut down

This means Spark attempted to run a job, but the Spark application or SparkContext had already stopped.

Common causes include:

1. `spark.stop()` was executed earlier in the same session.
2. SparkSession became inactive, unhealthy, or timed out.
3. Out-of-memory condition caused the Spark driver or SparkContext to shut down.
4. YARN application timeout or termination.
5. Multiple SparkSession objects were created or reused in the same CML session.
6. A previous execution failed, but the same session and old Spark objects were reused.

This message usually indicates that Spark was already stopped before the current command was executed.

## 3. Connection refused

In CML with PySpark, this often happens when the Python process tries to communicate with the Spark JVM or Py4J gateway, but the JVM or driver process is no longer running.

In simple terms, the notebook may still appear active, but the Spark backend it is trying to communicate with has already stopped.

Common causes include:

1. Spark JVM or driver crash.
2. Py4J gateway port closed after SparkContext shutdown.
3. Reuse of old dataframe or Spark variables after the Spark session has become unhealthy.
4. Previous job failure causing the Spark backend to terminate.

## Why these issues are common in interactive sessions

These issues are more frequently seen in interactive CML sessions because users often run code back and forth in the same notebook session, for example:

1. Run a cell.
2. Modify the code.
3. Re-run the same cell.
4. Run older cells out of order.
5. Skip setup or initialization cells.
6. Install or upgrade packages within the same running session.
7. Run Spark jobs repeatedly.
8. Interrupt running jobs.
9. Reuse old variables from previous executions.

This working pattern can create stale session state, memory pressure, dependency conflicts, or references to Spark objects that are no longer valid.

## Recommended actions

To avoid or reduce these issues, please follow the below practices:

1. Restart the CML session after installing or upgrading Python packages.
2. Avoid using `collect()` or `toPandas()` on large datasets.
3. Use `limit()` while testing or previewing data.
4. Run notebook cells in the correct order.
5. Avoid creating SparkSession repeatedly in the same session.
6. Clear Spark cache after testing, if caching is used.
7. Restart the session if SparkContext shutdown or connection refused errors are observed.
8. Review the first traceback or first real error in the logs, not only the final CML/YARN message.

Example:

```python
# Avoid this on large datasets
pdf = spark_df.toPandas()

# Safer approach for testing
pdf = spark_df.limit(1000).toPandas()
```

Going forward, when reporting such issues, please share the complete logs, including the first error or traceback. This will help us identify whether the issue is due to user code, memory usage, Spark behavior, dependency conflict, data access, or an actual platform-level problem.

Regards, <Your Name>
