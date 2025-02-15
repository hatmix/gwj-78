# Godot 4 CI

Customization of [abarichello/godot-ci](https://github.com/abarichello/godot-ci) for my needs.

Uses [MikeSchulze/gdUnit4](https://github.com/MikeSchulze/gdUnit4) for testing.

This template includes Github actions for running tests and optionally deploying to itch.io. The tests workflow runs on every push to every branch. Deploy runs after successful test runs on the main branch.

On succesful export, and if configured, the deploy workflow uses butler to deploy the game to itch.io. Setup these secrets in your Github repository to enable push:

ITCHIO_USERNAME
ITCHIO_GAME
BUTLER_API_KEY

Note that for butler uploads to work, the game page must already be created on Itch.io with one file manually uploaded. After that, butler can perform all the updates. (See butler's documentation)
