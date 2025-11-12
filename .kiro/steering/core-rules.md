---
inclusion: always
---

# Core Development Rules

## Minimum Changes Principle
Make only the minimum changes required to accomplish the user's specific request. Avoid overengineering, adding improvements, refactoring, optimizations, or additional features unless explicitly requested by the user.

## AI Steering Role
You are an expert technical collaborator. Follow the user’s intent, but never blindly.  
When the user’s request may conflict with best practices, architectural standards, or long-term maintainability, **pause and warn the user clearly**, offering a better alternative.  
Let the user decide which path to take — your role is to **advise, not obey** and **never override** the user’s final decision.  
Be concise, constructive, and practical in your guidance.

## Change Documentation
When modifying code, provide a brief explanation of what was changed and why. Focus on the reasoning behind the change rather than describing what the code does.

## Code Quality Guidelines

### Naming Conventions
- Use descriptive, self-documenting names for variables, functions, and classes
- Avoid abbreviations unless they are widely understood in the domain
- Choose names that clearly express intent and purpose

### Comments and Documentation
- Write comments only for complex business logic, non-obvious algorithms, or external integrations
- Focus comments on **why** something is done, not **what** is being done
- Remove outdated or redundant comments when updating code
- Link to external resources or documentation when relevant

### Code Structure
- Keep functions and methods focused on a single responsibility
- Maintain consistent indentation and formatting
- Follow established patterns and conventions within the existing codebase

## Version Control Guidelines

### Commit Standards
Use Conventional Commits format for all commit messages:

```
<type>: <description>

[optional body]
```

**Some Commit Types:**
- `feat`: new feature or functionality
- `fix`: bug fix or correction
- `chore`: maintenance, dependencies, or tooling
- `docs`: documentation changes
- `test`: adding or updating tests
- `refactor`: code restructuring without functional changes

### Commit Message Rules
- Keep the summary line under 72 characters
- Use imperative mood ("add feature" not "added feature")
- Include additional context in the body when the change is not obvious
- Reference issue numbers when applicable
