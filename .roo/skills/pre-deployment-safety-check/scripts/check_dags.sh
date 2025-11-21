#!/bin/bash
set -e

# Validate inputs
PROJECT_ID=$1
LOCATION=$2

if [ -z "$PROJECT_ID" ] || [ -z "$LOCATION" ]; then
    echo "❌ Error: Project ID and location required"
    echo "Usage: $0 <project-id> <location>"
    echo "Example: $0 roogent-dev-ai us-west1"
    exit 1
fi

echo "🔍 Pre-Deployment Safety Check"
echo "================================================"
echo "📍 Project: $PROJECT_ID"
echo "📍 Location: $LOCATION"
echo ""

# Get Composer environment details
ENV_NAME=$(gcloud composer environments list \
    --project=$PROJECT_ID \
    --locations=$LOCATION \
    --format="value(name)" \
    --limit=1 2>/dev/null)

if [ -z "$ENV_NAME" ]; then
    echo "❌ No Composer environment found in $LOCATION"
    exit 1
fi

AIRFLOW_URI=$(gcloud composer environments describe $ENV_NAME \
    --location=$LOCATION \
    --project=$PROJECT_ID \
    --format="value(config.airflowUri)")

echo "🌐 Environment: $ENV_NAME"
echo "🌐 Airflow UI: $AIRFLOW_URI"
echo ""

# Get access token for authentication
TOKEN=$(gcloud auth print-access-token)

# Query running DAG runs via Airflow REST API
echo "🏃 Checking Running DAGs..."
echo "------------------------"

RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" \
    "${AIRFLOW_URI}/api/v1/dags/~/dagRuns?state=running")

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "⚠️  Warning: jq not installed. Install with: sudo apt-get install jq"
    echo "Raw response:"
    echo "$RESPONSE"
    exit 1
fi

# Get count of running DAGs
COUNT=$(echo "$RESPONSE" | jq '.total_entries // 0')

if [ $COUNT -gt 0 ]; then
    # Print running DAGs
    printf "%-30s %-25s %-10s\n" "DAG ID" "Started (UTC)" "Uptime"
    printf "%-30s %-25s %-10s\n" "------------------------------" "-------------------------" "----------"
    
    echo "$RESPONSE" | jq -r '.dag_runs[]? | "\(.dag_id)|\(.start_date)"' | while IFS='|' read -r dag_id start_date; do
        # Calculate uptime
        start_epoch=$(date -d "$start_date" +%s 2>/dev/null || echo "0")
        now_epoch=$(date +%s)
        uptime_seconds=$((now_epoch - start_epoch))
        
        hours=$((uptime_seconds / 3600))
        minutes=$(((uptime_seconds % 3600) / 60))
        
        if [ $hours -gt 0 ]; then
            uptime="${hours}h ${minutes}m"
        else
            uptime="${minutes}m"
        fi
        
        printf "%-30s %-25s %-10s\n" "$dag_id" "$start_date" "$uptime"
    done
    echo ""
fi

echo "================================================"
echo "📊 Summary: $COUNT DAG(s) currently running"
echo ""

# Final verdict
if [ $COUNT -eq 0 ]; then
    echo "✅ DEPLOYMENT SAFE: No running DAGs detected"
    echo "🚀 You may proceed with deployment"
    exit 0
else
    echo "❌ DEPLOYMENT NOT SAFE: $COUNT DAG(s) running"
    echo "⚠️  Recommendation: Wait for completion or coordinate with data team"
    exit 1
fi

