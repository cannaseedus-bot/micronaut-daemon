# Repository Guidelines

## Project Structure & Module Organization

The root contains the C++17 daemon and supporting modules: `main.cpp` starts the runtime, `http_server.*` handles requests, and paired `.cpp`/`.h` files implement features such as AIML, vector storage, and routing. OpenCL kernels live in root-level `.cl` files. `tools/` contains test programs and maintenance scripts; `templates/`, `examples/`, `data/`, and `aiml-en-us-foundation-alice/` hold inputs and examples. Treat `build/` and `bin/` as generated output.

## Build, Test, and Development Commands

- `cmake -S . -B build` configures the C++17 project.
- `cmake --build build --config Release` builds the daemon, command-line utilities, and test executables. The daemon target is named `micronaut`; its output path is set in `CMakeLists.txt`.
- `python aiml_to_gguf.py aiml-en-us-foundation-alice build/alice.aiml.jsonl` compiles the Alice corpus used by `chat.generate`.
- `python tools/test_fold_pair.py` runs one focused Python check. Run other `tools/test_*.py` scripts for the area changed.

`npm test` is currently a placeholder that exits with an error; it is not the project test command.

## Coding Style & Naming Conventions

Follow nearby code and keep C++ declarations in matching headers. Use four-space indentation in C++ and Python, descriptive `snake_case` filenames and functions, and `test_<feature>` names for new test targets or scripts. Keep kernel changes in the relevant `.cl` file and update CMake copy rules when a new runtime kernel is required. No repository-wide formatter or linter is configured.

## Testing Guidelines

C++ tests are standalone executables declared in `CMakeLists.txt`, with sources under `tools/test_*.cpp`; Python checks use `tools/test_*.py`. Build and run the affected executable directly, for example `./build/Release/test_vector_plan.exe` on Windows. Add focused coverage for changed behavior and report the exact commands run. No coverage threshold or CTest registration is defined.

## Commit & Pull Request Guidelines

Git history is unavailable in this directory, so no existing commit-message convention can be verified. Use a concise imperative subject, such as `Fix vector plan validation`. In pull requests, explain the behavior changed, list build and test results, link any relevant issue, and include sample request/output or screenshots when changing visible behavior.

## Configuration & Generated Files

Keep local secrets in `.env` and out of commits. Review generated corpus files and build artifacts before staging changes; source inputs and scripts should remain the authoritative versions.
