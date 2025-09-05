Architecture

Flutter app with core/detection, training engine, scenario content; Android PROCESS_TEXT; no network.

## Training Module

The training module is designed to be an offline, interactive learning experience. It consists of the following components:

-   `lib/training/engine.dart`: A state machine that manages the training flow. It handles scenario progression, user choices, feedback, and recall questions.
-   `lib/training/scenarios.dart`: Contains the data models for the training content and the list of all training scenarios. The content is bundled in the app for offline access.
-   `lib/screens/training_screen.dart`: The UI for the training module. It's a stateful widget that reacts to the state of the `TrainingEngine`.
