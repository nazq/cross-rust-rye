#!/bin/bash

# Replace with your run ID
RUN_ID=$1

# Check if a run ID was provided
if [ -z "$RUN_ID" ]; then
  echo "Usage: $0 <run-id>"
  exit 1
fi

# Fetch the list of jobs for the workflow run
JOBS=$(gh api "repos/nazq/cross-rust-rye/actions/runs/$RUN_ID/jobs" | jq -r '.jobs[].id')

# Check if jobs were found
if [ -z "$JOBS" ]; then
  echo "No jobs found for run ID $RUN_ID"
  exit 1
fi

echo "Found jobs: $JOBS"

# Loop through the jobs and stream their logs
for JOB_ID in $JOBS; do
  echo "Streaming logs for job ID $JOB_ID..."

  while true; do
    # Fetch the logs for the job
    gh api "repos/nazq/cross-rust-rye/actions/jobs/$JOB_ID/logs" > job-$JOB_ID.log

    # Clear the screen and display the logs
    clear
    cat job-$JOB_ID.log

    # Check if the job is still in progress
    STATUS=$(gh api "repos/nazq/cross-rust-rye/actions/jobs/$JOB_ID" | jq -r '.status')
    if [ "$STATUS" != "in_progress" ]; then
      echo "Job $JOB_ID is no longer in progress (status: $STATUS)."
      break
    fi

    # Wait for a few seconds before fetching the logs again
    sleep 10
  done
done

