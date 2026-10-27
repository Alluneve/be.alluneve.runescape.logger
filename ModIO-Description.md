# be.alluneve.logger

**be.alluneve.logger** is a shared logging framework for RuneScape plugin developers. It provides a common API for structured, severity-based logging, making it easier to capture diagnostic information and generate useful bug reports without having to build and maintain separate logging infrastructure.

Log messages are retained in independent, per-plugin rolling histories. When a registered plugin triggers the flight recorder, be.alluneve.logger generates a report containing events from **60 seconds before and 10 seconds after the trigger** by default. This provides developers with a timeline of logged events to help investigate and troubleshoot reported issues.

Reports are stored locally and can be browsed through an in-game interface powered by **PrettyUI**.

## Features

- Shared logging API with **DEBUG, INFO, WARN, and ERROR** severity levels.
- Supports both required and optional dependency integration.
- Independent per-plugin session logs, limited to approximately 1 MiB of estimated memory per plugin.
- Flight recorder triggered automatically by API error logging or manually by developers.
- Configurable recording intervals and post-trigger duration.
- Independent severity settings controlling console output and report submissions.
- Efficient paged FIFO storage with tick-budgeted cleanup.
- Persistent report storage across normal client restarts.
- In-game report viewer with navigation, individual deletion, and archive clearing.
- Manual session-log submission through the API or Plugins interface.

Only log messages explicitly supplied by registered plugins are recorded. be.alluneve.logger does not intercept global Lua errors.

Direct clipboard export is currently awaiting support from the RuneScape Plugin API.

For integration instructions and API documentation, see [INSTALLATION.md](https://github.com/Alluneve/be.alluneve.runescape.logger/blob/main/INSTALLATION.md).

## Dependencies

**PrettyUI** is required for the in-game interface.

## Source

GitHub — [be.alluneve.logger](https://github.com/Alluneve/be.alluneve.runescape.logger)

## Contact Email

For questions:

alluneve@alluneve.be

Although I prefer to be contacted through GitHub issues.

## EULA

By submitting be.alluneve.logger, I acknowledge and agree to the Jagex End User License Agreement, including Schedule 4 governing plugins.

[Jagex End User License Agreement](https://www.jagex.com/en-GB/terms)

## Permissions

be.alluneve.logger does not request any additional RuneScape Plugin API permissions.

## Data Protection

be.alluneve.logger processes logging and diagnostic information explicitly supplied by participating plugins, including:

- Plugin identifiers.
- Log message contents.
- Message severity levels.
- Game logic tick information.

Log messages are temporarily retained in memory through independent per-plugin rolling histories. Submitted reports and configuration settings are stored locally using RuneScape's PersistentDB functionality.

The information contained in log messages depends on what participating plugin developers choose to log.

be.alluneve.logger does not transmit logging or diagnostic information to external servers or third-party services.

Users can browse and delete individual reports or clear all saved reports through the in-game interface. Reports are persisted during normal plugin shutdown, and unexpected client termination may result in the loss of unsaved reports.