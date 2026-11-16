# Contributing to Highest Honor

Thank you for contributing to **Highest Honor**! This document explains how we collaborate, organize our work, and maintain the project. Whether you're working on gameplay mechanics, UI, character systems, scenes, or game assets, these guidelines will help us work together efficiently.

## Where Tasks Live: GitHub Issues

- **All tasks, bugs, improvements, and feature requests are tracked through GitHub Issues.**
- Before starting work, check the Issues tab for available or assigned tasks.
- If you discover a bug or have an idea for a new feature, create an issue with a clear description.
- Avoid working on the same task as another developer unless you've agreed to collaborate.
- Link the related issue when submitting your Pull Request.

## Branch Naming (Organize Your Work)

A **branch** is an independent version of the project where you can work on your assigned task without directly modifying the main branch.

Always create a new branch from the latest `main`:

```bash
git checkout main
git pull origin main
git checkout -b <type>/<short-description>
```

Branch types:

- `feat/` — New game features or mechanics (e.g. `feat/player-movement`)
- `fix/` — Bug fixes (e.g. `fix/player-collision`)
- `ui/` — User interface changes (e.g. `ui/pause-menu`)
- `gameplay/` — Gameplay improvements (e.g. `gameplay/dialogue-system`)
- `assets/` — Adding or modifying game assets (e.g. `assets/character-sprites`)
- `scene/` — Creating or modifying Godot scenes (e.g. `scene/kitchen-room`)
- `docs/` — Documentation updates (e.g. `docs/game-controls`)
- `chore/` — Project maintenance (e.g. `chore/organize-project-files`)

Use lowercase letters and dashes. Avoid spaces and special characters.

## Commit Style (Save Your Progress)

A **commit** is a saved snapshot of your changes. Write clear and meaningful commit messages so everyone understands what was modified.

Use this format:

```text
<type>: <short description>
```

Examples:

- `feat: add player movement`
- `feat: implement dialogue interaction`
- `fix: resolve player collision issue`
- `ui: create main menu`
- `scene: add kitchen room`
- `assets: add character sprites`
- `gameplay: implement NPC interaction`
- `docs: update game controls`

Guidelines:

- Keep commits small and focused on one task.
- Commit whenever you complete a meaningful part of your work.
- Avoid vague messages like `update`, `changes`, or `final`.
- Do not include unrelated modifications in a single commit.

## Pull Request (PR) Checklist

A **Pull Request (PR)** is a request to merge your changes into the main branch. It allows other developers to review your work before it becomes part of the game.

Before submitting a PR:

- [ ] My branch is up to date with `main`.
- [ ] My changes work as expected in Godot.
- [ ] I tested the affected scenes and gameplay mechanics.
- [ ] I checked for script errors and missing resources.
- [ ] I checked for broken node paths, signals, and scene references.
- [ ] My changes do not break existing game systems.
- [ ] I did not commit unnecessary cache or temporary files.
- [ ] I did not commit passwords, API keys, or other sensitive information.
- [ ] I linked the related GitHub Issue.
- [ ] I included screenshots or a video if I modified visual elements or gameplay.

Keep Pull Requests focused on one task whenever possible. This makes reviewing and troubleshooting easier.

After submitting your PR, wait for another developer to review your changes. If revisions are requested, update the same branch and push your fixes.

## Godot Development Guidelines

To keep Highest Honor organized and maintainable, follow these guidelines when developing:

### Scenes and Nodes

- Use separate scenes for reusable objects, characters, UI elements, and environments.
- Keep node hierarchies organized and easy to understand.
- Give nodes meaningful names instead of leaving unnecessary default names.
- Avoid putting unrelated systems into a single scene.
- When modifying an existing scene, check its dependencies before making changes.

### GDScript

- Use descriptive names for variables, functions, and signals.
- Follow the naming conventions already established in the project.
- Keep scripts focused on their responsibilities.
- Avoid unnecessarily duplicating functions or systems.
- Use signals when communication between separate nodes is appropriate.
- Add comments when a function or system needs additional explanation.

### Resources and Assets

- Organize sprites, audio, animations, fonts, and other resources into their appropriate folders.
- Use meaningful filenames.
- Avoid unnecessarily duplicating assets.
- Check resource paths before committing changes.
- Do not delete or rename assets without checking whether other scenes or scripts depend on them.

### Game Testing

- Test modified scenes directly in Godot.
- Check whether character movement, collisions, animations, and interactions work correctly.
- Verify that scene transitions and resource references are functioning.
- Check the Output and Debugger panels for errors.
- Test the main game after integrating changes whenever possible.

## Project File Management

Since Godot automatically generates editor and import data, we need to keep unnecessary files out of GitHub.

- Do not commit the `.godot/` directory. It contains generated editor and imported resource data.
- Keep project files such as `project.godot`, `.tscn`, `.gd`, `.tres`, and required game assets in version control.
- Keep Godot 4 `.gd.uid` files when generated. They help maintain stable resource references.
- Do not manually modify generated cache files.
- Coordinate with teammates before changing project-wide settings or input mappings in `project.godot`.

## Team Collaboration

Since multiple developers are working on the same game, communication is important.

- Inform the team about the task you're working on.
- Avoid modifying another developer's assigned scenes or scripts without coordinating first.
- If your changes depend on another developer's work, communicate with them before proceeding.
- Pull the latest changes from `main` regularly.
- Resolve merge conflicts carefully, especially in `.tscn` files.
- Coordinate when multiple developers need to modify the same scene.
- Review your teammates' Pull Requests when possible.

**Important:** Avoid having multiple developers edit the same scene simultaneously. Godot scene files can produce merge conflicts when different developers modify the same nodes or properties.

## Final Reminder

The goal is not just to make Highest Honor playable, but to build it together while maintaining clean, understandable, and organized project files.

Communicate, test your changes, review each other's work, and keep the project stable for everyone.

Thank you for being part of the development of **Highest Honor**!
