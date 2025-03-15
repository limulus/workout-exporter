# Workout Exporter

A SwiftUI iOS application that exports Apple HealthKit workout data to TCX format files.

## Purpose

This app is mainly meant to be used as a way to exfiltrate cycling and hiking workout data from HealthKit so the can be synced with videos of those events. You may find it useful for other things. Read more about this in my [blog post].

[blog post]: https://limulus.net/feed/workout-exporter/

## Features

- Export workout data from Apple Health to TCX format
- Support for various workout types (running, cycling, etc.)
- Include detailed workout metrics:
  - Heart rate data
  - GPS routes and coordinates
  - Distance and pace information
  - Elevation data
  - Course and speed information
- View history of previously exported workouts

## Usage

1. Tap “Export Workout…”
2. Grant the app permission to access your HealthKit data
3. Select a workout from the list of available workouts
4. Tap the export to bring up the share sheet and AirDrop to your Mac or save to Files.
