# be.alluneve.logger

**be.alluneve.logger** is a shared logging framework for RuneScape plugin developers. It provides a common API for structured, severity-based logging, making it easier to capture diagnostic information and produce useful bug reports without maintaining separate logging infrastructure.

Log messages are retained in independent, per-plugin rolling histories. When a registered plugin logs an error or manually triggers the flight recorder, be.alluneve.logger generates a report containing events from **60 seconds before and 10 seconds after the trigger** by default. This gives developers a detailed timeline of events to help investigate and reproduce reported issues.

Reports are stored locally and can be browsed through an in-game interface powered by **PrettyUI**.

## Features

- Shared logging API with **DEBUG, INFO, WARN, and ERROR** severity levels.
- Independent per-plugin rolling session logs.
- Automatic flight-recorder triggers through the logging API, with configurable recording intervals.
- Manual recording triggers and session-log submission through the API.
- Independent severity filtering for console output and submitted reports.
- Efficient paged FIFO storage with tick-budgeted cleanup.
- Persistent bug reports with an in-game viewer for browsing and management.
- Support for both required and optional dependency integration.

Only log messages explicitly supplied by participating plugins are recorded. be.alluneve.logger does not intercept global Lua errors.

For integration instructions and API documentation, see [INSTALLATION.md](INSTALLATION.md).