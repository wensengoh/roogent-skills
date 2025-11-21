---
name: pre-deployment-safety-checks
description: Verify GCP Composer Airflow environments have no running DAGs before deployment to prevent conflicts
tags: [gcp, airflow, composer, deployment, safety, pre-deployment]
permissions: [run_command]
required_mode: [code, devops]
---

# Pre-Deployment Safety Checks

## Overview

This skill checks all GCP Composer (Airflow) environments in a project to ensure no DAGs are currently running. Running DAGs during deployment can cause:
- Data pipeline failures
- Incomplete data processing
- Resource conflicts
- Deployment rollback issues

## Instructions

1. Get the GCP project ID and location from the user
   - Project ID examples: `roogent-dev-ai`, `roogent-prod-ai`
   - Location examples: `us-west1`, `us-central1`, `asia-east1`
2. Run the safety check script:
   ```bash
   .roo/skills/pre-deployment-safety-checks/scripts/check_dags.sh <project-id> <location>
   ```
3. Interpret and report the results:
   - **Exit code 0** (✅): Safe to deploy - no running DAGs detected
   - **Exit code 1** (❌): Not safe - running DAGs detected, recommend waiting or coordinating with data team

## Expected Output

### Safe to Deploy
```
🔍 Pre-Deployment Safety Check
================================================
📍 Project: roogent-dev-ai
📍 Location: us-west1

🌐 Environment: composer-env
🌐 Airflow UI: https://...

🏃 Checking Running DAGs...
------------------------
================================================
📊 Summary: 0 DAG(s) currently running

✅ DEPLOYMENT SAFE: No running DAGs detected
🚀 You may proceed with deployment
```

### Not Safe to Deploy
```
🔍 Pre-Deployment Safety Check
================================================
📍 Project: roogent-prod-ai
📍 Location: us-west1

🌐 Environment: prod-composer
🌐 Airflow UI: https://...

🏃 Checking Running DAGs...
------------------------
DAG ID                         Started (UTC)             Uptime
------------------------------ ------------------------- ----------
data_pipeline_daily            2024-01-15 10:30:00       2h 15m
etl_transform                  2024-01-15 12:00:00       45m

================================================
📊 Summary: 2 DAG(s) currently running

❌ DEPLOYMENT NOT SAFE: 2 DAG(s) running
⚠️  Recommendation: Wait for completion or coordinate with data team
```

## Prerequisites

- `gcloud` CLI installed and authenticated
- Appropriate permissions to list Composer environments and query DAG status
- Project ID must have Composer environments configured

## Use Cases

- Pre-deployment validation in CI/CD pipelines
- Manual deployment safety checks
- Automated deployment gates
- Coordination between deployment and data teams

