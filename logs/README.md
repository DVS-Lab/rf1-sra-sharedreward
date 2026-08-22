# Logs

`code/run_logged.sh` writes verbose logs to ignored `logs/runs/` and compact Markdown records to tracked `logs/records/`. Runlists are generated under ignored `logs/runlists/` unless a reviewed small manifest is intentionally promoted.

Commit run records for major characterization, pilot, and production steps so collaborators can diagnose Linux2 work without access to the live terminal.
