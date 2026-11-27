jq -r '.incidents[].impact' samples/github_incidents.json | sort | uniq -c
