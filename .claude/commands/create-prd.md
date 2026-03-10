---
description: Create a Product Requirements Document from an app idea
argument-hint: <output-filename>
allowed-tools: Read, Write, Glob, Grep
---

# Create PRD: $ARGUMENTS

## Overview

Generate a comprehensive Product Requirements Document based on the conversation context and requirements discussed.

## Output File

Write the PRD to: `.plans/prd-$ARGUMENTS.md` (or `$ARGUMENTS` if a full path is provided)

## PRD Structure

Create a well-structured PRD with the following sections. Adapt depth based on available information.

### Required Sections

**1. Executive Summary**
- Concise product overview (2-3 paragraphs)
- Core value proposition
- MVP goal statement

**2. Mission & Principles**
- Product mission statement
- 3-5 core design principles

**3. Target Users**
- Primary user personas
- Key user needs and pain points
- Technical comfort level

**4. MVP Scope**
- **In Scope**: Core functionality (use ✅ checkboxes)
- **Out of Scope**: Deferred features (use ❌ checkboxes)
- Group by category: Core Functionality, Technical, Integration, Deployment

**5. User Stories**
5-8 primary user stories in format:
> As a [user], I want to [action], so that [benefit]

Include concrete examples for each story.

**6. Architecture & Patterns**
- High-level architecture approach
- Recommended directory structure
- Key design patterns
- Data flow overview

**7. Feature Specifications**
- Detailed breakdown of each core feature
- Acceptance criteria per feature
- Dependencies between features

**8. Technology Stack**
- Backend/Frontend technologies with versions
- Key dependencies and libraries
- Third-party integrations
- Development tools (testing, linting, CI)

**9. Security & Configuration**
- Authentication/authorization approach
- Configuration management (env vars, settings)
- Security requirements and constraints

**10. API Specification** (if applicable)
- Key endpoints with methods, paths, request/response shapes
- Authentication requirements
- Error response format

**11. Success Criteria**
- MVP success definition
- Functional requirements (✅ checkboxes)
- Quality indicators
- User experience goals

**12. Implementation Phases**
Break into 3-4 phases, each with:
- Goal statement
- Deliverables (✅ checkboxes)
- Validation criteria
- Dependencies on previous phases

**13. Risks & Mitigations**
- 3-5 key risks with specific mitigation strategies

## Instructions

### 1. Extract Requirements
- Review the conversation for explicit requirements and implicit needs
- Note technical constraints and user preferences
- Capture goals and success criteria

### 2. Synthesize
- Organize into appropriate sections
- Fill reasonable assumptions where details are missing
- Ensure technical feasibility and consistency

### 3. Write the PRD
- Use clear, professional language
- Include concrete examples and specifics
- Use markdown formatting: headings, lists, code blocks, checkboxes, tables
- Keep Executive Summary concise but comprehensive

### 4. Quality Checks
- ✅ All required sections present
- ✅ User stories have clear benefits
- ✅ MVP scope is realistic
- ✅ Technology choices are justified
- ✅ Implementation phases are actionable
- ✅ Success criteria are measurable

## After Creation

1. Confirm the file path
2. Provide a brief summary of the PRD
3. Highlight any assumptions made
4. Suggest next steps: review → `/plan <first-feature>` → `/build <feature>`
