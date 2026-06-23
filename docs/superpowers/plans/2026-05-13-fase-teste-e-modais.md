# Fase de Teste e Modais Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a non-scoring test phase, close buttons for reward and sound modals, and unify pause/menu labeling in the existing Godot UI.

**Architecture:** Keep the implementation inside `scripts/main.gd` and `scenes/main.tscn`, because the current game loop, overlays, score flow, and button wiring already live there. Introduce a small explicit test-mode state, reuse the existing phase UI and feedback modal, and add close controls to the existing overlays instead of creating new scenes.

**Tech Stack:** Godot 4, GDScript, `.tscn` scene tree

---

### Task 1: Add start-screen and modal nodes in the scene

**Files:**
- Modify: `scenes/main.tscn`
- Test: manual smoke test in Godot editor/runtime

- [ ] **Step 1: Add the failing UI expectation**

Open `scenes/main.tscn` and confirm the start overlay has no `BtnTestPhase`, the reward popup has no `BtnRewardClose`, and the pause overlay audio tab has no explicit close button. This is the red state because the requested controls do not exist yet.

- [ ] **Step 2: Verify the scene is missing the requested nodes**

Run a text check:

```powershell
rg -n "BtnTestPhase|BtnRewardClose|BtnPauseOverlayClose" "C:\Users\acer\Documents\detetive_numeros\scenes\main.tscn"
```

Expected: no matches.

- [ ] **Step 3: Add minimal scene nodes**

Add:

```text
- `BtnTestPhase` inside the start buttons container near `BtnStartGame`
- `BtnRewardClose` inside the reward popup header area
- `BtnPauseOverlayClose` attached to the pause overlay card top-right area
```

Keep them using the same theme variations already used by the scene (`SecondaryButton` / `GhostButton`) so they fit the existing UI.

- [ ] **Step 4: Verify the scene contains the new controls**

Run:

```powershell
rg -n "BtnTestPhase|BtnRewardClose|BtnPauseOverlayClose" "C:\Users\acer\Documents\detetive_numeros\scenes\main.tscn"
```

Expected: one match for each node name.

### Task 2: Add explicit state and helpers for the test phase

**Files:**
- Modify: `scripts/main.gd`
- Test: manual smoke test in Godot editor/runtime

- [ ] **Step 1: Add the failing state expectation**

Confirm `main.gd` has no state that distinguishes a test phase from real progression, and no helper that creates a random arithmetic question for test mode.

- [ ] **Step 2: Verify the code is missing the test-mode helpers**

Run:

```powershell
rg -n "test_phase|is_test_phase|_build_test_phase|_start_test_phase|_generate_test" "C:\Users\acer\Documents\detetive_numeros\scripts\main.gd"
```

Expected: no matches.

- [ ] **Step 3: Add minimal state and generation helpers**

Implement:

```gdscript
var is_test_phase := false
var pending_real_game_after_test := false

func _start_test_phase() -> void:
    player_name = name_input.text.strip_edges()
    if player_name.is_empty():
        return
    is_test_phase = true
    pending_real_game_after_test = false
    start_overlay.visible = false
    _reset_runtime_state_for_new_session(false)
    _load_test_phase()

func _load_test_phase() -> void:
    current_phase_source = _build_test_phase_data()
    current_phase = current_phase_source.duplicate(true)
    current_question = current_phase.duplicate(true)
    in_boss_phase = false
    current_phase_index = 0
    _setup_phase_ui(current_phase, current_question)
```

Also add a helper that creates a simple random arithmetic question plus plausible alternatives and marks the resulting dictionary as test-only.

- [ ] **Step 4: Verify helper names and state are present**

Run:

```powershell
rg -n "is_test_phase|_start_test_phase|_load_test_phase|_build_test_phase_data" "C:\Users\acer\Documents\detetive_numeros\scripts\main.gd"
```

Expected: all helpers present.

### Task 3: Route the start buttons and keep test mode isolated from score/progression

**Files:**
- Modify: `scripts/main.gd`
- Test: manual smoke test in Godot editor/runtime

- [ ] **Step 1: Add the failing behavior expectation**

The current start flow only supports the real game path from `_on_start_game_pressed`, and all success handlers add score and advance progression.

- [ ] **Step 2: Verify the current code always scores and advances**

Run:

```powershell
rg -n "_on_start_game_pressed|score \+=|_advance_after_success|_award_phase_badge" "C:\Users\acer\Documents\detetive_numeros\scripts\main.gd"
```

Expected: only the real-game flow exists.

- [ ] **Step 3: Write minimal routing and isolation**

Update the button wiring to connect `BtnTestPhase` to `_start_test_phase`. Extract the game reset logic into a helper that can either clear score/badges for a real game or preserve them when entering/leaving test mode. In the correct-answer path:

```gdscript
if is_test_phase:
    phase_in_progress = false
    _show_feedback_modal(
        "🎉",
        "Muito Bem!!!",
        "Podemos comecar nossa aventura???!!!",
        "SIM!",
        "start_real_game",
        "TELA INICIAL",
        "go_start",
        {}
    )
    return
```

Ensure test mode does not call score increment, badge award, reward popup, or phase advancement.

- [ ] **Step 4: Verify the new test route exists**

Run:

```powershell
rg -n "BtnTestPhase|start_real_game|go_start|is_test_phase" "C:\Users\acer\Documents\detetive_numeros\scripts\main.gd"
```

Expected: the new route and modal actions are present.

### Task 4: Add close actions for reward and sound overlays and rename pause/menu entry points

**Files:**
- Modify: `scripts/main.gd`
- Modify: `scenes/main.tscn`
- Test: manual smoke test in Godot editor/runtime

- [ ] **Step 1: Add the failing behavior expectation**

The reward popup auto-hides only by tween timeout, and the sound tab has no dedicated top-right close control. The main HUD pause label also still reflects only pause semantics.

- [ ] **Step 2: Verify current labels and close controls**

Run:

```powershell
rg -n "BtnPause|Menu|Premiacao|Som|_show_reward_popup|_show_pause_overlay" "C:\Users\acer\Documents\detetive_numeros\scripts\main.gd"
```

Expected: no dedicated close handler for reward/sound and no `Menu/Pause` label.

- [ ] **Step 3: Write minimal close handlers and relabeling**

Implement:

```gdscript
func _hide_reward_popup() -> void:
    reward_popup.visible = false
    reward_popup.modulate.a = 1.0
    reward_popup.scale = Vector2.ONE

func _close_pause_overlay_from_audio() -> void:
    _hide_pause_overlay()
```

Wire `BtnRewardClose` to `_hide_reward_popup()`, `BtnPauseOverlayClose` to `_hide_pause_overlay()`, rename the HUD button text to `Menu/Pause`, and rename the helper tab button label from `Menu` to `Menu/Pause` where appropriate without changing the existing actions.

- [ ] **Step 4: Verify the close handlers and new label exist**

Run:

```powershell
rg -n "Menu/Pause|_hide_reward_popup|BtnRewardClose|BtnPauseOverlayClose" "C:\Users\acer\Documents\detetive_numeros\scripts\main.gd" "C:\Users\acer\Documents\detetive_numeros\scenes\main.tscn"
```

Expected: all new labels and handlers present.

### Task 5: Extend modal actions and start/reset behavior for test-to-real transitions

**Files:**
- Modify: `scripts/main.gd`
- Test: manual smoke test in Godot editor/runtime

- [ ] **Step 1: Add the failing modal-action expectation**

The feedback modal currently supports only `advance`, `retry`, and `restart_game`, so it cannot start the real game after test mode or explicitly return to the start overlay from the test completion modal.

- [ ] **Step 2: Verify the action set is incomplete**

Run:

```powershell
rg -n "_execute_feedback_modal_action|advance|retry|restart_game" "C:\Users\acer\Documents\detetive_numeros\scripts\main.gd"
```

Expected: no `start_real_game` or `go_start` actions.

- [ ] **Step 3: Write minimal modal action support**

Extend `_execute_feedback_modal_action()` with:

```gdscript
"start_real_game":
    is_test_phase = false
    _hide_feedback_modal()
    _restart_whole_game()
"go_start":
    is_test_phase = false
    _hide_feedback_modal()
    _show_start_overlay()
```

Also make `_show_start_overlay()` clear any test-only runtime state so reopening the test always generates a fresh question.

- [ ] **Step 4: Verify the modal action names are wired**

Run:

```powershell
rg -n "start_real_game|go_start|_show_start_overlay" "C:\Users\acer\Documents\detetive_numeros\scripts\main.gd"
```

Expected: the new actions are present and routed.

### Task 6: Validate the full flow locally

**Files:**
- Test: manual smoke test in Godot editor/runtime

- [ ] **Step 1: Run static text checks**

Run:

```powershell
rg -n "BtnTestPhase|BtnRewardClose|BtnPauseOverlayClose|Menu/Pause|is_test_phase|start_real_game|go_start" "C:\Users\acer\Documents\detetive_numeros\scripts\main.gd" "C:\Users\acer\Documents\detetive_numeros\scenes\main.tscn"
```

Expected: all requested markers appear in the edited files.

- [ ] **Step 2: Run interactive smoke test in Godot**

Validate:

```text
1. Start screen shows `Fase de Teste`.
2. Test phase opens with a random arithmetic problem.
3. Solving the test problem does not change score or prizes.
4. Test completion modal offers `SIM!` and `TELA INICIAL`.
5. `SIM!` starts the real game at phase 1.
6. `TELA INICIAL` returns to the name-entry screen.
7. Reward popup closes via `X` and the phase remains intact.
8. Sound overlay closes via `X` and the phase remains intact.
9. HUD shows `Menu/Pause`.
```

- [ ] **Step 3: Record any gaps**

If Godot runtime testing cannot be executed in the current environment, document that limitation in the final handoff and keep the static verification results.
