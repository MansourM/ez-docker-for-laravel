# Bashly - CLI Framework for Bash

## What is Bashly?

Bashly is a command-line application (written in Ruby) that generates feature-rich bash command-line tools. It allows you to focus on your specific code without worrying about command-line argument parsing, usage texts, error messages, and other framework functions.

## How It Works

1. **Define**: You provide a YAML configuration file (`src/bashly.yml`) describing commands, subcommands, arguments, and flags
2. **Generate**: Bashly generates a bash script (`bashly generate`) that handles parsing, validation, and help messages
3. **Implement**: Your code for each command is kept in separate files in `src/` directory
4. **Regenerate**: Run `bashly generate` again to merge your code changes back into the final script

## Key Features

- Generates a **single, standalone bash script**
- **Human-readable**, shellcheck-compliant, and shfmt-compliant output
- Automatic **usage texts and help screens**
- Parses **positional arguments**, **option flags**, and **commands/subcommands**
- Validates user input before running
- Provides optional standard library functions (colors, config management, YAML parsing, bash completions)
- Auto-generates **markdown and man page documentation**

## Project Structure

```
project/
├── src/
│   ├── bashly.yml              # Main configuration file
│   ├── before.sh               # Global setup (runs before all commands)
│   ├── lib/                    # Reusable library functions
│   │   ├── function1.sh
│   │   └── function2.sh
│   ├── command_name_command.sh # Command implementations
│   └── ...
└── ez                          # Generated executable (DO NOT EDIT MANUALLY)
```

## Important Rules

### ⚠️ NEVER Edit the Generated Script Directly

The `ez` file is **auto-generated** by Bashly. Any manual edits will be **overwritten** the next time you run `bashly generate`.

**Always edit source files in `src/` directory:**
- `src/bashly.yml` - CLI structure and configuration
- `src/*_command.sh` - Command implementations
- `src/lib/*.sh` - Library functions
- `src/before.sh` - Global hooks

### How Library Functions Work

Bashly automatically includes all `.sh` files from `src/lib/` directory in the generated script. Files are included in alphabetical order.

**Important**: Bashly does NOT automatically include subdirectories. If you create `src/lib/security/file.sh`, it will NOT be included.

**Solutions**:
1. Place files directly in `src/lib/` (e.g., `src/lib/input_validator.sh`)
2. Or manually source subdirectory files in your command scripts

## Basic Workflow

### 1. Initialize (First Time Only)

```bash
bashly init              # Creates sample src/bashly.yml
# or
bashly init --minimal    # Creates simpler configuration
```

### 2. Edit Configuration

Edit `src/bashly.yml` to define your CLI structure:

```yaml
name: ez
help: My CLI tool description
version: 0.3.0

commands:
  - name: docker
    alias: d
    help: Docker commands
    
    commands:
      - name: install
        alias: i
        help: Install Docker
```

### 3. Generate Script

```bash
bashly generate
```

This creates:
- The main executable script (`ez`)
- Placeholder files for your commands in `src/` (e.g., `src/docker_install_command.sh`)

### 4. Implement Commands

Edit the generated command files in `src/`:

```bash
# src/docker_install_command.sh
apt-get update
apt-get install docker-ce
```

### 5. Regenerate

After editing command files or adding library functions:

```bash
bashly generate
```

This merges your changes back into the main script.

## Common Commands

```bash
bashly init              # Create initial configuration
bashly generate          # Generate/regenerate the script
bashly add command       # Add a new command interactively
bashly validate          # Validate bashly.yml syntax
bashly doc               # Generate markdown documentation
```

## In This Project

We use Bashly to generate the `ez` CLI tool:

- **Configuration**: `src/bashly.yml` defines all commands (docker, shared, laravel)
- **Commands**: Each command has its own file (e.g., `src/laravel_deploy_command.sh`)
- **Libraries**: Reusable functions in `src/lib/` (logging, validation, etc.)
- **Hooks**: `src/before.sh` runs before every command (e.g., root check)
- **Generated**: `ez` is the final executable (never edit directly!)

## Installation

Bashly requires Ruby. To install:

```bash
gem install bashly
```

For detailed installation instructions, see: https://bashly.dev/installation/

## Resources

- Official Documentation: https://bashly.dev/
- GitHub: https://github.com/bashly-framework/bashly
- Examples: https://github.com/bashly-framework/bashly/tree/master/examples
