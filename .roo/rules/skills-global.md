# Skills Orchestration Policy

## Skill Discovery

### Mandatory Index Consultation
- **ALWAYS** consult `.roo/skills.index.json` for available skills. THIS IS NON-NEGOTIABLE.
- The index is the single source of truth for skill availability

### Matching Algorithm
Match user requests against skills in priority order:
1. **Exact Name Match**: Check if request contains exact skill name
2. **Keyword Match**: Match against skill keywords (highest priority)
3. **Tag Match**: Match against skill tags (categorical indicators)
4. **Description Match**: Semantic match against skill description
5. **Fuzzy Match**: Consider partial matches and synonyms

### Discovery Process
1. Parse user request to identify key terms and intent
2. Load `.roo/skills.index.json`
3. Apply matching algorithm to find relevant skills
4. Read `.roo/skills/<skill>/SKILL.md` for detailed instructions

## Prerequisite Validation

Before executing any skill, validate:
- **Mode Compatibility**: Code mode typically required for script execution
- **Tool Availability**: Verify required tools (e.g., `execute_command`)
- **Parameter Availability**: Check if user provided necessary inputs

## Mode Compatibility and Auto-Delegation

### Automatic Mode Delegation
When a skill is matched but requires a different mode than the current one:

1. **Recognize the Mismatch**: Check if current mode is in the skill's `required_modes`
2. **Auto-Delegate**: Use `new_task` or `switch_mode` to delegate to the appropriate mode
3. **Pass Context**: Include the complete user request in the delegation message

### Delegation Logic
- If skill requires `["code"]` and current mode is `orchestrator`:
  - Use `new_task` with `mode="code"` and the user's original request
- If skill requires `["devops"]` and current mode is not `devops`:
  - Use `new_task` with `mode="devops"` and the user's original request
- If multiple modes are valid, choose the first one in `required_modes`

### Example
```
User (in orchestrator): "create a new skill about X"
→ Matches skill-builder (required_modes: ["code"])
→ Current mode: orchestrator (not in required_modes)
→ Auto-delegate: new_task(mode="code", message="create a new skill about X")
```

This ensures skills are always executed in compatible modes without requiring manual mode switching.

## Skill Execution

### Step-by-Step Process
1. **Read Instructions**: Open `.roo/skills/<skill>/SKILL.md`
2. **Validate Prerequisites**: Confirm tools and parameters available
3. **Discover Parameters**: Extract from SKILL.md, match user values, request missing ones
4. **Execute Scripts**: Use full path `.roo/skills/<skill>/scripts/<script>.sh`
   - Pass parameters in order specified in SKILL.md
   - Use `execute_command` tool
   - Example: `bash .roo/skills/<skill>/scripts/<script>.sh <param1> <param2>`
5. **Monitor Execution**: Capture output, track status and exit codes
6. **Report Results**: Format output clearly with success/failure status

## Error Handling

### Common Scenarios
- **Skill Not Found**: Inform user, suggest similar skills or ask for clarification
- **Missing Parameters**: Use `ask_followup_question` with clear description of what's needed
- **Script Execution Failure**: Capture error, analyze reason, report with context and solutions
- **Invalid Parameter Format**: Validate against SKILL.md, request corrected parameter with example

### Response Formats
**Error**: `❌ Skill Execution Failed: <skill-name>` | **Error**: `<error-message>` | **Resolution**: `<suggested-fix>`

**Success**: `✅ Skill Executed: <skill-name>` | **Parameters Used**: `<param-list>` | **Results**: `<formatted-output>` | **Summary**: `<brief-summary>`

## Example Workflow

**User Request**: "Perform a pre-deployment safety check for project roogent-dev-ai in us-west1"

**Execution**:
1. Load `.roo/skills.index.json`
2. Match "pre-deployment safety check" → find "pre-deployment-safety-check" skill
3. Read `.roo/skills/pre-deployment-safety-check/SKILL.md`
4. Validate: Code mode ✓, execute_command ✓, project_id="roogent-dev-ai" ✓, location="us-west1" ✓
5. Run: `bash .roo/skills/pre-deployment-safety-check/scripts/check_dags.sh roogent-dev-ai us-west1`
6. Report results with formatted output

## Best Practices

**Do's**: ✅ Always consult skills.index.json first | ✅ Read complete SKILL.md before execution | ✅ Validate all parameters before running scripts | ✅ Use full paths for script execution | ✅ Handle errors gracefully with helpful messages

**Don'ts**: ❌ Don't assume skill availability without checking index | ❌ Don't execute scripts without reading SKILL.md | ❌ Don't proceed with missing required parameters

